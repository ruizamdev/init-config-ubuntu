#!/usr/bin/env bash
# -------------
# Script para automatizar la instalación
# del terminal Warp en Ubuntu.
# -------------

set -euo pipefail

# ===============================
# Color definitions
# ===============================

if command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"
  BLUE="$(tput setaf 4)"
  GREEN="$(tput setaf 2)"
  RED="$(tput setaf 1)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  BLUE=""
  GREEN=""
  RED=""
  RESET=""
fi

# ===============================
# Header function
# ===============================

print_header() {
  local TITLE="$1"
  local WIDTH

  if command -v tput >/dev/null 2>&1; then
    WIDTH=$(tput cols)
  else
    WIDTH=80
  fi

  printf "\n${BLUE}%*s${RESET}\n" "$WIDTH" "" | tr ' ' '='
  printf "${BOLD}%*s${RESET}\n" $(((${#TITLE} + WIDTH) / 2)) "$TITLE"
  printf "${BLUE}%*s${RESET}\n\n" "$WIDTH" "" | tr ' ' '='
}

# ===============================
# Section function
# ===============================

print_section() {
  local TEXT="$1"
  echo -e "\n${GREEN}▶ ${TEXT}${RESET}\n"
}

fail() {
  local TEXT="$1"
  echo -e "${RED}${TEXT}${RESET}" >&2
  exit 1
}

print_header "Instalación de Warp Terminal"

print_section "Verificando permisos de root"
if ! sudo -n true 2>/dev/null; then
  echo -e "${RED}Este script requiere privilegios de sudo. Por favor, ingresa tu contraseña.${RESET}"
  sudo -v
fi

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

print_section "Warp Terminal instalado correctamente. Puedes iniciarlo desde el menú de aplicaciones."
