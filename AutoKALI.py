# python 3.13

import sys
import os
import subprocess
from subprocess import DEVNULL
import getpass
import typing
import json
import shutil
import pwd
import grp
from pathlib import Path
from terminal_colors import Colors
colors = Colors("", "")

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
THEMES_DIR = os.path.join(SCRIPT_DIR, "themes")
PACKAGES_JSON = os.path.join(THEMES_DIR, "packages.json")
KALITHEME_PACKAGES = os.path.join(SCRIPT_DIR, "kalitheme_packages.txt")
supported_wallpapers = ["kalitheme"]
KALITHEME_WALLPAPERS = os.path.join(THEMES_DIR, "kalitheme", "wallpapers")

def PrivilegiesVerify() -> bool:
    return os.getuid() == 0

def SudoAuthentication():
    if not PrivilegiesVerify():
       print(colors("br", "\nThis program requires administrator privileges!\n"))
       try:
          subprocess.run(["sudo", sys.executable] + sys.argv, check=True)
          sys.exit(0)
       except subprocess.CalledProcessError as error:
              print(colors("br", "\nSubprocess or authentication Error: {error}"))
              sys.exit(1)

def read_utilities_list(utilities_list_path: str) -> list[str]:
    print(colors("ok", "Reading utilities list"))
    with open(utilities_list_path, "r", encoding="utf-8") as file:
         return [line.strip() for line in file if line.strip()]

def InstallUtilities(package_manager: str, utilities_list_path: str):
    print(colors("ok", "Installing utilities..."))
    utilities = read_utilities_list(utilities_list_path)
    match package_manager:
        case "pacman":
            try:
                subprocess.run(["pacman", "-S", "--noconfirm"] + utilities, check=True)
                print(colors("green", f"Installed: {', '.join(utilities)}"))
            except subprocess.CalledProcessError as error:
                   print(colors("error", f"Error installing with pacman: {error}"))
        case other:
             print(f"Package manager '{other}' not supported for installation.")
             sys.exit(1)

def UninstallUtilities(package_manager: str, utilities_list_path: str):
    utilities = read_utilities_list(utilities_list_path)
    match package_manager:
          case "pacman":
               try:
                  subprocess.run(["pacman", "-Rns", "--noconfirm"] + utilities, check=True)
                  print(colors("ok", f"Uninstalled: {', '.join(utilities)}"))
               except subprocess.CalledProcessError as error:
                      print(colors("error", f"Error installing with pacman: {error}"))
          case other:
               print(colors("br", f"Package manager {other} not supported for uninstallation"))
               sys.exit(1)

def expand_path(path: str) -> str:
    if path.startswith("~/"):
       sudo_user = os.environ.get('SUDO_USER')
       if sudo_user and os.getuid() == 0:
          home_dir = f"/home/{sudo_user}"
          path = path.replace('~', home_dir, 1)
    
    return os.path.abspath(os.path.expanduser(os.path.expandvars(path)))

    
def file_backup(path: str):
    expanded_path = expand_path(path)
    backup_path = expanded_path + ".old"
    
    if os.path.exists(expanded_path):
       if os.path.isdir(expanded_path):
          shutil.copytree(expanded_path, backup_path, dirs_exist_ok=True)
          print(colors("ok", f"Directory backup created: {expanded_path} -> {backup_path}"))
       else:
           shutil.copy2(expanded_path, backup_path)
           print(colors("ok", f"File backup created: {expanded_path} -> {backup_path}"))
    else:
        if not path.endswith("/"):
           os.makedirs(os.path.dirname(expanded_path), exist_ok=True)
           with open(expanded_path, "w") as file:
                file.write("# Placeholder created by KaliArch installer\n")
           shutil.copy2(expanded_path, backup_path)
           print(colors("ok", f"Created placeholder and backup for: {expanded_path}"))
        else:
            os.makedirs(expanded_path, exist_ok=True)
            print(colors("ok", f"Created directory: {expanded_path}"))

def config_apply(src: typing.Union[str, list], dest: typing.Union[str, list]):
    if isinstance(src, list) and isinstance(dest, list):
       if len(src) != len(dest):
          print(colors("error", "Error: source and destination lists have different lengths"))
          return
       for s, d in zip(src, dest):
           _single_config_apply(s, d)
    else:
        _single_config_apply(src, dest)

