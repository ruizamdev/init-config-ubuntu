#!/bin/bash

# -------------
# Script para mejorar el editor de texto Vim en Ubuntu.
# -------------
# Script to enhance the Vim text editor on Ubuntu.
# -------------

# Comprobamos si el usuario tiene privilegios de sudo
# Verify if the user has sudo privileges
if ! sudo -n true 2>/dev/null; then
  sudo -v
fi

# Instalación de Vim
# Install Vim

sudo apt update
if ! command -v vim &> /dev/null; then
  echo "Vim no está instalado. Procediendo con la instalación..."
  sudo apt install vim -y
fi

# Instalación del gestor de plugins vim-plug
# Install the vim-plug plugin manager
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "Instalando vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "vim-plug ya está instalado."
fi

# Configuración básica de Vim
# Basic Vim configuration
echo "Creando archivo .vimrc con configuración básica..."
touch ~/.vimrc

cat << 'EOF' > ~/.vimrc
" ============= PLUGINS =============
call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
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
colorscheme gruvbox
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

echo "Configuración básica de Vim creada en ~/.vimrc"

# Instalación de plugins de Vim
# Install Vim plugins
echo "Instalando plugins de Vim..."
vim +PlugInstall +qall

echo "Vim se a arponeado con éxito. ¡A partir madres valedor!"