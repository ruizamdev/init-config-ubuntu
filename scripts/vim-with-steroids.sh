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