#!/usr/bin/env bash

# -------------
# Script para automatizar la instalación
# del navegador Brave en Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Brave Browser"
DESCRIPTION="Script para instalar el navegador Brave en sistemas basados en Ubuntu."
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

  print_section "Instalando dependencias necesarias"
  run_step "Instalando curl" sudo dnf install -y curl
  
  print_section "Instalación de Brave Browser" 
  run_step "Instalando plugins dnf" sudo dnf install -y dnf-plugins-core
  run_step "Agregando el repositorio de Brave" sudo dnf config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
  run_step "Actualizando los repositorios" sudo dnf makecache
  run_step "Instalando Brave Browser" sudo dnf install -y brave-browser

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
