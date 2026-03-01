#!/usr/bin/env bash
set -euo pipefail


SCRIPTS=(
  "./scripts/install-chrome.sh"
  "./scripts/install-brave.sh"
  "./scripts/install-warp.sh"
  "./scripts/install-vscode.sh"
  "./scripts/vim-with-steroids.sh"
  "./scripts/install-nodejs.sh"
  "./scripts/install-docker.sh"
  "./scripts/install-linux-virt.sh"
# Nota: Mantener el script de OH-MY-ZSH al final, ya que cambia el shell por defecto a zsh y corta el script principal.
  "./scripts/install-oh-my-zsh.sh"
)

for script in "${SCRIPTS[@]}"; do
  [[ -f "$script" ]] || { echo "No existe: $script"; exit 1; }
  [[ -x "$script" ]] || chmod +x "$script"

  echo "==> Ejecutando $script"
  "$script"   # si falla, se detiene por set -e
  echo "==> OK: $script"
done

echo "Todo completado"