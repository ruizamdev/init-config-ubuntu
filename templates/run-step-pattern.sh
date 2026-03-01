#!/usr/bin/env bash
# Patron reutilizable para ejecutar pasos silenciosos con estado visual.
# - Muestra "procesando" en amarillo mientras corre un comando.
# - Si termina bien, limpia la linea y muestra OK en verde.
# - Si falla, limpia la linea, muestra FAIL en rojo, imprime el error y detiene el script.

# -------------
# Info variables
# -------------

TITLE="Titulo"
DESCRIPTION="Descripción del proceso o instalación"
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
