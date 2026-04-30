#!/usr/bin/env bash

# -------------
# Script para mejorar el editor de texto Vim en Ubuntu.
# -------------
# Script to enhance the Vim text editor on Ubuntu.
# -------------

# -------------
# Info variables
# -------------

TITLE="Vim con Esteroides"
DESCRIPTION="Instalación y configuración de Vim con plugins esenciales para desarrollo."
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

  print_section "Instalación de Vim y gestor de plugins"
  run_step "Actualizando índices de APT" sudo apt update
  run_step "Instalando Vim" vim_install
  run_step "Instalando Vim-Plug" vim_pm_install
  run_step "Configurando Vim y plugins" vim_config


  echo -e "\n${GREEN}${BOLD}Proceso terminado correctamente.${RESET}"
}

# ================================
# Funciones adicionales
# ================================

vim_install() {
  if ! command -v vim &> /dev/null; then
    sudo apt install vim -y
  fi
}

vim_pm_install() {
  if [ ! -f ~/.vim/autoload/plug.vim ]; then
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
}

vim_config() {
  if [ -f ~/.vimrc ]; then
    cp ~/.vimrc ~/.vimrc.backup.$(date +%Y%m%d_%H%M%S)
  fi

  touch ~/.vimrc

cat << 'EOF' > ~/.vimrc
" ============= PLUGINS =============
call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" ============= CONFIGURACIÓN =============
colorscheme dracula
set background=dark
set number
set relativenumber
set tabstop=4
set shiftwidth=4
set expandtab
set ignorecase
set smartcase
set incsearch
set hlsearch

" Atajos
nnoremap <C-n> :NERDTreeToggle<CR>
nnoremap <C-p> :Files<CR>
EOF
}

# Ejecuta la función principal
main "$@"

vim +PlugInstall +qall