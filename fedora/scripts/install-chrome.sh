#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Google Chrome"
DESCRIPTION="Script para instalar el navegador Google Chrome en sistemas basados en Ubuntu."
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

  print_section "Configuración de APT source e Instalación"
  run_step "Agregando repositorio" sudo dnf config-manager setopt google-chrome.enabled=1
  run_step "Instalando Google Chrome" sudo dnf install google-chrome-stable -y

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
