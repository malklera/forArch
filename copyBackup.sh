#!/bin/bash

# Helper Functions for Logging
log_info() {
    echo -e "\e[34m[INFO]\e[0m $1" # Blue
}

log_success() {
    echo -e "\e[32m[SUCCESS]\e[0m $1" # Green
}

log_error() {
    echo -e "\e[31m[ERROR]\e[0m $1" # Red
}

log_warning() {
    echo -e "\e[33m[WARNING]\e[0m $1" # Yellow
}

# Get the original user who invoked sudo
ORIGINAL_USER="${SUDO_USER:-$(whoami)}"

# Get the home directory of the original user
HOME_DIR=$(eval echo "~$ORIGINAL_USER")

# Set up repository
REPO="$HOME_DIR/forArch"

log_info "Starting backup process for user: $ORIGINAL_USER..."

# Create necessary directories in REPO
mkdir -p "$REPO/.config"
mkdir -p "$REPO/.tmux"
mkdir -p "$REPO/assets/keyboard"
mkdir -p "$REPO/.local/share/applications"
mkdir -p "$REPO/.config/tmux"
mkdir -p "$REPO/.config/Thunar"

backup_file() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -f "$src" ]; then
    if cp -u "$src" "$dst"; then
        log_success "Backup $name: Success"
    else
        log_error "Backup $name: Failed"
    fi
    else
        log_warning "Backup $name: Source $src not found. Skipping."
    fi
}

backup_dir() {
    local src="$1"
    local dst="$2"
    local name="$3"

    if [ -d "$src" ]; then
    if cp -ru "$src" "$dst"; then
        log_success "Backup $name: Success"
    else
        log_error "Backup $name: Failed"
    fi
    else
        log_warning "Backup $name: Source $src not found. Skipping."
    fi
}

# bash
backup_file "$HOME_DIR/.bashrc" "$REPO/" ".bashrc"
backup_file "$HOME_DIR/.bash_profile" "$REPO/" ".bash_profile"

# neovim
backup_dir "$HOME_DIR/.config/nvim/" "$REPO/.config/" "neovim"

# tmux
backup_file "$HOME_DIR/.tmux/tmux-close.sh" "$REPO/.tmux/" "tmux-close"
backup_file "$HOME_DIR/.tmux/tmux-start.sh" "$REPO/.tmux/" "tmux-start"
backup_file "$HOME_DIR/.config/tmux/tmux.conf" "$REPO/.config/tmux/" "tmux.conf"

# custom layout
backup_file "/usr/share/X11/xkb/symbols/custom" "$REPO/assets/keyboard/" "keyboard layout"

# custom compose
backup_file "$HOME_DIR/.XCompose" "$REPO/" "compose file"

# ghostty
backup_dir "$HOME_DIR/.config/ghostty" "$REPO/.config/" "ghostty"

# btop
backup_dir "$HOME_DIR/.config/btop/" "$REPO/.config/" "btop"

# hyprland
backup_dir "$HOME_DIR/.config/hypr/" "$REPO/.config/" "hyprland"

# dunst
backup_dir "$HOME_DIR/.config/dunst/" "$REPO/.config/" "dunst"

# waybar
backup_dir "$HOME_DIR/.config/waybar/" "$REPO/.config/" "waybar"

# wlogout
backup_dir "$HOME_DIR/.config/wlogout/" "$REPO/.config/" "wlogout"

# mimeapps
backup_file "$HOME_DIR/.config/mimeapps.list" "$REPO/.config/" "mimeapps"

# user-dirs
backup_file "$HOME_DIR/.config/user-dirs.dirs" "$REPO/.config/" "user-dirs.dirs"
backup_file "$HOME_DIR/.config/user-dirs.locale" "$REPO/.config/" "user-dirs.locale"

# thunar
backup_file "$HOME_DIR/.config/Thunar/uca.xml" "$REPO/.config/Thunar/" "uca.xml"

# udiskie
backup_dir "$HOME_DIR/.config/udiskie/" "$REPO/.config/" "udiskie"

# zellij
backup_dir "$HOME_DIR/.config/zellij/" "$REPO/.config/" "zellij"

# desktop files
log_info "Backing up desktop files..."
# Use a loop to handle potential absence of .desktop files without erroring
shopt -s nullglob
desktop_files=("$HOME_DIR/.local/share/applications/"*.desktop)
if [ ${#desktop_files[@]} -gt 0 ]; then
    if cp -u "${desktop_files[@]}" "$REPO/.local/share/applications/"; then
        log_success "Desktop files backup: Success"
    else
        log_error "Desktop files backup: Failed"
    fi
else
    log_warning "No .desktop files found in $HOME_DIR/.local/share/applications/"
fi
shopt -u nullglob

# rofi
backup_dir "$HOME_DIR/.config/rofi/" "$REPO/.config/" "rofi"

log_success "Backup process completed!"
