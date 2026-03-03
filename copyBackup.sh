#!/bin/bash

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" # Red
}

# Get the original user who invoked sudo
ORIGINAL_USER="$(whoami)"

# Get the home directory of the original user
HOME_DIR=$(eval echo "~$ORIGINAL_USER")

# Set up repository
REPO="$HOME_DIR/forArch"

# bash
cp -u "$HOME_DIR/.bashrc" "$REPO/" || log_error "Failed to copy .bashrc."

cp -u "$HOME_DIR/.bash_profile" "$REPO/" || log_error "Failed to copy .bash_profile."

# neovim
cp -ru "$HOME_DIR/.config/nvim/" "$REPO/.config/" || log_error "Failed to copy nvim."

# tmux
cp -u "$HOME_DIR/.tmux/tmux-close.sh" "$REPO/.tmux/" || log_error "Failed to copy tmux-close.sh."
cp -u "$HOME_DIR/.tmux/tmux-start.sh" "$REPO/.tmux/" || log_error "Failed to copy tmux-start.sh."
cp -u "$HOME_DIR/.config/tmux/tmux.conf" "$REPO/.config/tmux/" || log_error "Failed to copy tmux.conf."

# custom layout
cp -u "/usr/share/X11/xkb/symbols/custom" "$REPO/assets/keyboard/" || log_error "Failed to copy keyboard layout."

# custom compose
cp -u "$HOME_DIR/.XCompose" "$REPO/" || log_error "Failed to copy compose file."

# ghostty
cp -ru "$HOME_DIR/.config/ghostty" "$REPO/.config/" || log_error "Failed to copy ghostty."

# btop
cp -ru "$HOME_DIR/.config/btop/" "$REPO/.config/" || log_error "Failed to copy btop."

# hyprland
cp -ru "$HOME_DIR/.config/hypr/" "$REPO/.config/" || log_error "Failed to copy hypr."

# dunst
cp -ru "$HOME_DIR/.config/dunst/" "$REPO/.config/" || log_error "Failed to copy dunst."

# waybar
cp -ru "$HOME_DIR/.config/waybar/" "$REPO/.config/" || log_error "Failed to copy waybar."

# wlogout
cp -ru "$HOME_DIR/.config/wlogout/" "$REPO/.config/" || log_error "Failed to copy wlogout."

# mimeapps
cp -u "$HOME_DIR/.config/mimeapps.list" "$REPO/.config/" || log_error "Failed to copy mimeapps."

# user-dirs
cp -u "$HOME_DIR/.config/user-dirs.dirs" "$REPO/.config/" || log_error "Failed to copy user-dirs.dirs."
cp -u "$HOME_DIR/.config/user-dirs.locale" "$REPO/.config/" || log_error "Failed to copy user-dirs.locale."

# thunar
cp -u "$HOME_DIR/.config/Thunar/uca.xml" "$REPO/.config/Thunar/" || log_error "Failed to copy uca.xml."

# desktop files
cp -u "$HOME_DIR/.local/share/applications/"*.desktop "$REPO/.local/share/applications/" || log_error "Failed to copy applications files."

# rofi
cp -ru "$HOME_DIR/.config/rofi/" "$REPO/.config/" || log_error "Failed to copy rofi."
