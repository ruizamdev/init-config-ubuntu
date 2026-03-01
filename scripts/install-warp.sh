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

  # ===============================================
  # Aquí van los pasos principales del script

  print_section "Instalación de la app"
  run_step "Instalando Warp Terminal" install_app

  print_section "Instalación de temas"
  run_step "Instalando temas para Warp Terminal" install_themes
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_app() {
  ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64|arm64) ;;
  *)
    fail "Arquitectura no soportada por este script: $ARCH (usa amd64 o arm64)."
    ;;
esac

print_section "Instalando dependencias del repositorio"
sudo apt-get update
sudo apt-get install -y ca-certificates curl gpg

print_section "Configurando repositorio oficial de Warp"
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL "https://releases.warp.dev/linux/keys/warp.asc" \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/warpdotdev.gpg >/dev/null

echo "deb [arch=$ARCH signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" \
  | sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null

print_section "Actualizando índices e instalando Warp"
sudo apt-get update
sudo apt-get install -y warp-terminal
}

install_themes() {
  if [[ -e "${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal" ]]; then
    mkdir -p ${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal
  fi
  cd ${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/
  if [[ -d "./themes" ]]; then
    rm -rf themes
  fi
  git clone https://github.com/warpdotdev/themes.git
}


# Ejecuta la función principal
main "$@"


