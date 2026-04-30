#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de GitHub CLI"
DESCRIPTION="Este script instala GitHub CLI (gh) en el sistema operativo Linux."
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

  print_section "Instalación"
  run_step "Agregando repositorio e Instalando GitHub CLI" install
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install() {
 curl -fsSL -o - https://cli.github.com/packages/githubcli-archive-keyring.asc | gpg --show-keys
 sudo dnf install -y dnf5-plugins 
 sudo dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
 sudo dnf install -y gh --repo gh-cli
}

# Ejecuta la función principal
main "$@"