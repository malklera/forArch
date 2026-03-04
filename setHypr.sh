#!/bin/bash

# This script assumes the 'forArch' repository is cloned in your home directory.
# It is called by setArch.sh

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root. Please use 'sudo ./setHypr.sh'"
   exit 1
fi

# Get the original user who invoked sudo
ORIGINAL_USER="${SUDO_USER:-$(whoami)}"
# Get the home directory of the original user
HOME_DIR=$(eval echo "~$ORIGINAL_USER")

log_info "Starting Hyprland setup script for user: $ORIGINAL_USER..."

log_info "Copying Waybar configurations..."
if [ -d "$HOME_DIR/forArch/.config/waybar" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/waybar" "$HOME_DIR/.config/" || log_error "Failed to copy waybar config directory."
    log_success "Waybar configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/waybar not found. Waybar configs not copied."
fi

log_info "Copying wlogout configurations..."
if [ -d "$HOME_DIR/forArch/.config/wlogout" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/wlogout/" "$HOME_DIR/.config/" || log_error "Failed to copy wlogout config directory."
    log_success "Wlogout configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/wlogout not found. Wlogout configs not copied."
fi

log_info "Copying Rofi configurations and themes..."
if [ -d "$HOME_DIR/forArch/.config/rofi" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/rofi/" "$HOME_DIR/.config/" || log_error "Failed to copy rofi config directory."
    log_success "Rofi configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/rofi not found. Rofi configs not copied."
fi

# Copy Rofi themes to system-wide location (requires root)
if [ -f "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi" ]; then
    cp "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi" /usr/share/rofi/themes/ || log_error "Failed to copy t4-s4.rasi theme."
    log_success "Rofi theme t4-s4.rasi copied."
else
    log_error "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi not found. Theme not copied."
fi

if [ -f "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi" ]; then
    cp "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi" /usr/share/rofi/themes/ || log_error "Failed to copy tokyoNight.rasi theme."
    log_success "Rofi theme tokyoNight.rasi copied."
else
    log_error "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi not found. Theme not copied."
fi

# Copy backup dunst config
sudo -u "$ORIGINAL_USER" cp -r forArch/.config/dunst "$HOME_DIR/.config/" || log_error "Failed to copy dunstrc to user config."
log_success "Dunst configurations copied for $ORIGERAL_USER."

log_info "Copying wallpaper image..."
if [ -f "$HOME_DIR/forArch/assets/wallpaper.png" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/assets/wallpaper.png" "$HOME_DIR/" || log_error "Failed to copy wallpaper.png."
    log_success "Wallpaper image copied to $HOME_DIR."
else
    log_error "$HOME_DIR/forArch/assets/wallpaper.png not found. Wallpaper not copied."
fi

# --- Copy Hyprland Configs ---
log_info "Copying Hyprland configurations..."
if [ -d "$HOME_DIR/forArch/.config/hypr" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/hypr/" "$HOME_DIR/.config/" || log_error "Failed to copy hyprland config directory."
    log_success "Hyprland configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/hypr not found. Hyprland configs not copied."
fi

log_success "Hyprland setup script completed!"
