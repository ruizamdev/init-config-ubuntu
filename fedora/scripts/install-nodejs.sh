#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Node.js"
DESCRIPTION="Script para instalar Node.js y pnpm en sistemas basados en Ubuntu."
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

  print_section "Instalando Node.js y pnpm"
  run_step "Descargando e instalando nvm" bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash'
  run_step "Cargando nvm en el entorno actual" \. "$HOME/.nvm/nvm.sh"
  run_step "Instalando Node.js v24" nvm install 24
  run_step "Habilitando pnpm con corepack" corepack enable pnpm

  echo -e "\n${BOLD}Verificando instalación:${RESET}"
  echo "version de Node.js:"
  node -v
  echo "version de pnpm:"
  pnpm -v
  echo ""

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
