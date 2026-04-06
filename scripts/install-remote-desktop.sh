#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Escritorio Remoto (AnyDesk y RustDesk)"
DESCRIPTION="Este script instala y configura AnyDesk y RustDesk para acceso remoto en tu sistema. AnyDesk es una solución de escritorio remoto rápida y segura, mientras que RustDesk es una alternativa de código abierto que también ofrece acceso remoto eficiente."
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
  print_section "Actualizando repos"
  run_step "Actualizando" sudo apt update
  print_section "Instalando AnyDesk"
  run_step "Ejecutando" install_anydesk
  print_section "Instalando RustDesk"
  run_step "Ejecutando" install_rustdesk
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_anydesk() {
  sudo apt install ca-certificates curl apt-transport-https -y
  sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
  sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc

  echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

  sudo apt update
  sudo apt install anydesk -y
}

install_rustdesk() {
  local pkg_url="https://github.com/rustdesk/rustdesk/releases/download/1.4.6/rustdesk-1.4.6-x86_64.deb"
  local pkg_name="rustdesk.deb"

  TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TEMP_DIR"' EXIT

  curl -L "$pkg_url" -o "$TEMP_DIR/$pkg_name"
  sudo apt install -y "$TEMP_DIR/$pkg_name"
}
# Ejecuta la función principal
main "$@"