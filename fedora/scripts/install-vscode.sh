#!/usr/bin/env bash

# -------------
# Script para automatizar la instalación
# de Visual Studio Code en Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Visual Studio Code"
DESCRIPTION="Script para instalar el editor Visual Studio Code en sistemas basados en Ubuntu."
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

  print_section "Instalación del keyring de Microsoft"
  run_step "Instalando key Microsoft" install_ms_key

  print_section "Instalando Visual Studio Code"
  run_step "Actualizando cache de paquetes" sudo dnf makecache -y
  run_step "Instalando Visual Studio Code"  sudo dnf install -y code

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

install_ms_key() {
  sudo rpm --import https://packages.microsfot.com/keys/microsoft.asc
  bash -c 'cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo >/dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF'
}

# Ejecuta la función principal
main "$@"
