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
  run_step "Actualizando paquetes" sudo dnf makecache

  print_section "Instalación de utilerias de sistema"
  run_step "Instalando BTop" sudo dnf install -y btop
  run_step "Instalando GParted" sudo dnf install -y gparted
  run_step "Instalando LMSensors" sudo dnf install -y lm_sensors

  print_section "Instalación de Tweaks y Extensiones de Gnome"
  run_step "Instalando Gnome Tweaks" sudo dnf install -y gnome-tweaks
  run_step "instalación de Extensiones" install_extensions
  run_step "Instalación del runtime gnome Platform" install_gnome_platform

  print_section "Instalación de utilerias de desarrollo"
  run_step "Instalando Git" sudo dnf install -y git
  run_step "Instalando Curl" sudo dnf install -y curl
  run_step "Instalando Wget" sudo dnf install -y wget
  run_step "Instalando Unzip" sudo dnf install -y unzip
  run_step "Instalando Build-Essential" sudo dnf install -y @development-tools

  print_section "Instalación de utilerias de red"
  run_step "Instalación de Server SSH" install_ssh
  run_step "Instalando Net Tools" sudo dnf install -y net-tools
  run_step "Instalando nmap with gui" flatpak install -y flathub org.nmap.Zenmap
  run_step "Instalando dependencias para recursos compartidos" configure_shares
  # run_step "Configurando nsswitch" configure_nsswitch_winbind
  run_step "Instalando SpeedTest CLI" sudo dnf install -y speedtest-cli
  run_step "Instalando Transmission BitTorrent Client" sudo dnf install -y transmission
  run_step "Instalando Thunderbird" flatpak install fedora -y org.mozilla.Thunderbird
  run_step "Instalando filezilla" sudo dnf install -y filezilla
  run_step "Instalando FreeRDP" sudo dnf install -y freerdp
  run_step "Instalando ZeroTier" install_zt

  print_section "Instalación de utilerias de ofimática"
  run_step "Instalando Okular" sudo dnf install -y okular

  print_section "Instalación de apps multimedia"
  run_step "Instalando VLC" sudo dnf install -y vlc

  print_section "Instalación de utilerias misceláneas"
  run_step "Instalando Shutter" sudo dnf install -y shutter
  run_step "Instalando Eza" sudo dnf install -y eza
  run_step "Instalando Grc" sudo dnf install -y grc
  run_step "Instalando tree" sudo dnf install -y tree

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

configure_shares() {
  packages=(
    "samba"
    "smbclient"
    # "cifs-utils"
    # "winbind"
    # "nfs-common"
    # "libnfs-utils"
    "sshfs"
    # "avahi-daemon"
    # "libnss-mdns"
    # "gvfs-backends"
    # "gvfs-fuse"
  )

  for package in "${packages[@]}"; do
    if ! dnf --assumeno "$package" >/dev/null 2>&1; then
      sudo dnf install -y "$package"
    fi
  done

  # sudo systemctl enable --now avahi-daemon
  # sudo systemctl enable --now winbind
}

configure_nsswitch_winbind() {
  local file="/etc/nsswitch.conf"

  for campo in passwd group shadow; do
    if ! grep -Eq "^${campo}:.*\bwinbind\b" "$file"; then
      sudo sed -i "/^${campo}:/ s/$/ winbind/" "$file"
    fi
  done
}

install_flatpak() {
  sudo apt install -y flatpak
  sudo apt install gnome-software-plugin-flatpak
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

install_ssh() {
  sudo apt install -y openssh-server
  if command -v ufw >/dev/null 2>&1; then
    sudo ufw allow ssh
    sudo ufw enable
  fi
}

install_extensions() {
  sudo dnf install -y gnome-extensions-app
  sudo dnf install -y gnome-shell-extension-appindicator
  sudo dnf install -y gnome-shell-extension-dash-to-dock
}

install_gnome_platform() {
  local gnome_branch="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"
  flatpak install -y flathub "org.gnome.Platform/x86_64/${gnome_branch}"
}

# Ejecuta la función principal
main "$@"
