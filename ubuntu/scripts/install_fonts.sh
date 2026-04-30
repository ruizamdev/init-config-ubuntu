#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de fuentes"
DESCRIPTION="Script para instalar fuentes necesarias en sistemas basados en Ubuntu."
AUTHOR="Autor: Armando Ruiz <artmx@proton.me>"

set -euo pipefail

# ===============================
# Shared modules
# ===============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../modules/run-step-ui.sh
source "$ROOT_DIR/modules/run-step-ui.sh"

# ===============================
# Main function
# ===============================

main() {
  print_header "$TITLE" "$DESCRIPTION" "$AUTHOR"
  # Pide credenciales una sola vez al inicio.
  if ! sudo -n true 2>/dev/null; then
    sudo -v
  fi

  # ===============================================
  # Aquí van los pasos principales del script

  print_section "Instalando fuentes necesarias"
  run_step "Instalando fuentes necesarias" fonts_install
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

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

# Ejecuta la función principal
main "$@"