def _fix_owner(path: str):
    if os.getuid() != 0:
       return

    expanded_path = os.path.abspath(path)
    if expanded_path.startswith("/etc/") or expanded_path == "/etc":
       return

    sudo_uid = os.environ.get("SUDO_UID")
    sudo_gid = os.environ.get("SUDO_GID")
    if not sudo_uid or not sudo_gid:
       return

    uid = int(sudo_uid)
    gid = int(sudo_gid)

    if os.path.isfile(expanded_path):
       try:
          os.chown(expanded_path, uid, gid)
       except PermissionError:
              print(colors("warning", f"Failed to change owner of {expanded_path}"))
              return

    for root, dirs, files in os.walk(expanded_path):
        try:
           os.chown(root, uid, gid)
        except PermissionError:
               print(colors("warning", f"Failed to change owner of {root}"))
        for d in dirs:
            p = os.path.join(root, d)
            try:
               os.chown(p, uid, gid)
            except PermissionError:
                   print(colors("warning", f"Failed to change owner of {p}"))
        for f in files:
            p = os.path.join(root, f)
            try:
               os.chown(p, uid, gid)
            except PermissionError:
                   print(colors("warning", f"Failed to change owner of {p}"))

def _single_config_apply(src: str, dest: str):
    full_src = os.path.join(THEMES_DIR, src)
    full_dest = expand_path(dest)
    
    try:
        os.makedirs(os.path.dirname(full_dest), exist_ok=True)

        if os.path.exists(full_dest):
           if os.path.isdir(full_dest):
              shutil.rmtree(full_dest)
           else:
               os.remove(full_dest)

        if os.path.isdir(full_src):
           shutil.copytree(full_src, full_dest)
           print(colors("ok", f"Copied directory: {src} -> {dest}"))
           _fix_owner(full_dest)
        else:
            shutil.copy2(full_src, full_dest)
            print(colors("ok", f"Copied file: {src} -> {dest}"))
            _fix_owner(full_dest)

    except Exception as error:
           print(colors("error", f"Copy failed: {src} -> {dest}: {error}"))

def restore_from_backup(path: str):
    expanded_path = expand_path(path)
    backup_path = expanded_path + ".old"

    if os.path.exists(backup_path) and os.path.exists(expanded_path):
       try:
          if os.path.isdir(expanded_path):
             shutil.rmtree(expanded_path)
          else:
              os.remove(expanded_path)

          if os.path.isdir(backup_path):
             shutil.copytree(backup_path, expanded_path)
          else:
              shutil.copy2(backup_path, expanded_path)
          print(colors("ok", f"Restored backup: {backup_path} -> {expanded_path}"))
       except Exception as error:
              print(colors("error", f"Restore failed: {error}"))
    else:
        print(colors("red", f"No backup found for: {expanded_path}"))

def load_json_packages(PACKAGES_JSON):
    try:
        with open(PACKAGES_JSON, "r", encoding="utf-8") as file:
             return json.load(file)
    except Exception as error:
           print(colors("error", f"Failed to load packages.json: {error}"))
           sys.exit(1)

def InstallKalitheme(package_manager: str):
    print(colors("ok", "Installing Kalitheme..."))

    json_data = load_json_packages(PACKAGES_JSON)

    system_packages = json_data.get("System packages", {}).get("kalitheme", {})
    packages_configs = json_data.get("Packages config", {}).get("kalitheme", {})

    packages_to_install = []
    for pkg in system_packages.keys():
        print(colors("check", f"Checking package {pkg}"))
        if subprocess.run(["pacman", "-Q", pkg], stdout=DEVNULL, stderr=DEVNULL).returncode != 0:
           packages_to_install.append(pkg)

    if packages_to_install:
       print(colors("bb", f"Packages to install: {', '.join(packages_to_install)}"))
       with open(KALITHEME_PACKAGES, "w", encoding="utf-8") as file:
            file.write("\n".join(packages_to_install))
       InstallUtilities(package_manager, KALITHEME_PACKAGES)
    else:
        print(colors("ok", "All required packages are already installed"))

    for pkg, pkg_cfg in system_packages.items():
        if isinstance(pkg_cfg, list):
           for path in pkg_cfg:
               if path.strip():
                  file_backup(path)
        elif isinstance(pkg_cfg, str) and pkg_cfg.strip():
             file_backup(pkg_cfg)
    
        if pkg in packages_configs:
           src_config = packages_configs[pkg]
           dest_config = pkg_cfg
    
           if isinstance(dest_config, list):
              if any(os.path.exists(expand_path(path)) for path in dest_config) or pkg in packages_to_install:
                 config_apply(src_config, dest_config)
           else:
               if os.path.exists(expand_path(dest_config)) or pkg in packages_to_install:
                  config_apply(src_config, dest_config)

    print(colors("ok", "KaliTheme installed successfully!"))

