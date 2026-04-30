#!/usr/bin/env bash
fonts_install() {
  declare -A FONTS=(
    ["AgaveNerdFont"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Agave.zip"
    ["MesloLGNerdFont"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
    ["FiraCodeNerdFont"]="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip"
  )

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  echo "$TMP_DIR"

  for font in "${!FONTS[@]}"; do
    FONT_URL="${FONTS[$font]}"
    echo "$FONT_URL"
    INSTALL_DIR="$HOME/.local/share/fonts/$font"
    echo "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$TMP_DIR/$font"
    echo "$TMP_DIR/$font"
    curl -L "$FONT_URL" -o "$TMP_DIR/$font/font.zip"
    unzip -q "$TMP_DIR/$font/font.zip" -d "$TMP_DIR/$font/extracted"
    find "$TMP_DIR/$font/extracted" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0 | xargs -0 -I{} cp -f "{}" "$INSTALL_DIR/"
    fc-cache -f "$HOME/.local/share/fonts"
  done
}

fonts_install