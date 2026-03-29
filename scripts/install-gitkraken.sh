#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de GitKraken"
DESCRIPTION="Este script instala GitKraken, un cliente de Git visual y multiplataforma, en sistemas basados en Debian/Ubuntu."
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

  print_section "Descarga e instalación de GitKraken"
  run_step "Ejecutando" install_gitkraken

  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_gitkraken() {
  local pkg_url="https://release.gitkraken.com/linux/gitkraken-amd64.deb"
  local pkg_name="gitkraken.deb"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  curl -L "$pkg_url" -o "$TMP_DIR/$pkg_name"
  sudo apt install -y "$TMP_DIR/$pkg_name"
}

# Ejecuta la función principal
main "$@"