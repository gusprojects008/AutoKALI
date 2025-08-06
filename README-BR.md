# AutoKALI

## Índice
* [Sobre](#-sobre)
* [Como funciona](#como-funciona)
* [Modos de Uso](#modos-de-uso)
* [Recomendações](#recomendações)
* [Futuras funcionalidades](#futuras-funcionalidades)
* [Referências](#referências)

---

## 💡 Sobre
> Este simples script permite instalar utilitários automaticamente por meio de uma lista *.txt*, aplicar um temas customizaveis automaticamente e adicionar wallpapers de forma dinâmica conforme a preferência do usuário, e restaurar às configurações originais automaticamencaso o usuário queira.

---

## Como funciona
- O script deve ser executado dentro do diretório do repositório.
- Permite instalar pacotes listados em um arquivo `.txt` por meio do gerenciador de pacotes especificado.
- É possível remover todos os pacotes e arquivos instalados pelo script a qualquer momento.  
- O usuário pode aplicar o temas **Kali-like** por exemplo, e que podem ser customizados.  
- Também é possível configurar um **papel de parede dinâmico**, que muda automaticamente de acordo com o tempo configurado e o modo escolhido.  
- Antes de qualquer modificação, arquivos ou diretórios de configuração são **backupados** com a extensão `.old` para garantir segurança.  

⚠️ **Importante:**  
- Sempre recomendado executar apenas como usuário normal, o próprio script irá pedir a senha de *sudo* se necessário.
- Após aplicar o tema, é recomendado revisar e, se necessário, personalizar os arquivos de configuração adicionados. 
- Arquivos `.old` permitem restaurar a configuração original a qualquer momento.  

---

## Modos de Uso

```bash
# Instalar pacotes listados em um arquivo
python3 KaliArch.py --install-utilities <e.g: pacman> utilities.txt

# Desinstalar pacotes listados em um arquivo
python3 KaliArch.py --uninstall-utilities <e.g: pacman> utilities.txt

# Aplicar o tema Kali-like
python3 KaliArch.py --install-kalitheme <e.g: pacman>

# Aplicar o tema Kali-like com papel de parede dinâmico
python3 KaliArch.py --dynamic-background 5 --randomize ~/wallpapers/ <e.g: kalitheme>

# Também pode usar a ordem padrão em vez de aleatória
python3 KaliArch.py --dynamic-background 5 --ordered ~/wallpapers/ <e.g: kalitheme>

# Remover o tema Kali-like e restaurar backups
python3 KaliArch.py --uninstall-kalitheme <e.g: pacman>
```
---

## Recomendações

- Personalize o *packages.json* de *themes* ou o script se necessário, mas fique atento para seguir o padrão do script e de packages.json.
- Personalize o `~/.config/i3/config` conforme suas preferências após aplicar o tema.
- Configure a cor, tema ou transparência do terminal, se necessário.
- Ajuste as fontes do **Kitty** se necessário.
- Configure o **Zsh** como shell padrão.

---

## Referências
- [Temas Kitty](https://github.com/dexpota/kitty-themes)
