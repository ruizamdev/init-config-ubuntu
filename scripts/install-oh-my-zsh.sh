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
# Color definitions
# ===============================

if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"
  BLUE="$(tput setaf 4)"
  YELLOW="$(tput setaf 3)"
  GREEN="$(tput setaf 2)"
  RED="$(tput setaf 1)"
  DARK_GREY="$(tput setaf 8)"
  LIGHT_GREY="$(tput setaf 7)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  YELLOW=""
  GREEN=""
  RED=""
  DARK_GREY=""
  LIGHT_GREY=""
  RESET=""
fi

# ===============================
# Header function
# ===============================

print_header() {
  local TITLE="$1"
  local DESCRIPTION="${2:-}"
  local AUTHOR="${3:-}"
  local WIDTH

  if command -v tput >/dev/null 2>&1; then
    WIDTH=$(tput cols)
  else
    WIDTH=80
  fi

  printf "\n${BLUE}%*s${RESET}\n" "$WIDTH" "" | tr ' ' '='
  printf "${BOLD}%*s${RESET}\n" $(((${#TITLE} + WIDTH) / 2)) "$TITLE"
  if [[ -n "$DESCRIPTION" ]]; then
    printf "${DARK_GREY}%*s${RESET}\n" $(((${#DESCRIPTION} + WIDTH) / 2)) "$DESCRIPTION"
  fi
  if [[ -n "$AUTHOR" ]]; then
    printf "${DARK_GREY}%*s${RESET}\n" $(((${#AUTHOR} + WIDTH) / 2)) "$AUTHOR"
  fi
  printf "${BLUE}%*s${RESET}\n\n" "$WIDTH" "" | tr ' ' '='
}

# ===============================
# Section function
# ===============================

print_section() {
  local TEXT="$1"
  echo -e "\n${BOLD}▶  ${TEXT}${RESET}\n"
}

# ===============================
# Step function
# ===============================

run_step() {
  local label="$1"
  shift

  local log_file
  log_file="$(mktemp)"

  # Mensaje en progreso
  printf "\r${YELLOW}⏳ %s...${RESET}" "$label"

  if "$@" >"$log_file" 2>&1; then
    # Limpia la linea de progreso
    printf "\r\033[K"
    printf "${GREEN}✔  %s${RESET}\n" "$label"
    rm -f "$log_file"
    return 0
  fi

  # Error: limpia progreso, muestra detalle y corta flujo
  printf "\r\033[K"
  printf "${RED}${BOLD}✖  %s${RESET}\n" "$label"
  echo "${RED}Detalle del error:${RESET}"
  tail -n 40 "$log_file" || true
  rm -f "$log_file"
  return 1
}

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
  run_step "Instalando fuentes necesarias" fonts_install
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

fonts_install() {
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Agave.zip"
  FONT_NAME="Agave-Nerd-Font"
  INSTALL_DIR="$HOME/.local/share/fonts/$FONT_NAME"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  mkdir -p "$INSTALL_DIR"

  curl -L "$FONT_URL" -o "$TMP_DIR/font.zip"

  unzip -q "$TMP_DIR/font.zip" -d "$TMP_DIR/extracted"

  find "$TMP_DIR/extracted" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0 \
    | xargs -0 -I{} cp -f "{}" "$INSTALL_DIR/"

  fc-cache -f "$HOME/.local/share/fonts"
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

read -p "Cambia la fuente en tu terminal a Agave Nerd Font y presiona enter para continuar con la configuración de zsh..."
# Iniciar configuración del tema Powerlevel10k
# Start Powerlevel10k theme configuration
zsh
