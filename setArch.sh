#!/bin/bash

# This script assumes you are running it from your home directory.

#  Configuration Variables 
GIT_USERNAME="malklera"

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
   log_error "This script must be run as root. Please use 'sudo ./setArch.sh'"
   exit 1
fi

# Get the original user who invoked sudo
ORIGINAL_USER="${SUDO_USER:-$(whoami)}"
# Get the home directory of the original user
HOME_DIR=$(eval echo "~$ORIGINAL_USER")

log_info "Starting Arch Linux setup script for user: $ORIGINAL_USER..."

# Update System Before Starting
log_info "Updating system packages..."
pacman -Syu --noconfirm || log_error "Failed to update system."

# Microcode
log_info "Installing Microcode (amd-ucode)..."
pacman -S --needed --noconfirm amd-ucode || log_error "Failed to install amd-ucode."

# Network Manager
log_info "Installing and enabling NetworkManager..."
pacman -S --needed --noconfirm networkmanager || log_error "Failed to install networkmanager."
systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."

# Fonts
log_info "Installing JetBrains Mono Nerd Font and Nerd Fonts Symbols..."
pacman -S --noconfirm ttf-jetbrains-mono-nerd || log_error "Failed to install ttf-jetbrains-mono-nerd."
pacman -S --noconfirm ttf-nerd-fonts-symbols || log_error "Failed to install ttf-nerd-fonts-symbols."

# Set up SSH
log_info "Setting up OpenSSH..."
pacman -S --needed --noconfirm openssh || log_error "Failed to install openssh."

log_info "Generating SSH key pair. You will be prompted for a passphrase."
log_warning "Write the passphrase on a piece of paper, not on the PC. Aim for 64 characters, easy to remember."
# The -C flag adds a comment to the key for identification
# Run ssh-keygen as the original user
sudo -u "$ORIGINAL_USER" ssh-keygen -C "$ORIGINAL_USER@$(uname -n)-$(date -I)" || log_error "Failed to generate SSH key pair."

# Git
log_info "Installing Git and configuring global settings..."
pacman -S --needed --noconfirm git || log_error "Failed to install git."

# Configure Git for the original user
sudo -u "$ORIGINAL_USER" git config --global user.name "$GIT_USERNAME"
sudo -u "$ORIGINAL_USER" git config --global init.defaultBranch main

log_info "Installing github-cli..."
pacman -S --needed --noconfirm github-cli || log_error "Failed to install github-cli."

# Get backup configs (forArch repository)
log_info "Attempting to clone 'forArch' repository..."
if sudo -u "$ORIGINAL_USER" git clone https://github.com/malklera/forArch.git "$HOME_DIR/forArch"; then
    log_success "Successfully cloned 'forArch' repository using basic HTTPS."
else
    log_error "Failed to clone 'forArch' repository using any method. Please clone it manually into $HOME_DIR/forArch."
fi

# Shell Zsh
log_info "Installing Zsh and copying configurations..."
pacman -S --needed --noconfirm zsh || log_error "Failed to install zsh."

