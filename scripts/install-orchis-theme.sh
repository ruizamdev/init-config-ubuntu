#!/usr/bin/env bash

# -------------
# Info variables
# -------------

TITLE="Instalación del tema Orchis para KDE Plasma"
DESCRIPTION="Este script automatiza la instalación del tema Orchis para KDE Plasma en sistemas basados en Ubuntu. Incluye la descarga, instalación y configuración del tema para mejorar la apariencia de tu escritorio. Este incluye la versión GTK y Qt para una integración completa con el entorno de escritorio. Además, se instala Kvantum para mejorar la apariencia de las aplicaciones Qt."
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

  print_section "Instalando dependencias necesarias"
  run_step "Verificando que git esté instalado" check_git_isntalled
  run_step "Instalando kvantum" sudo apt install -y qt5-style-kvantum
  print_section "Instalando tema Orchis GTK"
  install_gtk_version
  print_section "Instalando tema Orchis Qt"
  install_qt_version
  print_section "Instalando tema de iconos Tela"
  install-tela-icon-theme
  run_step "Instalando latte dock" sudo apt install -y latte-dock
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

check_git_isntalled() {
  if [[! command -v git >/dev/null 2>&1 ]]; then
    sudo apt install -y git
  fi
}

install_gtk_version() {
  REPO_URL="https://github.com/vinceliuice/Orchis-theme.git"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  git clone --depth 1 "$REPO_URL" "$TMP_DIR"
  cd "$TMP_DIR"
  chmod 755 ./install.sh
  ./install.sh
}

install_qt_version() {
  REPO_URL="https://github.com/vinceliuice/Orchis-kde.git"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  git clone --depth 1 "$REPO_URL" "$TMP_DIR"
  cd "$TMP_DIR"
  chmod 755 ./install.sh
  ./install.sh
}

install-tela-icon-theme() {
  REPO_URL="https://github.com/vinceliuice/Tela-icon-theme.git"

  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT

  git clone --depth 1 "$REPO_URL" "$TMP_DIR"
  cd "$TMP_DIR"
  chmod 755 ./install.sh
  ./install.sh
}
# Ejecuta la función principal
main "$@"