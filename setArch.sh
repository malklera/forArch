#!/bin/bash

log_info "Installing base dependencies..."
sudo pacman -S --noconfirm --needed git base-devel chezmoi || log_error "Failed to install base tools."

# TODO: probably will use the dotfiles repo instead of this
if [ ! -d "$HOME_DIR/forArch" ]; then
    git clone https://github.com/malklera/forArch.git "$HOME_DIR/forArch" || log_error "Failed to clone forArch"
fi

if ! command -v yay &> /dev/null; then
    log_info "Bootstrapping yay..."
    git clone https://aur.archlinux.org/yay-bin.git "$HOME_DIR/yay-bin"
    cd "$HOME_DIR/yay-bin" || exit 1
    makepkg -si --noconfirm
    cd "$HOME_DIR"
else
    log_info "Yay is already installed."
fi

log_info "Configuring yay..."
yay -Y --gendb --noconfirm
yay -Syu --devel --noconfirm

log_info "Installing aconfmgr..."
yay -S --needed --noconfirm aconfmgr-git

# TODO: check the path from chezmoi
aconfmgr --config-dir="$HOME_DIR/forArch/aconfmgr" apply

log_info "Applying dotfiles..."
chezmoi init --apply malklera


systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."
systemctl enable cronie.service || log_error "Failed to enable cronie.service."
systemctl start cronie.service || log_error "Failed to start cronie.service."

systemctl daemon-reload || log_error "Failed to reload systemd daemon after autologin config."
