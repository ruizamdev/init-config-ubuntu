#!/usr/bin/env bash

# -------------
# Script para automatizar la instalación
# del navegador Brave en Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Brave Browser"
DESCRIPTION="Script para instalar el navegador Brave en sistemas basados en Ubuntu."
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
  echo -e "\n${BOLD}▶ ${TEXT}${RESET}\n"
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
  run_step "Instalando curl" sudo apt install -y curl
  
  print_section "Instalación de Brave Browser" 
  run_step "Agregando keyring de Brave" sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  run_step "Agregando el repositorio de Brave" sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
  run_step "Actualizando los repositorios" sudo apt update
  run_step "Instalando Brave Browser" sudo apt install -y brave-browser

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
