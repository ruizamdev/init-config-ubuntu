#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Docker"
DESCRIPTION="Script para instalar Docker Engine en sistemas basados en Ubuntu."
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

  print_section "Instalación"
  run_step "Desinstalando paquetes conflictivos" bash -c 'sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)'
  run_step "Configurando repositorio de Docker" repo_config
  run_step "Instalando Docker Engine" bash -c 'sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y'
  run_step "Agregando usuario al grupo docker" bash -c 'sudo usermod -aG docker $USER'
  run_step "Habilitando servicio" sudo systemctl start docker
  run_step "Verificando instalación" sudo docker run hello-world


  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

repo_config() {
  # Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
}

# Ejecuta la función principal
main "$@"

