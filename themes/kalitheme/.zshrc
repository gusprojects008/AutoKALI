#!/bin/zsh

USE_SYNTAX_HIGHLIGHTING=yes
AUTO_DOWNLOAD_SYNTAX_HIGHLIGHTING_PLUGIN=yes

USE_ZSH_AUTOSUGGESTIONS=yes
AUTO_DOWNLOAD_ZSH_AUTOSUGGESTIONS_PLUGIN=yes

PROMPT_ALTERNATIVE=twoline

export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

export TERM=xterm-256color
export COLORTERM=truecolor

# Carregar módulo de cores
autoload -U colors && colors

# Configurações básicas do ZSH
setopt autocd
setopt interactivecomments
setopt magicequalsubst
setopt nonomatch
setopt notify
setopt numericglobsort
setopt promptsubst
setopt share_history

WORDCHARS=${WORDCHARS//\/}

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e
bindkey ' ' magic-space
bindkey '^U' backward-kill-line
bindkey '^[[3;5~' kill-word
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[5~' beginning-of-buffer-or-history
bindkey '^[[6~' end-of-buffer-or-history
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[Z' undo

setopt hist_verify

# force zsh to show the complete history
alias history="history 0"

# configure time format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# Função git_prompt_info alternativa
git_prompt_info() {
    local ref
    ref=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return 0
    
    echo -n "%F{067}[%f${ref}%F{067}]%f"
}

configure_prompt() {
    if [[ $UID == 0 || $EUID == 0 ]]; then
        FGPROMPT="%F{196}"
        CYANPROMPT="%F{027}"
    else
        CYANPROMPT="%F{073}"
        FGPROMPT="%F{027}"
    fi
    
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT="${CYANPROMPT}┌───(%B${FGPROMPT}%n@%m%b${CYANPROMPT})-[%B%f%(6~.%-1~/…/%4~.%5~)%b${CYANPROMPT}]$(git_prompt_info)
${CYANPROMPT}└─%B%(#.%F{red}#.${FGPROMPT}\$)%b%f "
            RPROMPT=''
            ;;
        oneline)
            PROMPT="%B${FGPROMPT}%n@%m%b%f:%B${CYANPROMPT}%~%b$(git_prompt_info)%f%(#.#.\$) "
            RPROMPT=''
            ;;
    esac
}

configure_prompt

# Ativar syntax highlighting
if [[ "$USE_SYNTAX_HIGHLIGHTING" == "yes" ]]; then
    syntax_highlighting=no
    local paths=(
        ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    )
    
    for file in $paths; do
        if [[ -f $file ]]; then
            source $file
            syntax_highlighting=yes
            break
        fi
    done

    if [[ "$syntax_highlighting" == "no" && "$AUTO_DOWNLOAD_SYNTAX_HIGHLIGHTING_PLUGIN" == "yes" ]]; then
        if command -v git &>/dev/null; then
            git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git \
                ~/.zsh/zsh-syntax-highlighting &>/dev/null
            if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
                source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
                syntax_highlighting=yes
            fi
        else
            echo "Git não encontrado. Plugin zsh-syntax-highlighting não instalado."
        fi
    fi

    if [[ "$syntax_highlighting" == "yes" ]]; then
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=white,underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=073,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=073,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=073,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=073,underline
        ZSH_HIGHLIGHT_STYLES[path]=fg=white,bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=073
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=073
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=073,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
fi

# Função para alternar prompt
toggle_oneline_prompt() {
    if [[ "$PROMPT_ALTERNATIVE" == "oneline" ]]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey '^P' toggle_oneline_prompt

# Configurar cores para ls e outros
if [[ -x /usr/bin/dircolors ]]; then
    # Usar cores do Kali diretamente
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    [[ $+commands[pacman] ]] && alias pacman='pacman --color=auto'

    # Completion colors
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# Aliases para ls
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Ativar autosuggestions
if [[ "$USE_ZSH_AUTOSUGGESTIONS" == "yes" ]]; then
    zsh_autosuggestions=no
    local paths=(
        ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
        /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    )
    
    for file in $paths; do
        if [[ -f $file ]]; then
            source $file
            ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555'
            ZSH_AUTOSUGGEST_STRATEGY=(history completion)
            zsh_autosuggestions=yes
            break
        fi
    done

    if [[ "$zsh_autosuggestions" == "no" && "$AUTO_DOWNLOAD_ZSH_AUTOSUGGESTIONS_PLUGIN" == "yes" ]]; then
        if command -v git &>/dev/null; then
            git clone -q https://github.com/zsh-users/zsh-autosuggestions.git \
                ~/.zsh/zsh-autosuggestions &>/dev/null
            if [[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
                source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
                ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#555'
                ZSH_AUTOSUGGEST_STRATEGY=(history completion)
                zsh_autosuggestions=yes
            fi
        else
            echo "Git não encontrado. Plugin zsh-autosuggestions não instalado."
        fi
    fi
fi

if [[ -f /etc/DIR_COLORS ]]; then
    eval $(dircolors -b /etc/DIR_COLORS)
elif [[ -f $HOME/.dir_colors ]]; then
    eval $(dircolors -b $HOME/.dir_colors)
else
    export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=00:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.7z=01;31:*.ace=01;31:*.alz=01;31:*.apk=01;31:*.arc=01;31:*.arj=01;31:*.bz=01;31:*.bz2=01;31:*.cab=01;31:*.cpio=01;31:*.crate=01;31:*.deb=01;31:*.drpm=01;31:*.dwm=01;31:*.dz=01;31:*.ear=01;31:*.egg=01;31:*.esd=01;31:*.gz=01;31:*.jar=01;31:*.lha=01;31:*.lrz=01;31:*.lz=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.lzo=01;31:*.pyz=01;31:*.rar=01;31:*.rpm=01;31:*.rz=01;31:*.sar=01;31:*.swm=01;31:*.t7z=01;31:*.tar=01;31:*.taz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tgz=01;31:*.tlz=01;31:*.txz=01;31:*.tz=01;31:*.tzo=01;31:*.tzst=01;31:*.udeb=01;31:*.war=01;31:*.whl=01;31:*.wim=01;31:*.xz=01;31:*.z=01;31:*.zip=01;31:*.zoo=01;31:*.zst=01;31:*.avif=01;35:*.jpg=01;35:*.jpeg=01;35:*.jxl=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:*~=00;90:*#=00;90:*.bak=00;90:*.crdownload=00;90:*.dpkg-dist=00;90:*.dpkg-new=00;90:*.dpkg-old=00;90:*.dpkg-tmp=00;90:*.old=00;90:*.orig=00;90:*.part=00;90:*.rej=00;90:*.rpmnew=00;90:*.rpmorig=00;90:*.rpmsave=00;90:*.swp=00;90:*.tmp=00;90:*.ucf-dist=00;90:*.ucf-new=00;90:*.ucf-old=00;90:'
fi

zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
alias ls="ls --color=auto"

# Ativar command-not-found se disponível
if [ -f /etc/zsh_command_not_found ]; then
    source /etc/zsh_command_not_found
fi
