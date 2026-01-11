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
pacman -S --needed --noconfirm network-manager-applet || log_error "Failed to install network-manager-applet."
systemctl enable NetworkManager.service || log_error "Failed to enable NetworkManager.service."

# Fonts
log_info "Installing JetBrains Mono Nerd Font and Nerd Fonts Symbols..."
pacman -S --noconfirm --needed ttf-jetbrains-mono-nerd || log_error "Failed to install ttf-jetbrains-mono-nerd."
pacman -S --noconfirm --needed ttf-nerd-fonts-symbols || log_error "Failed to install ttf-nerd-fonts-symbols."
pacman -S --noconfirm --needed otf-comicshanns-nerd || log_error "Failed to install otf-comicshanns-nerd."
pacman -S --noconfirm --needed ttf-opensans || log_error "Failed to install ttf-opensans."
pacman -S --noconfirm --needed otf-codenewroman-nerd || log_error "Failed to install otf-codenewroman-nerd."
pacman -S --noconfirm --needed ttf-liberation || log_error "Failed to install ttf-liberation."
pacman -S --noconfirm --needed ttf-font-awesome || log_error "Failed to install ttf-font-awesome."
pacman -S --noconfirm --needed noto-fonts || log_error "Failed to install noto-fonts."
pacman -S --noconfirm --needed noto-fonts-cjk || log_error "Failed to install noto-fonts-cjk."
pacman -S --noconfirm --needed noto-fonts-emoji || log_error "Failed to install noto-fonts-emoji."

pacman -S --noconfirm --needed lxde-icon-theme || log_error "Failed to install lxde-icon-theme."
pacman -S --noconfirm --needed hicolor-icon-theme || log_error "Failed to install hicolor-icon-theme."
pacman -S --noconfirm --needed cosmic-icon-theme || log_error "Failed to install cosmic-icon-theme."
pacman -S --noconfirm --needed adwaita-icon-theme || log_error "Failed to install adwaita-icon-theme."


# Set up SSH
log_info "Setting up OpenSSH..."
pacman -S --needed --noconfirm openssh || log_error "Failed to install openssh."

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

# Change keyboard layout
log_info "Copying custom keyboard layout and setting it..."
if [ -f "$HOME_DIR/forArch/assets/keyboardLayout/custom" ]; then
    cp "$HOME_DIR/forArch/assets/keyboardLayout/custom" /usr/share/xkeyboard-config-2/symbols/ || log_error "Failed to copy custom keyboard layout."
    log_success "Custom keyboard layout copied."
else
    log_error "$HOME_DIR/forArch/assets/keyboardLayout/custom not found. Keyboard layout not changed."
fi

# Go
log_info "Installing Go..."
pacman -S --needed --noconfirm go || log_error "Failed to install Go."

# AUR helper (yay)
log_info "Setting up Yay (AUR helper)..."
pacman -S --needed --noconfirm base-devel || log_error "Failed to install base-devel (required for yay)."

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

log_info "Installing Neovim and its dependencies (luarocks, tree-sitter-cli)..."
pacman -S --needed --noconfirm luarocks || log_error "Failed to install luarocks."
pacman -S --needed --noconfirm tree-sitter-cli || log_error "Failed to install tree-sitter-cli."
pacman -S --needed --noconfirm neovim || log_error "Failed to install neovim."

# LSP
pacman -S --needed --noconfirm gopls || log_error "Failed to install gopls."
pacman -S --needed --noconfirm staticcheck || log_error "Failed to install staticcheck."
pacman -S --needed --noconfirm lua-language-server || log_error "Failed to install lua-language-server."
pacman -S --needed --noconfirm pyright || log_error "Failed to install pyright."
pacman -S --needed --noconfirm bash-language-server || log_error "Failed to install bash-language-server."
sudo -u "$ORIGINAL_USER" yay -S --noconfirm superhtml || log_error "Failed to install superhtml."
sudo -u "$ORIGINAL_USER" yay -S --noconfirm vscode-langservers-extracted || log_error "Failed to install vscode-langservers-extracted."
pacman -S --needed --noconfirm typescript-language-server || log_error "Failed to install typescript-language-server."
pacman -S --needed --noconfirm tailwindcss-language-server || log_error "Failed to install tailwindcss-language-server."

# Formatters
pacman -S --needed --noconfirm stylua || log_error "Failed to install stylua."
pacman -S --needed --noconfirm prettier || log_error "Failed to install prettier."
pacman -S --needed --noconfirm python-black || log_error "Failed to install python-black."

