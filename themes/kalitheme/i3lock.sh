#!/usr/bin/env bash

# Configurações
IMG="/tmp/lock.png"
BLUR_INTENSITY="0x8"
FONT_SIZE_DATE=36
FONT_SIZE_TIME=72

# Limpar arquivos temporários
rm -f "$IMG" "/tmp/lock_"*.png 2>/dev/null

# 1. Capturar tela
if ! scrot -q 100 "$IMG"; then
    echo "Erro: Falha ao capturar tela" >&2
    exit 1
fi

# 2. Verificar ImageMagick
if command -v magick >/dev/null; then
    IM_CMD="magick"
elif command -v convert >/dev/null; then
    IM_CMD="convert"
else
    echo "Erro: ImageMagick não instalado" >&2
    exit 1
fi

# 3. Aplicar blur
if ! $IM_CMD "$IMG" -blur "$BLUR_INTENSITY" "$IMG"; then
    echo "Erro: Falha ao aplicar blur" >&2
    exit 1
fi

# 4. Adicionar data/hora
DATE=$(date '+%d/%m/%Y')
TIME=$(date '+%H:%M')

# Detectar fonte de forma silenciosa
FONT=$(fc-match -f '%{family[0]}' sans 2>/dev/null || echo "Arial")

# Adicionar texto à imagem
if ! $IM_CMD "$IMG" \
  -gravity center \
  -font "$FONT" \
  -fill white \
  -pointsize $FONT_SIZE_DATE \
  -annotate +0-100 "$DATE" \
  -pointsize $FONT_SIZE_TIME \
  -annotate +0+50 "$TIME" \
  "$IMG" 2>/dev/null; then
    echo "Aviso: Falha ao adicionar texto, continuando sem texto..." >&2
fi

# 5. Bloquear tela (verificação silenciosa)
if i3lock --help 2>&1 | grep -q -- "--color"; then
    i3lock \
      -i "$IMG" \
      -n \
      -e \
      --color=000000 \
      --pass-media-keys \
      --pass-screen-keys \
      --pass-volume-keys 2>/dev/null
else
    i3lock \
      -i "$IMG" \
      -n \
      -e \
      -c 000000 2>/dev/null
fi

# Limpar
rm -f "$IMG" "/tmp/lock_"*.png 2>/dev/null