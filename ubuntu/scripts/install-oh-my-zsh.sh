#!/usr/bin/env bash

# -------------
# Script para automatizar la instalación
# de Oh-My-Zsh! en Ubuntu.
# -------------
# Script for automating the installation
# of Oh-My-Zsh! on Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Oh-My-Zsh!"
DESCRIPTION="Script para instalar Oh-My-Zsh! en sistemas basados en Ubuntu. Incluye instalación de fuentes, configuración de temas y plugins."
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
  run_step "Actualizando indices de APT" sudo apt update
  run_step "Instalando dependencias necesarias" dep_install
  run_step "Instalando zsh" sudo apt install -y zsh
  run_step "Cambiando a zsh como shell por defecto" sudo chsh -s $(which zsh) $USER

  print_section "Instalación"
  run_step "Instalando Oh-My-Zsh!" omz_install

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Funciones extra

dep_install() {
  if ! command -v unzip >/dev/null 2>&1; then
  sudo apt-get install -y unzip
  fi

  if ! command -v fc-cache >/dev/null 2>&1; then
    sudo apt-get install -y fontconfig
  fi

  if ! command -v curl >/dev/null 2>&1; then
    sudo apt-get install -y curl
  fi
}

omz_install() {
  # Instalación de Oh-My-Zsh
  # Install Oh-My-Zsh
  if [ -d $HOME/.oh-my-zsh ]; then
    rm -rf $HOME/.oh-my-zsh
  fi

  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

  # Instalación de tema powerlevel10k
  # Install powerlevel10k theme
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

  # Instalación de plugins útiles
  # Install useful plugins
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions

  # Configuración de Oh-My-Zsh
  # Configure Oh-My-Zsh
  sed -i.bak '/ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
  sed -i.bak '/plugins=/c\
  plugins=(\
    git\
    zsh-syntax-highlighting\
    zsh-autosuggestions\
    zsh-completions\
  )' ~/.zshrc

}


# Ejecuta la función principal
main "$@"

echo -e "\n${YELLOW}Si tu sistema es Kubuntu, agrega esta línea: ${RED}${BOLD}emulate sh -c 'source /etc/profile'${RESET} ${YELLOW}a este fichero:${RESET}${RED}${BOLD} /etc/zsh/zprofile ${RESET}"
echo -e "\n${BLUE} Esto es para que las apps instaladas con snap se indicen correctamente en el menú de aplicaciones. ${RESET}"

read -p "Cambia la fuente en tu terminal a Agave Nerd Font y presiona enter para continuar con la configuración de zsh..."
# Iniciar configuración del tema Powerlevel10k
# Start Powerlevel10k theme configuration
# zsh
