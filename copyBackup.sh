#!/bin/bash

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" # Red
}

# Get the original user who invoked sudo
ORIGINAL_USER="$(whoami)"

# Get the home directory of the original user
HOME_DIR=$(eval echo "~$ORIGINAL_USER")

# bash
cp -u "$HOME_DIR/.bashrc" "$HOME_DIR/forArch/" || log_error "Failed to copy .bashrc."

cp -u "$HOME_DIR/.bash_profile" "$HOME_DIR/forArch/" || log_error "Failed to copy .bash_profile."

# neovim
cp -ru --parents "$HOME_DIR/.config/nvim/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy nvim."

# tmux
cp -u --parents "$HOME_DIR/.tmux/tmux-close.sh" "$HOME_DIR/forArch/.tmux/" || log_error "Failed to copy tmux-close.sh."
cp -u "$HOME_DIR/.tmux/tmux-start.sh" "$HOME_DIR/forArch/.tmux/" || log_error "Failed to copy tmux-start.sh."
cp -u --parents "$HOME_DIR/.config/tmux/tmux.conf" "$HOME_DIR/forArch/.config/tmux/" || log_error "Failed to copy tmux.conf."

# custom layout
cp -u "/usr/share/X11/xkb/symbols/custom" "$HOME_DIR/forArch/assets/keyboard/" || log_error "Failed to copy keyboard layout."

# ghostty
cp -ru "$HOME_DIR/.config/ghostty" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy ghostty."

# btop
cp -ru "$HOME_DIR/.config/btop/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy btop."

# hyprland
cp -ru "$HOME_DIR/.config/hypr/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy hypr."

# dunst
cp -ru "$HOME_DIR/.config/dunst/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy dunst."

# waybar
cp -ru "$HOME_DIR/.config/waybar/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy waybar."

# rofi
cp -ru "$HOME_DIR/.config/rofi/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy rofi."

# wlogout
cp -ru "$HOME_DIR/.config/wlogout/" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy wlogout."

# mimeapps
cp -u "$HOME_DIR/.config/mimeapps.list" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy mimeapps."

# user-dirs
cp -u "$HOME_DIR/.config/user-dirs.dirs" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy user-dirs.dirs."
cp -u "$HOME_DIR/.config/user-dirs.locale" "$HOME_DIR/forArch/.config/" || log_error "Failed to copy user-dirs.locale."
