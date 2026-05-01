#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación de Docker"
DESCRIPTION="Script para instalar Docker Engine en sistemas basados en Ubuntu."
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

  print_section "Configuraciones previas"
  run_step "Instalando dnf plugins" sudo dnf install -y dnf-plugins-core
  run_step "Agregando repo" sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
  run_step "Instalando Docker Engine" sudo dnf install -y docker-ce-cli
  run_step "Instalando Docker Desktop..." install_docker
  


  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

install_docker() {
  local pkg_url="https://desktop.docker.com/linux/main/amd64/docker-desktop-x86_64.rpm?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64"
  local pkg_name="docker-desktop.rpm"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  curl -L "$pkg_url" -o "$TMP_DIR/$pkg_name"
  sudo dnf install -y "$TMP_DIR/$pkg_name"
}

# Ejecuta la función principal
main "$@"

