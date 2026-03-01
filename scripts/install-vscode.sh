#!/usr/bin/env bash

# -------------
# Script para automatizar la instalación
# de Visual Studio Code en Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Instalación de Visual Studio Code"
DESCRIPTION="Script para instalar el editor Visual Studio Code en sistemas basados en Ubuntu."
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

  print_section "Instalación del keyring de Microsoft"
  run_step "Instalando dependencias necesarias" sudo apt install -y wget gpg
  run_step "Descargando clave de Microsoft" bash -c "wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg"
  run_step "Instalando clave de Microsoft" sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
  run_step "Limpiando archivos temporales" rm -f microsoft.gpg

  print_section "Creando el fichero de fuentes para Visual Studio Code"
  run_step "Creando fichero de fuentes" sudo touch /etc/apt/sources.list.d/vscode.sources
  run_step "Escribiendo configuración de fuentes" bash -c \
    'printf "%s\n" \
    "Types: deb" \
    "URIs: https://packages.microsoft.com/repos/code" \
    "Suites: stable" \
    "Components: main" \
    "Architectures: amd64,arm64,armhf" \
    "Signed-By: /usr/share/keyrings/microsoft.gpg" \
    | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null'

  print_section "Instalando Visual Studio Code"
  run_step "Instalando apt-transport-https" sudo apt install -y apt-transport-https
  run_step "Actualizando índices de APT" sudo apt update
  run_step "Instalando Visual Studio Code" sudo apt install -y code # o code-insiders

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# Ejecuta la función principal
main "$@"
# or code-insiders