def UninstallKalitheme(package_manager: str):
    print(colors("ok", "Uninstalling Kalitheme..."))

    json_data = load_json_packages(PACKAGES_JSON)

    system_packages = json_data.get("System packages", {}).get("kalitheme", {})
    packages_configs = json_data.get("Packages config", {}).get("kalitheme", {})

    for pkg, pkg_cfg in system_packages.items():
        if isinstance(pkg_cfg, list):
           for path in pkg_cfg:
               restore_from_backup(path)
        else:
            restore_from_backup(pkg_cfg)

    packages_to_uninstall = []
    for pkg in system_packages.keys():
        print(colors("check", f"Checking package {pkg}"))
        if subprocess.run(["pacman", "-Q", pkg], stdout=DEVNULL, stderr=DEVNULL).returncode == 0:
           packages_to_uninstall.append(pkg)

    if packages_to_uninstall:
       print(colors("bb", f"Packages to uninstall: {', '.join(packages_to_uninstall)}"))
       with open(KALITHEME_PACKAGES, "w", encoding="utf-8") as file:
            file.write("\n".join(packages_to_uninstall))
       UninstallUtilities(package_manager, KALITHEME_PACKAGES)
    else:
        print(colors("ok", "No packages to uninstall"))

    print(colors("ok", "KaliTheme uninstalled successfully!"))

def dynamic_background(sec: int, mode: str, wallpapers_path: str, wallpapers_type: str):
    if subprocess.run(["pacman", "-Q", "feh"], stdout=DEVNULL, stderr=DEVNULL).returncode != 0:
        print(colors("warning", "feh not found ); Installing..."))
        try:
           print(colors("ok", "Installing feh ..."))
           subprocess.run(["sudo", "pacman", "-S", "--noconfirm", "feh"], check=True)
        except subprocess.CalledProcessError as error:
               print(colors("error", f"Error installing feh: {error}"))
               sys.exit(1)
    else:
        print(colors("ok", "feh found..."))

    script_path = expand_path("~/.dynamic_background.sh") 
    wallpapers_path = expand_path(wallpapers_path)

    if wallpapers_type == "kalitheme" and wallpapers_type in supported_wallpapers:
       if os.path.exists(wallpapers_path):
          print(colors("ok", f"Doing backup {wallpapers_path}"))
          file_backup(wallpapers_path)
          print(colors("ok", f"Copying {KALITHEME_WALLPAPERS} to {wallpapers_path} ..."))
          shutil.rmtree(wallpapers_path)
          shutil.copytree(KALITHEME_WALLPAPERS, wallpapers_path)
       else:
           print(colors("ok", f"Copying {KALITHEME_WALLPAPERS} to {wallpapers_path} ..."))
           shutil.copytree(KALITHEME_WALLPAPERS, wallpapers_path)
    else:
        print(colors("error", f"Wallpapers type not supported );\nSupported wallpapers: {supported_wallpapers}"))
        sys.exit(1)

    subprocess.run(["pkill", "-f", ".dynamic_background.sh"], stdout=DEVNULL, stderr=DEVNULL)

    script_content = f"""#!/bin/bash
    # Auto-generated by AutoKALI
    while true; do
      mapfile -t W < <(find "{wallpapers_path}" -maxdepth 1 -type f)
      if [ ${{#W[@]}} -eq 0 ]; then
        sleep {sec}
        continue
      fi
    """
    
    if mode == "--randomize":
        script_content += f'  feh --no-fehbg --bg-scale --randomize "${{W[@]}}"\n'
    elif mode == "--ordered":
        script_content += f"""  for img in "${{W[@]}}"; do
        feh --no-fehbg --bg-scale "$img"
        sleep {sec}
      done
    """
    else:
        print(colors("error", "Invalid mode! Use --randomize or --ordered"))
        sys.exit(1)
    
    script_content += f"  sleep {sec}\n"
    script_content += "done &\n"

    with open(script_path, "w", encoding="utf-8") as file:
         file.write(script_content)

    os.chmod(script_path, 0o755)
    print(colors("ok", f"Script created in {script_path}"))

    print(colors("check", "Checking i3 config..."))
    i3_config = expand_path("~/.config/i3/config")

    if os.path.exists(i3_config):
       answer = input(colors("green", f"Do you want i3 to execute '{script_path}' on startup? (y/n): ")).strip().lower()
       if answer == "y":
          with open(i3_config, "r", encoding="utf-8") as file:
               lines = file.readlines()
               exec_line = f"exec --no-startup-id {script_path}  # by AutoKALI\n"
               if exec_line not in lines:
                  with open(i3_config, "a", encoding="utf-8") as file:
                       file.write("\n" + exec_line)
                       print(colors("ok", f"Line added to {i3_config}"))
                       _exec_i3(script_path)
               else:
                   print(colors("ok", "Startup line already exists in i3 config"))
                   _exec_i3(script_path)
       else:
           print(colors("ok", "Ignoring automatic configuration on i3..."))
    else:
        print(colors("ok", "i3 config not found, just executing script..."))

    try:
        subprocess.Popen([script_path])
        print(colors("ok", f"Dynamic background in {script_path} running..."))
    except Exception as error:
           print(colors("error", f"Error running {script_path}: {error}"))

