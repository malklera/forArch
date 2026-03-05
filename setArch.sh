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

install_pacman() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "File $file_path not found."
        return 1
    fi

    log_info "Installing packages from $file_path..."
    while IFS= read -r line; do
        # Strip comments and trim whitespace
        local package
        package=$(echo "$line" | sed 's/#.*//' | xargs)
        
        # Skip if line is empty after stripping comments
        if [[ -z "$package" ]]; then
            continue
        fi

        log_info "Installing $package..."
        pacman -S --noconfirm --needed "$package" || log_error "Failed to install $package"
    done < "$file_path"
}

log_info "Starting Arch Linux setup script for user: $ORIGINAL_USER..."

# Update System Before Starting
log_info "Updating system packages..."
pacman -Syu --noconfirm || log_error "Failed to update system."

install_pacman "install.md"
install_pacman "hyprland.md"

systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."

# TODO: Do i really need this on root?

# Change keyboard layout
log_info "Copying custom keyboard layout and setting it..."
if [ -f "$HOME_DIR/forArch/assets/keyboardLayout/custom" ]; then
    cp "$HOME_DIR/forArch/assets/keyboardLayout/custom" /usr/share/xkeyboard-config-2/symbols/ || log_error "Failed to copy custom keyboard layout."
    log_success "Custom keyboard layout copied."
else
    log_error "$HOME_DIR/forArch/assets/keyboardLayout/custom not found. Keyboard layout not changed."
fi

log_success "Arch Linux setup script completed!"

chmod +x "$HOME_DIR/forArch/nonRootConfig.sh"
./forArch/nonRootConfig.sh
