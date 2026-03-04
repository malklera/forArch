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

systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."

# Configure Git for the original user
sudo -u "$ORIGINAL_USER" git config --global user.name "$GIT_USERNAME"
sudo -u "$ORIGINAL_USER" git config --global init.defaultBranch main

# Get backup configs (forArch repository)
log_info "Attempting to clone 'forArch' repository..."
if sudo -u "$ORIGINAL_USER" git clone https://github.com/malklera/forArch.git "$HOME_DIR/forArch"; then
    log_success "Successfully cloned 'forArch' repository using basic HTTPS."
else
    log_error "Failed to clone 'forArch' repository using any method. Please clone it manually into $HOME_DIR/forArch."
fi

# Change keyboard layout
log_info "Copying custom keyboard layout and setting it..."
if [ -f "$HOME_DIR/forArch/assets/keyboardLayout/custom" ]; then
    cp "$HOME_DIR/forArch/assets/keyboardLayout/custom" /usr/share/xkeyboard-config-2/symbols/ || log_error "Failed to copy custom keyboard layout."
    log_success "Custom keyboard layout copied."
else
    log_error "$HOME_DIR/forArch/assets/keyboardLayout/custom not found. Keyboard layout not changed."
fi

sudo -u "$ORIGINAL_USER" git clone https://aur.archlinux.org/yay-bin.git "$HOME_DIR/yay-bin" || log_error "Failed to clone yay-bin repository."
cd "$HOME_DIR/yay-bin" || log_error "Failed to change directory to $HOME_DIR/yay-bin."
sudo -u "$ORIGINAL_USER" makepkg -si --noconfirm || log_error "Failed to install yay."
cd - || log_error "Failed to change back from yay directory."

log_info "Running yay post-installation commands as $ORIGINAL_USER..."
sudo -u "$ORIGINAL_USER" yay -Y --gendb || log_error "Failed to run yay --gendb."
sudo -u "$ORIGINAL_USER" yay -Syu --devel --noconfirm || log_error "Failed to run yay -Syu --devel."
sudo -u "$ORIGINAL_USER" yay -Y --devel --save || log_error "Failed to run yay --devel --save."

log_info "Cleaning up yay build directory..."
sudo rm -r "$HOME_DIR/yay" || log_error "Failed to remove yay build directory."
log_success "Yay installed and configured."

if [ -d "$HOME_DIR/forArch/.config/ghostty" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/ghostty/" "$HOME_DIR/.config/" || log_error "Failed to copy ghostty config directory."
    log_success "Ghostty configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/ghostty not found. Ghostty configs not copied."
fi
log_info "Note: Ghostty cannot be used directly on TTY."


if [ -d "$HOME_DIR/forArch/.config/nvim" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/nvim/" "$HOME_DIR/.config/" || log_error "Failed to copy nvim config directory."
    log_success "Neovim configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/nvim not found. Neovim configs not copied."
fi
log_info "Wait to open neovim till I am inside of hyprland."

if [ -d "$HOME_DIR/forArch/.config/btop" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/btop/" "$HOME_DIR/.config/" || log_error "Failed to copy btop config directory."
    log_success "Btop configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/btop not found. Btop configs not copied."
fi

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

log_info "Installing tpm plugin manager"
sudo -u "$ORIGINAL_USER" git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || log_error "Error cloning tpm repository."

log_info "Copy my ide desktop file"
sudo -u "$ORIGINAL_USER" mkdir "$HOME_DIR/.local/share/applications/" || log_error "Failed to create applications directory."
sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.local/share/applications/"*.desktop "$HOME_DIR/.local/share/applications/" || log_error "Error copying desktop file."
sudo -u "$ORIGINAL_USER" update-desktop-database "$HOME_DIR/.local/share/applications/" || log_error "Error updating desktop database."

log_success "Arch Linux setup script completed!"

# Copy and execute setHypr.sh
sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/setHypr.sh" "$HOME_DIR/" || log_error "Failed to copy setHypr.sh."
chmod +x setHypr.sh
./setHypr.sh
sudo -u "$ORIGINAL_USER" rm setHypr.sh

# Copy bash backup files
if [ -d "$HOME_DIR/forArch/.bashrc" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.bashrc" "$HOME_DIR/" || log_error "Failed to copy .bashrrc."
    log_success "Bash configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.bashrc not found. Bash configs not copied."
fi

log_info "Copying .bash_profile..."
if [ -f "$HOME_DIR/forArch/.bash_profile" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.bash_profile" "$HOME_DIR/" || log_error "Failed to copy .bash_profile."
    log_success ".bash_profile copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.bash_profile not found. .bash_profile not copied."
fi

# Copy Thunar backup file
log_info "Copying .uca.xml..."
if [ -f "$HOME_DIR/forArch/.config/Thunar/uca.xml" ]; then
    sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.config/Thunar/uca.xml" "$HOME_DIR/.config/Thunar/" || log_error "Failed to copy .bash_profile."
    log_success "uca.xml copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/Thunar not found. uca.xml not copied."
fi
