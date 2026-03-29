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
  run_step "Instalando dependencias necesarias" sudo apt install -y wget gpg
  run_step "Descargando clave de Microsoft" bash -c "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg"
  run_step "Instalando clave de Microsoft" sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
  run_step "Limpiando archivos temporales" rm -f microsoft.gpg

  print_section "Creando el fichero de fuentes para Visual Studio Code"
  run_step "Creando fichero de fuentes" sudo touch /etc/apt/sources.list.d/vscode.sources
  run_step "Escribiendo configuración de fuentes" bash -c \
    'printf "%s\n" \
    "Types: deb" \
    "URIs: https://packages.microsoft.com/repos/code" \
    "Suites: stable" \
    "Components: main" \
    "Architectures: amd64,arm64,armhf" \
    "Signed-By: /usr/share/keyrings/microsoft.gpg" \
    | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null'

  print_section "Instalando Visual Studio Code"
  run_step "Instalando apt-transport-https" sudo apt install -y apt-transport-https
  run_step "Actualizando índices de APT" sudo apt update
  run_step "Instalando Visual Studio Code" sudo apt install -y code # o code-insiders

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
# or code-insiders
