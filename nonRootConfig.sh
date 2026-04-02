#!/bin/bash

# This is for all operations without root

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

# Ensure this script is NOT run as root
if [[ $EUID -eq 0 ]]; then
   log_error "This script must NOT be run as root. Run it as your normal user: './nonRootConfig.sh'"
   exit 1
fi

# Current user and home directory
ORIGINAL_USER="$USER"
HOME_DIR="$HOME"

# Change to the directory where the script (and its configuration files) are located
cd "$(dirname "$0")" || exit 1

install_yay() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "File $file_path not found."
        return 1
    fi

    log_info "Installing AUR packages from $file_path..."
    while IFS= read -r line; do
        # Strip comments and trim whitespace
        local package
        package=$(echo "$line" | sed 's/#.*//' | xargs)

        # Skip if line is empty after stripping comments
        if [[ -z "$package" ]]; then
            continue
        fi

        log_info "Installing AUR package $package..."
        yay -S --noconfirm --needed "$package" || log_error "Failed to install AUR package $package"
    done < "$file_path"
}

install_flatpak() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "File $file_path not found."
        return 1
    fi

    log_info "Installing Flatpak packages from $file_path..."
    while IFS= read -r line; do
        # Strip comments and trim whitespace
        local package
        package=$(echo "$line" | sed 's/#.*//' | xargs)

        # Skip if line is empty after stripping comments
        if [[ -z "$package" ]]; then
            continue
        fi

        log_info "Installing Flatpak package $package..."
        flatpak install -y --noninteractive "$package" || log_error "Failed to install Flatpak package $package"
    done < "$file_path"
}

clone_repos() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        log_error "File $file_path not found."
        return 1
    fi

    log_info "Cloning repositories from $file_path..."
    while IFS= read -r line; do
        # Strip comments and trim whitespace
        local url
        url=$(echo "$line" | sed 's/#.*//' | xargs)

        # Skip if line is empty after stripping comments
        if [[ -z "$url" ]]; then
            continue
        fi

        # Derive the repo name from the URL (strip .git suffix if present)
        local repo_name
        repo_name=$(basename "$url" .git)

        if [ -d "$HOME_DIR/$repo_name" ]; then
            log_warning "Directory $HOME_DIR/$repo_name already exists. Skipping clone of $url."
            continue
        fi

        log_info "Cloning $url into $HOME_DIR/$repo_name..."
        git clone "$url" "$HOME_DIR/$repo_name" || log_error "Failed to clone $url"
    done < "$file_path"
}

yay_installed=false
if cd "$HOME_DIR/yay-bin" 2>/dev/null; then
    if makepkg -si --noconfirm; then
        cd - || log_error "Failed to change back from yay directory."

        log_info "Running yay post-installation commands as $ORIGINAL_USER..."
        if yay -Y --gendb \
            && yay -Syu --devel --noconfirm \
            && yay -Y --devel --save; then
            log_success "Yay installed and configured."
            yay_installed=true
        else
            log_error "Yay post-installation failed. AUR packages will be skipped."
        fi
    else
        log_error "Failed to install yay via makepkg. Skipping AUR package installation."
        cd - || true
    fi
else
    log_error "Failed to change directory to $HOME_DIR/yay-bin. Skipping AUR package installation."
fi

if $yay_installed; then
    install_yay "$HOME_DIR/forArch/aur.md"
else
    log_warning "Skipping install_yay: yay was not successfully installed."
fi

log_info "Restoring configuration files..."
mkdir -p "$HOME_DIR/.config"

log_info "Copying desktop files..."
mkdir -p "$HOME_DIR/.local/share/applications/" || log_error "Failed to create applications directory."
cp "$HOME_DIR/forArch/.local/share/applications/"*.desktop "$HOME_DIR/.local/share/applications/" || log_error "Error copying desktop file."
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME_DIR/.local/share/applications/" || log_error "Error updating desktop database."
fi

log_info "Copyin xdg-dekstop-portal..."
if [ -d "$HOME_DIR/forArch/.config/xdg-desktop-portal/" ]; then
	cp -r "$HOME_DIR/forArch/.config/xdg-desktop-portal/" "$HOME_DIR/.config/" || log_error "Failed to copy xdg-desktop-portal"
else
	log_errror "$HOME_DIR/forArch/.config/xdg-desktop-portal/ not found." 
fi

log_info "Copying wallpaper image..."
if [ -f "$HOME_DIR/forArch/assets/wallpaper.png" ]; then
    cp "$HOME_DIR/forArch/assets/wallpaper.png" "$HOME_DIR/" || log_error "Failed to copy wallpaper.png."
    log_success "Wallpaper image copied to $HOME_DIR."
else
    log_error "$HOME_DIR/forArch/assets/wallpaper.png not found. Wallpaper not copied."
fi
