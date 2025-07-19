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

# Install Hyprland
log_info "Installing Hyprland..."
pacman -S --noconfirm hyprland || log_error "Failed to install hyprland."

# Clipboard manager
log_info "Installing wl-clip-persist (Wayland clipboard manager)..."
pacman -S --needed --noconfirm wl-clip-persist || log_error "Failed to install wl-clip-persist."

# Qt Wayland support
log_info "Installing Qt Wayland support..."
pacman -S --needed --noconfirm qt5-wayland || log_error "Failed to install qt5-wayland."
pacman -S --needed --noconfirm qt6-wayland || log_error "Failed to install qt6-wayland."

# Systemd startup (uwsm, libnewt)
log_info "Installing uwsm and libnewt for Systemd startup..."
pacman -S --needed --noconfirm uwsm || log_error "Failed to install uwsm."
pacman -S --needed --noconfirm libnewt || log_error "Failed to install libnewt."

log_info "Copying .zprofile..."
if [ -f "$HOME_DIR/forArch/.zprofile" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.zprofile" "$HOME_DIR/" || log_error "Failed to copy .zprofile."
    log_success ".zprofile copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.zprofile not found. .zprofile not copied."
fi

# Status bar (waybar)
log_info "Installing Waybar (status bar)..."
pacman -S --needed --noconfirm waybar || log_error "Failed to install waybar."

log_info "Copying Waybar configurations..."
if [ -d "$HOME_DIR/forArch/.config/waybar" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/waybar" "$HOME_DIR/.config/" || log_error "Failed to copy waybar config directory."
    log_success "Waybar configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/waybar not found. Waybar configs not copied."
fi

# Logout menu (wlogout)
log_info "Installing wlogout (logout menu) via Yay..."
sudo -u "$ORIGINAL_USER" yay -S --noconfirm wlogout || log_error "Failed to install wlogout via Yay."

log_info "Copying wlogout configurations..."
if [ -d "$HOME_DIR/forArch/.config/wlogout" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/wlogout/" "$HOME_DIR/.config/" || log_error "Failed to copy wlogout config directory."
    log_success "Wlogout configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/wlogout not found. Wlogout configs not copied."
fi

# XDG Desktop Portal
log_info "Installing xdg-desktop-portal-hyprland..."
pacman -S --needed --noconfirm xdg-desktop-portal-hyprland || log_error "Failed to install xdg-desktop-portal-hyprland."

# Audio server (pwvucontrol via Flatpak)
log_info "Installing pwvucontrol (audio server control) via Flatpak..."
sudo -u "$ORIGINAL_USER" flatpak install flathub com.saivert.pwvucontrol -y || log_error "Failed to install pwvucontrol via Flatpak."

# Authentication daemon
log_info "Installing hyprpolkitagent (authentication daemon)..."
pacman -S --noconfirm hyprpolkitagent || log_error "Failed to install hyprpolkitagent."

# App launcher (rofi)
log_info "Installing Rofi (app launcher)..."
pacman -S --needed --noconfirm rofi || log_error "Failed to install rofi."

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

# Auto mounting for usb and external devices
log_info "Installing udisks2 and udiskie for auto-mounting..."
pacman -S --needed --noconfirm udisks2 || log_error "Failed to install udisks2."
pacman -S --needed --noconfirm udiskie || log_error "Failed to install udiskie."

# Notification daemon
log_info "Installing Dunst (notification daemon) and copying configurations..."
pacman -S --needed --noconfirm dunst || log_error "Failed to install dunst."

# Copy default dunstrc from /etc to user's config
mkdir $HOME_DIR/.config/dunst/
sudo -u "$ORIGINAL_USER" cp /etc/dunst/dunstrc "$HOME_DIR/.config/dunst/dunstrc" || log_error "Failed to copy dunstrc to user config."
log_success "Dunst configurations copied for $ORIGINAL_USER."

# Wallpaper
log_info "Installing Hyprpaper (wallpaper utility)..."
pacman -S --noconfirm hyprpaper || log_error "Failed to install hyprpaper."

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
