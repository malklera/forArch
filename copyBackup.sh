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

# udiskie
backup_dir "$HOME_DIR/.config/udiskie/" "$REPO/.config/" "udiskie"

# xdg-portal
backup_dir "$HOME_DIR/.config/xdg-desktop-portal/" "$REPO/.config/" "xdg-desktop-portal"

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

log_success "Backup process completed!"
