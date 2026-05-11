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

log_info "Installing base dependencies..."
sudo pacman -S --noconfirm --needed git base-devel chezmoi || log_error "Failed to install base tools."

if ! command -v yay &>/dev/null; then
    log_info "Bootstrapping yay..."
    git clone https://aur.archlinux.org/yay-bin.git "$HOME_DIR/yay-bin"
    cd "$HOME_DIR/yay-bin" || exit 1
    makepkg -si --noconfirm
    cd "$HOME_DIR" || exit 1

    log_info "Configuring yay..."
    yay -Y --gendb --noconfirm
    yay -Syu --devel --noconfirm
else
    log_info "Yay is already installed."
fi

log_info "Installing aconfmgr..."
yay -S --needed --noconfirm aconfmgr-git

# if [ ! -d "$HOME_DIR/forArch" ]; then
#     git clone --branch btrfsUse --single-branch https://github.com/malklera/forArch.git "$HOME_DIR/forArch" || log_error "Failed to clone forArch"
# fi
#
# aconfmgr --config-dir="$HOME_DIR/forArch/chezmoi/private_dot_config/private_aconfmgr/" apply
#
# log_info "Applying dotfiles..."
# chezmoi init --apply malklera

if [ ! -d "$HOME_DIR/forArch" ]; then
    if ! git clone --branch btrfsUse --single-branch \
        https://github.com/malklera/forArch.git "$HOME_DIR/forArch"; then
        log_error "Failed to clone forArch"
        exit 1
    fi
fi

if ! aconfmgr --config "$HOME_DIR/forArch/chezmoi/private_dot_config/private_aconfmgr" apply; then
    log_error "Failed to apply aconfmgr"
    exit 1
fi

log_info "Applying dotfiles..."
if ! chezmoi init --apply malklera; then
    log_error "Failed to apply chezmoi"
    exit 1
fi

# NOTE: i am trying to use chezmoi templating, if it works, delete this
# mkdir -p ~/.config/chezmoi
# cat >~/.config/chezmoi/chezmoi.toml <<EOF
# sourceDir = "~/forArch/chezmoi"
# [edit]
#     command = "nvim"
#
# [diff]
#     command = "nvim"
#     args = ["-d", "{{ .Destination }}", "{{ .Target }}"]
# EOF


# I think aconfmgr track enabled services, if not, add this and one for openssh
# systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."
