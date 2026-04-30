#!/usr/bin/env bash
# -------------
# Script para automatizar la instalación
# del terminal Warp en Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Warp Terminal"
DESCRIPTION="Script para instalar el terminal Warp y temas en sistemas Ubuntu."
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

  print_section "configuración del repositorio"
  run_step "Importando clave GPG" sudo rpm --import https://releases.warp.dev/linux/keys/warp.asc
  run_step "Agregando repo" add_repo
  run_step "Instalando" sudo dnf install -y warp-terminal
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

add_repo() {
  sudo sh -c 'cat <<EOF | sudo tee /etc/yum.repos.d/warpdotdev.repo >/dev/null
[warpdotdev]
name= warpdotdev
baseurl=https://releases.warp.dev/linux/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://releases.warp.dev/linux/keys/warp.asc
EOF'
}

# Ejecuta la función principal
main "$@"


