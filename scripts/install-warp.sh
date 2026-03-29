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

  print_section "Instalación de la app"
  run_step "Instalando Warp Terminal" install_app

  sleep 5
  
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
  if [[ ! -e "${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal" ]]; then
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


