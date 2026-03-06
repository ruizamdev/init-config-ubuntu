#!/usr/bin/env bash

set -euo pipefail

# ===============================
# Shared modules
# ===============================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=../modules/run-step-ui.sh
source "$ROOT_DIR/modules/run-step-ui.sh"

echo -e "\n${YELLOW}Si tu sistema es Kubuntu, agrega esta línea: ${RED}${BOLD}emulate sh -c 'source /etc/profile'${RESET} ${YELLOW}a este fichero:${RESET}${RED}${BOLD} /etc/zsh/zprofile ${RESET}"
echo -e "\n${BLUE} Esto es para que las apps instaladas con snap se indicen correctamente en el menú de aplicaciones. ${RESET}"