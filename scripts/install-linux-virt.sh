#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Virtualización en Linux (KVM/QEMU)"
DESCRIPTION="Este script instala y configura las herramientas necesarias para la virtualización en Linux utilizando KVM y QEMU. Incluye la instalación de virt-manager para una gestión gráfica de las máquinas virtuales."
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

  print_section "instalación de paquetes necesarios"
  run_step "Instalando paquetes de virtualización" install
  
  print_section "Configurando permisos"
  run_step "Agregando usuario a grupos de virtualización" add_user
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install() {
  sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
}

add_user() {
  sudo usermod -aG libvirt $USER
  sudo usermod -aG kvm $USER
}

# Ejecuta la función principal
main "$@"
