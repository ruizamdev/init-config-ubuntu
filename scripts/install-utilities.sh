#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Utilerias Esenciales"
DESCRIPTION="Este script instala una serie de utilerías esenciales para el entorno de desarrollo y uso general en Linux."
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

  print_section "Actualizando lista de paquetes"
  run_step "Actualizando paquetes" sudo apt update

  print_section "Instalación de utilerias de sistema"
  run_step "Instalando BashTop" sudo apt install -y bashtop
  run_step "Instalando GParted" sudo apt install -y gparted
  run_step "Instalando LMSensors" sudo apt install -y lm-sensors

  print_section "Instalación de utilerias de desarrollo"
  run_step "Instalando Git" sudo apt install -y git
  run_step "Instalando Curl" sudo apt install -y curl
  run_step "Instalando Wget" sudo apt install -y wget
  run_step "Instalando Unzip" sudo apt install -y unzip
  run_step "Instalando Build-Essential" sudo apt install -y build-essential

  print_section "Instalación de utilerias de red"
  run_step "Instalando SpeedTest CLI" sudo apt install -y speedtest-cli
  run_step "Instalando Thunderbird" sudo apt install -y thunderbird
  run_step "Instalando filezilla" sudo apt install -y filezilla
  run_step "Instalando FreeRDP" sudo apt install -y freerdp3-x11
  run_step "Instalando ZeroTier" install_zt

  print_section "Instalación de utilerias de ofimática"
  run_step "Instalando Okular" sudo apt install -y okular

  print_section "Instalación de utilerias misceláneas"
  run_step "Instalando Shutter" sudo apt install -y shutter
  run_step "Instalando Eza" sudo apt install -y eza
  run_step "Instalando Grc" sudo apt install -y grc
  run_step "Instalando tree" sudo apt install -y tree

  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_zt() {
  curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg' | gpg --import && \
if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
}

install_winbind() {
  sudo apt install -y winbind libnss-winbind
  sudo sed -i -E '/^hosts:/ { /(^|[[:space:]])wins([[:space:]]|$)/! s/$/ wins/ }' /etc/nsswitch.conf
}

# Ejecuta la función principal
main "$@"