# Copy Zsh configurations backup
if [ -d "$HOME_DIR/forArch/.config/zsh" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.zshenv" "$HOME_DIR/" || log_error "Failed to copy .zshenv."
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/zsh/" "$HOME_DIR/.config/" || log_error "Failed to copy zsh config directory."
    log_success "Zsh configurations copied for $ORIGUAL_USER."

    # Automatically set Zsh as the default shell for the original user
    ZSH_PATH=$(which zsh)
    if [ -x "$ZSH_PATH" ]; then
        log_info "Setting Zsh as the default shell for $ORIGINAL_USER..."
        echo "You may be prompted for $ORIGINAL_USER's password to change the default shell."
        sudo -u "$ORIGINAL_USER" chsh -s "$ZSH_PATH" || log_error "Failed to set Zsh as default shell for $ORIGINAL_USER. Please run 'chsh -s $ZSH_PATH' manually."
        log_success "Zsh set as default shell for $ORIGINAL_USER. It will take effect on next login."
    else
        log_error "Could not find zsh executable at $ZSH_PATH. Cannot set as default shell automatically."
    fi
else
    log_error "$HOME_DIR/forArch/.config/zsh/ not found. Zsh configs not copied."
fi

# Change keyboard layout
log_info "Copying custom keyboard layout and setting it..."
if [ -f "$HOME_DIR/forArch/assets/keyboardLayout/custom" ]; then
    cp "$HOME_DIR/forArch/assets/keyboardLayout/custom" /usr/share/X11/xkb/symbols/ || log_error "Failed to copy custom keyboard layout."
    sudo localectl set-keymap --no-convert custom || log_error "Failed to set custom keyboard layout."
    log_success "Custom keyboard layout copied and set."
else
    log_error "$HOME_DIR/forArch/assets/keyboardLayout/custom not found. Keyboard layout not changed."
fi

# Go
log_info "Installing Go..."
pacman -S --needed --noconfirm go || log_error "Failed to install Go."

# AUR helper (yay)
log_info "Setting up Yay (AUR helper)..."
pacman -S --needed --noconfirm base-devel || log_error "Failed to install base-devel (required for yay)."

if [ -d "$HOME_DIR/yay" ]; then
    log_warning "Yay directory already exists in $HOME_DIR. Removing it to perform a clean install."
    sudo rm -rf "$HOME_DIR/yay"
fi

sudo -u "$ORIGINAL_USER" git clone https://aur.archlinux.org/yay.git "$HOME_DIR/yay" || log_error "Failed to clone yay repository."
cd "$HOME_DIR/yay" || log_error "Failed to change directory to $HOME_DIR/yay."
sudo -u "$ORIGINAL_USER" makepkg -si --noconfirm || log_error "Failed to install yay."
cd - || log_error "Failed to change back from yay directory."

log_info "Running yay post-installation commands as $ORIGINAL_USER..."
sudo -u "$ORIGINAL_USER" yay -Y --gendb || log_error "Failed to run yay --gendb."
sudo -u "$ORIGINAL_USER" yay -Syu --devel --noconfirm || log_error "Failed to run yay -Syu --devel."
sudo -u "$ORIGINAL_USER" yay -Y --devel --save || log_error "Failed to run yay --devel --save."

log_info "Cleaning up yay build directory..."
sudo rm -r "$HOME_DIR/yay" || log_error "Failed to remove yay build directory."
log_success "Yay installed and configured."

# Terminal Ghostty
log_info "Installing Ghostty terminal and copying configurations..."
pacman -S --needed --noconfirm ghostty || log_error "Failed to install ghostty."

if [ -d "$HOME_DIR/forArch/.config/ghostty" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/ghostty/" "$HOME_DIR/.config/" || log_error "Failed to copy ghostty config directory."
    log_success "Ghostty configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/ghostty not found. Ghostty configs not copied."
fi
log_info "Note: Ghostty cannot be used directly on TTY."

# Alternative to grep
log_info "Installing ripgrep..."
pacman -S --needed --noconfirm ripgrep || log_error "Failed to install ripgrep."

# Alternative to find
log_info "Installing fd (find alternative)..."
pacman -S --needed --noconfirm fd || log_error "Failed to install fd."

# Fuzzy finder
log_info "Installing fzf..."
pacman -S --needed --noconfirm fzf || log_error "Failed to install fzf."

# Text editors
log_info "Installing Vim and Neovim dependencies..."
pacman -S --needed --noconfirm vim || log_error "Failed to install vim."

log_info "Installing Neovim and its dependencies (npm, luarocks, tree-sitter-cli)..."
pacman -S --needed --noconfirm npm || log_error "Failed to install npm."
pacman -S --needed --noconfirm luarocks || log_error "Failed to install luarocks."
pacman -S --needed --noconfirm neovim || log_error "Failed to install neovim."
pacman -S --needed --noconfirm tree-sitter-cli || log_error "Failed to install tree-sitter-cli."

if [ -d "$HOME_DIR/forArch/.config/nvim" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/nvim/" "$HOME_DIR/.config/" || log_error "Failed to copy nvim config directory."
    log_success "Neovim configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/nvim not found. Neovim configs not copied."
fi
log_info "Wait to open neovim till i am inside of hyprland."

# Default applications
log_info "Installing perl-file-mimeinfo for default applications..."
pacman -S --needed --noconfirm perl-file-mimeinfo || log_error "Failed to install perl-file-mimeinfo."

# Manage user directories
log_info "Installing xdg-user-dirs for managing user directories..."
pacman -S --needed --noconfirm xdg-user-dirs || log_error "Failed to install xdg-user-dirs."

# Basics
log_info "Installing basic utilities (man, curl, wget, unzip, tldr)..."
pacman -S --needed --noconfirm man || log_error "Failed to install man."
pacman -S --needed --noconfirm tldr || log_error "Failed to install tldr"
pacman -S --needed --noconfirm wget || log_error "Failed to install wget"
pacman -S --needed --noconfirm unzip || log_error "Failed to install unzip"

# Terminal system monitoring
log_info "Installing btop and copying configurations..."
pacman -S --needed --noconfirm btop || log_error "Failed to install btop."

if [ -d "$HOME_DIR/forArch/.config/btop" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/btop/" "$HOME_DIR/.config/" || log_error "Failed to copy btop config directory."
    log_success "Btop configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/btop not found. Btop configs not copied."
fi

# File manager (GUI - Thunar)
log_info "Installing Thunar (GUI file manager)..."
pacman -S --needed --noconfirm thunar || log_error "Failed to install thunar."

# Terminal multiplexer (tmux)
log_info "Installing tmux and copying configurations..."
pacman -S --needed --noconfirm tmux || log_error "Failed to install tmux."

if [ -d "$HOME_DIR/forArch/.tmux" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.tmux/" "$HOME_DIR/" || log_error "Failed to copy .tmux directory."
    log_success ".tmux directory copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.tmux not found. .tmux configs not copied."
fi

if [ -d "$HOME_DIR/forArch/.config/tmux" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/tmux/" "$HOME_DIR/.config/" || log_error "Failed to copy tmux config directory."
    log_success "tmux configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/tmux not found. tmux configs not copied."
fi

# Information about disk
log_info "Installing dysk (disk information utility)..."
pacman -S --needed --noconfirm dysk || log_error "Failed to install dysk."

# Flatpak
log_info "Installing Flatpak..."
pacman -S --needed --noconfirm flatpak || log_error "Failed to install flatpak."

# Browsers
log_info "Installing Zen Browser via Flatpak..."
# Ensure Flatpak remote is added if not already
sudo -u "$ORIGINAL_USER" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || log_warning "Failed to add Flathub remote. Flatpak installations might fail."
sudo -u "$ORIGINAL_USER" flatpak install flathub app.zen_browser.zen -y || log_error "Failed to install Zen Browser via Flatpak."

log_info "Installing Vivaldi browser..."
pacman -S --needed --noconfirm vivaldi || log_error "Failed to install vivaldi."

# Check if Wayland is installed
log_info "Checking for Wayland installation..."
if ! pacman -Qi wayland &>/dev/null; then
    log_warning "Wayland is not installed. Installing it now..."
    pacman -S --needed --noconfirm wayland || log_error "Failed to install wayland."
    log_success "Wayland installed."
else
    log_info "Wayland is already installed."
fi

log_success "Arch Linux setup script completed!"

# Copy and execute setHypr.sh
sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/setHypr.sh/" "$HOME_DIR/" || log_error "Failed to copy setHypr.sh."
chmod +x setHypr.sh
./setHypr.sh
sudo -u "$ORIGINAL_USER" rm setHypr.sh
