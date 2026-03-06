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

# check where i do actually clone the repo
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

install_flatpak "$HOME_DIR/forArch/flatpak.md"
clone_repos "$HOME_DIR/forArch/repository.md"

log_info "Restoring configuration files..."
mkdir -p "$HOME_DIR/.config"

if command -v ghostty >/dev/null 2>&1; then
    if [ -d "$HOME_DIR/forArch/.config/ghostty" ]; then
        cp -r "$HOME_DIR/forArch/.config/ghostty/" "$HOME_DIR/.config/" || log_error "Failed to copy ghostty config directory."
        log_success "Ghostty configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/ghostty not found. Ghostty configs not copied."
    fi
    log_info "Note: Ghostty cannot be used directly on TTY."
else
    log_warning "Ghostty is not installed. Skipping its configuration."
fi

if command -v nvim >/dev/null 2>&1; then
    if [ -d "$HOME_DIR/forArch/.config/nvim" ]; then
        cp -r "$HOME_DIR/forArch/.config/nvim/" "$HOME_DIR/.config/" || log_error "Failed to copy nvim config directory."
        log_success "Neovim configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/nvim not found. Neovim configs not copied."
    fi
    log_info "Wait to open neovim till I am inside of hyprland."
else
    log_warning "Neovim is not installed. Skipping its configuration."
fi

if command -v btop >/dev/null 2>&1; then
    if [ -d "$HOME_DIR/forArch/.config/btop" ]; then
        cp -r "$HOME_DIR/forArch/.config/btop/" "$HOME_DIR/.config/" || log_error "Failed to copy btop config directory."
        log_success "Btop configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/btop not found. Btop configs not copied."
    fi
else
    log_warning "Btop is not installed. Skipping its configuration."
fi

if command -v tmux >/dev/null 2>&1; then
    if [ -d "$HOME_DIR/forArch/.tmux" ]; then
        cp -r "$HOME_DIR/forArch/.tmux/" "$HOME_DIR/" || log_error "Failed to copy .tmux directory."
        log_success ".tmux directory copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.tmux not found. .tmux configs not copied."
    fi

    if [ -d "$HOME_DIR/forArch/.config/tmux" ]; then
        cp -r "$HOME_DIR/forArch/.config/tmux/" "$HOME_DIR/.config/" || log_error "Failed to copy tmux config directory."
        log_success "tmux configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/tmux not found. tmux configs not copied."
    fi
else
    log_warning "Tmux is not installed. Skipping its configuration."
fi

log_info "Copying desktop files..."
mkdir -p "$HOME_DIR/.local/share/applications/" || log_error "Failed to create applications directory."
cp "$HOME_DIR/forArch/.local/share/applications/"*.desktop "$HOME_DIR/.local/share/applications/" || log_error "Error copying desktop file."
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME_DIR/.local/share/applications/" || log_error "Error updating desktop database."
fi

# Copy bash backup files
if [ -f "$HOME_DIR/forArch/.bashrc" ]; then
    cp "$HOME_DIR/forArch/.bashrc" "$HOME_DIR/" || log_error "Failed to copy .bashrrc."
    log_success "Bash configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.bashrc not found. Bash configs not copied."
fi

log_info "Copying .bash_profile..."
if [ -f "$HOME_DIR/forArch/.bash_profile" ]; then
    cp "$HOME_DIR/forArch/.bash_profile" "$HOME_DIR/" || log_error "Failed to copy .bash_profile."
    log_success ".bash_profile copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.bash_profile not found. .bash_profile not copied."
fi

log_info "Copying .XCompose..."
if [ -f "$HOME_DIR/forArch/.XCompose" ]; then
    cp "$HOME_DIR/forArch/.XCompose" "$HOME_DIR/" || log_error "Failed to copy .XCompose."
    log_success ".XCompose copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.XCompose not found. .XCompose not copied."
fi

# Copy Thunar backup file
if command -v thunar >/dev/null 2>&1; then
    log_info "Copying Thunar configuration..."
    if [ -f "$HOME_DIR/forArch/.config/Thunar/uca.xml" ]; then
        mkdir -p "$HOME_DIR/.config/Thunar/"
        cp "$HOME_DIR/forArch/.config/Thunar/uca.xml" "$HOME_DIR/.config/Thunar/" || log_error "Failed to copy uca.xml."
        log_success "uca.xml copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/Thunar/uca.xml not found."
    fi
