#!/bin/bash

# -------------
# Script para automatizar la instalación
# de Oh-My-Zsh! en Ubuntu.
# -------------
# Script for automating the installation 
# of Oh-My-Zsh! on Ubuntu.
# -------------

# Comprobamos si el usuario tiene privilegios de sudo
# Verify if the user has sudo privileges
if ! sudo -n true 2>/dev/null; then
  sudo -v
fi

# Instalación de Zsh
# Install Zsh
sudo apt install zsh -y

# Cambiar el shell por defecto a Zsh
# Change the default shell to Zsh
sudo chsh -s $(which zsh) $USER

# Instalación de Oh-My-Zsh
# Install Oh-My-Zsh
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# Instalación de tema powerlevel10k
# Install powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

# Instalación de plugins útiles
# Install useful plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions

# Configuración de Oh-My-Zsh
# Configure Oh-My-Zsh
sed -i.bak '/ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
sed -i.bak '/plugins=/c\
plugins=(\
  git\
  zsh-syntax-highlighting\
  zsh-autosuggestions\
  zsh-completions\
)' ~/.zshrc

# Iniciar configuración del tema Powerlevel10k
# Start Powerlevel10k theme configuration
zsh
