#!/usr/bin/env bash
# Patron reutilizable para ejecutar pasos silenciosos con estado visual.
# - Muestra "procesando" en amarillo mientras corre un comando.
# - Si termina bien, limpia la linea y muestra OK en verde.
# - Si falla, limpia la linea, muestra FAIL en rojo, imprime el error y detiene el script.

# -------------
# Info variables
# -------------

TITLE="Titulo. Lorem Ipsum dolor sit amet"
DESCRIPTION="Descripción del proceso o instalación. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
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

  print_section "Ejecutando pasos principales"
  run_step "Label del proceso" function_1 # <-- comando o función
  
  # ===============================================

  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

function_1() {
  # Simula un proceso que tarda
  sleep 3
  # Para simular error, descomenta la siguiente línea:
  # return 1
}

# Ejecuta la función principal
main "$@"
