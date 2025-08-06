# KaliArch

## Índice
* [Como funciona?](#como-funciona)
* [Uso](#uso)
* [Futuras funcionalidades](#futuras-funcionalidades)
* [Referências](#referências)

---

## 💡 Sobre
> ***Um script que instala utilitários automaticamente e oferece ao usuário a opção de personalizar o ArchLinux (Xorg + i3-wm) com um tema semelhante ao KaliLinux.***

---

## Como funciona?
O script receberá o nome do gerenciador de pacotes do sistema e uma lista `.txt` com os utilitários que o usuário irá instalar, e assim iniciará a instalação dos pacotes no sistema.
Com o script, o usuário também pode excluir os pacotes instalados com o script, usando o comando `--uninstall utilities.txt`.

O usuário também pode passar o argumento `--kalitheme` para configurar o tema padrão automático que desenvolvi, que simula a estética do KaliLinux. 
Ao passar o argumento `--kalitheme`, o script irá instalar alguns pacotes adicionais como um terminal alternativo (kitty), wallpapers do kalilinux etc..., mas tudo poderá ser removido `--uninstall kalitheme`. Veja o que será adicionado e configurado **[Arquivo de instalação e configuração de pacotes](./kaliarch-theme/packages.json)**

Com o argumento `--kalitheme` será instalado alguns pacotes e suas configurações, o usuário também pode passar o argumento `--dynamic-background` com o segundo argumento um número (por exemplo, `5`) para especificar o tempo de mudança de cada papel de parede (wallpaper) com o terceiro argumento para específicar se eles devem mudar de forma ramdomica `--randomize` ou na ordem padrão dos arquivos do diretório `--orderd` e por fim o quarto argumento, o caminho do diretório para os wallpapers (e.g `~/wallpapers/`).
Você pode copiar o diretório `wallpapers` deste repositório para home.

> 🔴 **As configurações originais do sistema não serão modificadas ou excluídas, elas serão salvas no mesmo local, com a extensão `.old` por segurança.**

**Veja a lista de pacotes e arquivos que serão instalados no seu sistema, e o caminho para os arquivos de configurações que serão criados para eles [Packages list](packages.list)**
**Com isso, você poderá modificar os arquivos de configurações adicionados conforme o necessário, ou retornar para os antigos que estão o extensão `.old`.**

---

## Modos de Uso
```bash
# Instalar pacotes listados em um arquivo
python3 kaliarch.py pacman utilities.txt

# Desinstalar os pacotes instalados com a lista
python3 kaliarch.py --uninstall utilities.txt

# Aplica o tema Kali-like e copia o diretório "wallpapers" do repositório para a home do usuário, e define um wallpaper do Kalilinux.
python3 kaliarch.py --kalitheme

# Aplicar o tema Kali-like com papel de parede dinâmico
python3 kaliarch.py --kalitheme --dynamic-background 5 --randomize ~/wallpapers/

# Também pode usar a ordem padrão em vez de aleatória
python3 kaliarch.py --kalitheme --dynamic-background 5 --ordered ~/wallpapers/

# Remover todos os pacotes e arquivos de configurações instalados pelo script
python3 kaliarch.py --uninstall kalitheme
```
---

### Recomendações
- Configure a cor e transparência do terminal, se necessário.
- Altere as fontes do kitty com `kitty + list-fonts`.
- Configure o zsh como shell padrão.

---

## Futuras funcionalidades
- O usuário poderá passar o argumento `--uninstall-autoreplace kalitheme` para remover os pacotes e os arquivos de configuração instaldos pelo script, e subsitiuir automaticamente pelo arquivo .old dos diretórios deles.

---

## Referências
- [Zsh](https://github.com/clamy54/kali-like-zsh-theme/blob/main/README.md)
- [Temas Kitty](https://github.com/dexpota/kitty-themes)