if [ -d "$HOME_DIR/forArch/.config/nvim" ]; then
    sudo -u "$ORIGINAL_USER" cp -r "$HOME_DIR/forArch/.config/nvim/" "$HOME_DIR/.config/" || log_error "Failed to copy nvim config directory."
    log_success "Neovim configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/nvim not found. Neovim configs not copied."
fi
log_info "Wait to open neovim till I am inside of hyprland."

# Default applications
log_info "Installing perl-file-mimeinfo for default applications..."
pacman -S --needed --noconfirm perl-file-mimeinfo || log_error "Failed to install perl-file-mimeinfo."

# Manage user directories
log_info "Installing xdg-user-dirs for managing user directories..."
pacman -S --needed --noconfirm xdg-user-dirs || log_error "Failed to install xdg-user-dirs."

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
pacman -S --needed --noconfirm thunar-volman || log_error "Failed to install thunar-volman."
pacman -S --needed --noconfirm thunar-archive-plugin || log_error "Failed to install thunar-archive-plugin."
pacman -S --needed --noconfirm xarchiver || log_error "Failed to install xarchiver."
pacman -S --needed --noconfirm tumbler || log_error "Failed to install tumbler."
pacman -S --needed --noconfirm gvfs || log_error "Failed to install gvfs."
pacman -S --needed --noconfirm gvfs-gphoto2 || log_error "Failed to install gvfs-gphoto2."
pacman -S --needed --noconfirm gvfs-mtp || log_error "Failed to install gvfs-mtp."

# Theme management for gtk apps
log_info "Installing nwg-look (theme manager)..."
pacman -S --needed --noconfirm nwg-look || log_error "Failed to install nwg-look."

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

log_info "Installing tpm plugin manager"
sudo -u "$ORIGINAL_USER" git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm || log_error "Error cloning tpm repository."

log_info "Copy my ide desktop file"
sudo -u "$ORIGINAL_USER" mkdir "$HOME_DIR/.local/share/applications/" || log_error "Failed to create applications directory."
sudo -u "$ORIGINAL_USER" cp "$HOME_DIR/forArch/.local/share/applications/"*.desktop "$HOME_DIR/.local/share/applications/" || log_error "Error copying desktop file."
sudo -u "$ORIGINAL_USER" update-desktop-database "$HOME_DIR/.local/share/applications/" || log_error "Error updating desktop database."

# Browsers
sudo -u "$ORIGINAL_USER" yay -S --noconfirm zen-browser-bin || log_error "Failed to install zen via Yay."
pacman -S --needed --noconfirm vivaldi || log_error "Failed to install vivaldi."
pacman -S --needed --noconfirm chromium || log_error "Failed to install chromium."

# Basics
log_info "Installing basic utilities..."
pacman -S --needed --noconfirm dysk || log_error "Failed to install dysk."
pacman -S --needed --noconfirm man || log_error "Failed to install man."
pacman -S --needed --noconfirm tldr || log_error "Failed to install tldr"
pacman -S --needed --noconfirm wget || log_error "Failed to install wget"
pacman -S --needed --noconfirm unzip || log_error "Failed to install unzip"
pacman -S --needed --noconfirm unrar-free || log_error "Failed to install unrar-free."
pacman -S --needed --noconfirm cronie || log_error "Failed to install cronie"
pacman -S --needed --noconfirm inetutils || log_error "Failed to install inetutils"
pacman -S --needed --noconfirm jq || log_error "Failed to install jq."
pacman -S --needed --noconfirm calibre-bin || log_error "Failed to install calibre-bin"
pacman -S --needed --noconfirm clamav || log_error "Failed to install clamav."
pacman -S --needed --noconfirm flatpak || log_error "Failed to install flatpak."
pacman -S --needed --noconfirm gimp || log_error "Failed to install gimp."
pacman -S --needed --noconfirm gimp-plugin-gmic || log_error "Failed to install gimp-plugin-gmic."
pacman -S --needed --noconfirm gtrash-bin || log_error "Failed to install gtrash-bin."
pacman -S --needed --noconfirm inkscape || log_error "Failed to install inkscape."
pacman -S --needed --noconfirm keepassxc || log_error "Failed to install keepassxc."
pacman -S --needed --noconfirm qalculate-qt || log_error "Failed to install qalculate-qt."
pacman -S --needed --noconfirm qbittorrent || log_error "Failed to install qbittorrent."
pacman -S --needed --noconfirm qemu-full || log_error "Failed to install qemu-full."
pacman -S --needed --noconfirm zathura || log_error "Failed to install zathura."
pacman -S --needed --noconfirm zathura-pdf-poppler || log_error "Failed to install zathura-pdf-poppler."

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
