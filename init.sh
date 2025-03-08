#!/bin/bash
# luka.init - A CLI app for Linux
# 
# Copyright (C) 2024 rxxuzi
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

set -e

SOURCE="$(cd "$(dirname "$0")/src" && pwd)"
RES_DIR="$(cd "$(dirname "$0")/res" && pwd)"
VIMRC_PATH="$RES_DIR/.vimrc"
VIM_COLORS_DIR="$RES_DIR/scripts"
HOME_VIMRC="$HOME/.vimrc"
HOME_VIM_COLORS="$HOME/.vim/colors"
BASH_ALIASES_PATH="$SOURCE/bashrc/aliases.bash"
LUKA_BASHRC="$HOME/luka/src/bashrc/luka.bashrc"
HOME_BASHRC="$HOME/.bashrc"
ORIGINAL_BASHRC="$HOME/.bashrc.original"
FLAG_FILE="$HOME/.luka_initialized"
BIN_PATH="$HOME/luka/bin/luka"

echo "Checking if Luka has already been initialized..."

if [ -f "$FLAG_FILE" ]; then
    echo "Luka has already been initialized. To reinitialize, remove $FLAG_FILE and run init.sh again."
    exit 1
fi

echo "Installing required Python packages with pip3..."
pip3 install -r "$SOURCE/requirements.txt"

if [ ! -f "$ORIGINAL_BASHRC" ]; then
    cp "$HOME_BASHRC" "$ORIGINAL_BASHRC"
    echo "Original .bashrc has been saved to $ORIGINAL_BASHRC."
fi

if ! grep -q "source $LUKA_BASHRC" "$HOME_BASHRC"; then
    echo "source $LUKA_BASHRC" >> "$HOME_BASHRC"
    echo "Contents of luka.bashrc have been added to .bashrc."
else
    echo "luka.bashrc is already sourced in .bashrc."
fi

if [ -f "$HOME_VIMRC" ]; then
    read -p ".vimrc already exists. Do you want to overwrite it? (y/n): " overwrite_vimrc
    if [ "$overwrite_vimrc" = "y" ]; then
        cp "$VIMRC_PATH" "$HOME_VIMRC"
        echo ".vimrc has been overwritten."
    else
        echo ".vimrc was not overwritten."
    fi
else
    cp "$VIMRC_PATH" "$HOME_VIMRC"
    echo ".vimrc has been applied."
fi

if [ ! -d "$HOME_VIM_COLORS" ]; then
    mkdir -p "$HOME_VIM_COLORS"
fi
cp "$VIM_COLORS_DIR"/*.vim "$HOME_VIM_COLORS"
echo "Vim colorschemes have been copied to ~/.vim/colors."

chmod +x "$BIN_PATH"
echo "bin/luka has been made executable."

touch "$FLAG_FILE"

echo "Luka has been initialized successfully. Please restart your terminal for changes to take effect."
