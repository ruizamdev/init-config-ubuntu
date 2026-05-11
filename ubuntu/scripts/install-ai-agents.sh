#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Titulo del Script"
DESCRIPTION="Descripción del script y lo que hace en general."
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

  run_step "Instalando Opencode" install_opencode
  run_step "Instalando Codex" install_codex
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_opencode() {
  curl -fsSL https://opencode.ai/install | bash
}

install_codex() {
  curl -fsSL https://chatgpt.com/codex/install.sh | sh
}

# Ejecuta la función principal
main "$@"