else
    log_warning "Thunar is not installed. Skipping its configuration."
fi

if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    log_info "Copying user-dirs configurations..."
    if [ -f "$HOME_DIR/forArch/.config/user-dirs.dirs" ]; then
        cp "$HOME_DIR/forArch/.config/user-dirs.dirs" "$HOME_DIR/.config/user-dirs.dirs" || log_error "Failed to copy user-dirs.dirs"
    else
        log_error "$HOME_DIR/forArch/.config/user-dirs.dirs not found." 
    fi

    if [ -f "$HOME_DIR/forArch/.config/user-dirs.locale" ]; then
        cp "$HOME_DIR/forArch/.config/user-dirs.locale" "$HOME_DIR/.config/user-dirs.locale" || log_error "Failed to copy user-dirs.locale"
    else
        log_error "$HOME_DIR/forArch/.config/user-dirs.locale not found." 
    fi
else
    log_warning "xdg-user-dirs is not installed. Skipping its configuration."
fi

log_info "Copying mimeapps.list..."
if [ -f "$HOME_DIR/forArch/.config/mimeapps.list" ]; then
    cp "$HOME_DIR/forArch/.config/mimeapps.list" "$HOME_DIR/.config/" || log_error "Failed to copy mimeapps.list."
    log_success "mimeapps.list copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/mimeapps.list not found. mimeapps.list not copied."
fi

log_info "Starting Hyprland setup script for user: $ORIGINAL_USER..."

if command -v waybar >/dev/null 2>&1; then
    log_info "Copying Waybar configurations..."
    if [ -d "$HOME_DIR/forArch/.config/waybar" ]; then
        cp -r "$HOME_DIR/forArch/.config/waybar" "$HOME_DIR/.config/" || log_error "Failed to copy waybar config directory."
        log_success "Waybar configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/waybar not found."
    fi
else
    log_warning "Waybar is not installed. Skipping its configuration."
fi

if command -v wlogout >/dev/null 2>&1; then
    log_info "Copying wlogout configurations..."
    if [ -d "$HOME_DIR/forArch/.config/wlogout" ]; then
        cp -r "$HOME_DIR/forArch/.config/wlogout/" "$HOME_DIR/.config/" || log_error "Failed to copy wlogout config directory."
        log_success "Wlogout configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/wlogout not found."
    fi
else
    log_warning "wlogout is not installed. Skipping its configuration."
fi

if command -v rofi >/dev/null 2>&1; then
    log_info "Copying Rofi configurations and themes..."
    if [ -d "$HOME_DIR/forArch/.config/rofi" ]; then
        cp -r "$HOME_DIR/forArch/.config/rofi/" "$HOME_DIR/.config/" || log_error "Failed to copy rofi config directory."
        log_success "Rofi configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/rofi not found."
    fi
else
    log_warning "Rofi is not installed. Skipping its configuration."
fi

# Copy backup dunst config
if command -v dunst >/dev/null 2>&1; then
    log_info "Copying Dunst configurations..."
    if [ -d "$HOME_DIR/forArch/.config/dunst" ]; then
        cp -r "$HOME_DIR/forArch/.config/dunst" "$HOME_DIR/.config/" || log_error "Failed to copy dunstrc to user config."
        log_success "Dunst configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/dunst not found."
    fi
else
    log_warning "Dunst is not installed. Skipping its configuration."
fi

log_info "Copying wallpaper image..."
if [ -f "$HOME_DIR/forArch/assets/wallpaper.png" ]; then
    cp "$HOME_DIR/forArch/assets/wallpaper.png" "$HOME_DIR/" || log_error "Failed to copy wallpaper.png."
    log_success "Wallpaper image copied to $HOME_DIR."
else
    log_error "$HOME_DIR/forArch/assets/wallpaper.png not found. Wallpaper not copied."
fi

# --- Copy Hyprland Configs ---
if command -v hyprland >/dev/null 2>&1; then
    log_info "Copying Hyprland configurations..."
    if [ -d "$HOME_DIR/forArch/.config/hypr" ]; then
        cp -r "$HOME_DIR/forArch/.config/hypr/" "$HOME_DIR/.config/" || log_error "Failed to copy hyprland config directory."
        log_success "Hyprland configurations copied for $ORIGINAL_USER."
    else
        log_error "$HOME_DIR/forArch/.config/hypr not found."
    fi
else
    log_warning "Hyprland is not installed. Skipping its configuration."
fi

log_success "Hyprland setup script completed!"