def _exec_i3(path: str):
    try:
       subprocess.run(["i3-msg", "exec", path], stdout=subprocess.DEVNULL, stderr=DEVNULL, check=True)
       sys.exit(0)
    except Exception as error:
           print(colors("error", f"Error to the try reload i3: {error}"))
           sys.exit(1)

if __name__ == "__main__":
   usage = (
     f"{colors('green', 'Usage:')}\n"
     "  --install-utilities <package manager> <utilities.txt>      Install utilities\n"
     "  --uninstall-utilities <package manager> <utilities.txt>    Uninstall utilities\n"
     "  --install-kalitheme <package manager>                      Apply Kali theme\n"
     "  --dynamic-background <sec> <mode> <DIR> <wallpapers type>  Dynamic wallpaper\n"
     "                                                             modes: --randomize, --ordered\n"
     f"                                                            wallpapers types supported: {supported_wallpapers}\n"
     "  --uninstall-kalitheme <package manager>                    Remove Kali theme\n"
     f"{colors('sublime', 'See documentation: https://is.gd/z1VHiI')}\n"
   )

   args = sys.argv

   if len(args) < 2:
      print(usage)
      sys.exit(1)

   remaining_args = args[1:]

   try:
      match remaining_args:
            case ["--install-utilities", package_manager, utilities_list]:
                 SudoAuthentication()
                 InstallUtilities(package_manager, utilities_list)
            case ["--uninstall-utilities", package_manager, utilities_list]:
                 SudoAuthentication()
                 UninstallUtilities(package_manager, utilities_list)
            case ["--install-kalitheme", package_manager]:
                 SudoAuthentication()
                 InstallKalitheme(package_manager)
            case ["--uninstall-kalitheme", package_manager]:
                 SudoAuthentication()
                 UninstallKalitheme(package_manager)
            case ["--dynamic-background", sec, mode, wallpapers_path, wallpapers_types]:
                 dynamic_background(int(sec), mode, wallpapers_path, wallpapers_types)
            case _:
                 print(colors("error", f"Unknown arguments: {remaining_args}"))
                 sys.exit(1)
                 
      sys.exit(0)
   except Exception as error:
          print(colors("error", f"Error: {str(error)}"))
          print(usage)
          sys.exit(1)
