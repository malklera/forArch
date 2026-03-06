#!/bin/bash

# This script assumes you are running it from your home directory.

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
GIT_USERNAME="malklera"

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
pacman -S --noconfirm --needed git || log_error "Failed to install git."

# Configure Git for the original user
sudo -u "$ORIGINAL_USER" git config --global user.name "$GIT_USERNAME"
sudo -u "$ORIGINAL_USER" git config --global init.defaultBranch main

if [ ! -d "$HOME_DIR/forArch" ]; then
    sudo -u "$ORIGINAL_USER" git clone https://github.com/malklera/forArch.git "$HOME_DIR/forArch" || log_error "Failed to clone forArch"
else
    log_info "forArch repository already exists at $HOME_DIR/forArch."
fi

install_pacman "$HOME_DIR/forArch/install.md"
install_pacman "$HOME_DIR/forArch/hyprland.md"

systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."
systemctl enable cronie.service
systemctl start cronie.service

log_info "Configuring auto-login for $ORIGINAL_USER on tty1..."
AUTOLOGIN_DIR="/etc/systemd/system/getty@tty1.service.d"
mkdir -p "$AUTOLOGIN_DIR" || log_error "Failed to create autologin override directory."

cat > "$AUTOLOGIN_DIR/autologin.conf" << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\u' --noclear --autologin $ORIGINAL_USER %I \$TERM
EOF

systemctl daemon-reload || log_error "Failed to reload systemd daemon after autologin config."

# Change keyboard layout
log_info "Copying custom keyboard layout and setting it..."
if [ -f "$HOME_DIR/forArch/assets/keyboard/custom" ]; then
    cp "$HOME_DIR/forArch/assets/keyboard/custom" /usr/share/X11/xkb/symbols/ || log_error "Failed to copy custom keyboard layout."
    log_success "Custom keyboard layout copied."
else
    log_error "$HOME_DIR/forArch/assets/keyboard/custom not found. Keyboard layout not changed."
fi

log_success "Arch Linux setup script completed!"

chmod +x "$HOME_DIR/forArch/nonRootConfig.sh"
sudo -u "$ORIGINAL_USER" bash "$HOME_DIR/forArch/nonRootConfig.sh"
