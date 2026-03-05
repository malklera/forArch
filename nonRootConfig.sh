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

# Configure Git for the original user
git config --global user.name "$GIT_USERNAME"
git config --global init.defaultBranch main

clone_repos "repository.md"

# check where i do actually clone the repo
yay_installed=false
if cd "$HOME_DIR/yay-bin" 2>/dev/null; then
    if makepkg -si --noconfirm; then
        cd - || log_error "Failed to change back from yay directory."

        log_info "Running yay post-installation commands as $ORIGINAL_USER..."
        if yay -Y --gendb \
            && yay -Syu --devel --noconfirm \
            && yay -Y --devel --save \
            && sudo rm -r "$HOME_DIR/yay-bin"; then
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
    install_yay "aur.md"
else
    log_warning "Skipping install_yay: yay was not successfully installed."
fi

install_flatpak "flatpak.md"

if [ -d "$HOME_DIR/forArch/.config/ghostty" ]; then
    cp -r "$HOME_DIR/forArch/.config/ghostty/" "$HOME_DIR/.config/" || log_error "Failed to copy ghostty config directory."
    log_success "Ghostty configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/ghostty not found. Ghostty configs not copied."
fi
log_info "Note: Ghostty cannot be used directly on TTY."

if [ -d "$HOME_DIR/forArch/.config/nvim" ]; then
    cp -r "$HOME_DIR/forArch/.config/nvim/" "$HOME_DIR/.config/" || log_error "Failed to copy nvim config directory."
    log_success "Neovim configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/nvim not found. Neovim configs not copied."
fi
log_info "Wait to open neovim till I am inside of hyprland."

if [ -d "$HOME_DIR/forArch/.config/btop" ]; then
    cp -r "$HOME_DIR/forArch/.config/btop/" "$HOME_DIR/.config/" || log_error "Failed to copy btop config directory."
    log_success "Btop configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/btop not found. Btop configs not copied."
fi

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

log_info "Copy my ide desktop file"
mkdir "$HOME_DIR/.local/share/applications/" || log_error "Failed to create applications directory."
cp "$HOME_DIR/forArch/.local/share/applications/"*.desktop "$HOME_DIR/.local/share/applications/" || log_error "Error copying desktop file."
update-desktop-database "$HOME_DIR/.local/share/applications/" || log_error "Error updating desktop database."

# Copy bash backup files
if [ -d "$HOME_DIR/forArch/.bashrc" ]; then
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

# Copy Thunar backup file
log_info "Copying .uca.xml..."
if [ -f "$HOME_DIR/forArch/.config/Thunar/uca.xml" ]; then
    cp "$HOME_DIR/forArch/.config/Thunar/uca.xml" "$HOME_DIR/.config/Thunar/" || log_error "Failed to copy .bash_profile."
    log_success "uca.xml copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/Thunar not found. uca.xml not copied."
fi

log_info "Starting Hyprland setup script for user: $ORIGINAL_USER..."

log_info "Copying Waybar configurations..."
if [ -d "$HOME_DIR/forArch/.config/waybar" ]; then
    cp -r "$HOME_DIR/forArch/.config/waybar" "$HOME_DIR/.config/" || log_error "Failed to copy waybar config directory."
    log_success "Waybar configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/waybar not found. Waybar configs not copied."
fi

log_info "Copying wlogout configurations..."
if [ -d "$HOME_DIR/forArch/.config/wlogout" ]; then
    cp -r "$HOME_DIR/forArch/.config/wlogout/" "$HOME_DIR/.config/" || log_error "Failed to copy wlogout config directory."
    log_success "Wlogout configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/wlogout not found. Wlogout configs not copied."
fi

log_info "Copying Rofi configurations and themes..."
if [ -d "$HOME_DIR/forArch/.config/rofi" ]; then
    cp -r "$HOME_DIR/forArch/.config/rofi/" "$HOME_DIR/.config/" || log_error "Failed to copy rofi config directory."
    log_success "Rofi configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/rofi not found. Rofi configs not copied."
fi

# Copy backup dunst config
cp -r forArch/.config/dunst "$HOME_DIR/.config/" || log_error "Failed to copy dunstrc to user config."
log_success "Dunst configurations copied for $ORIGERAL_USER."

log_info "Copying wallpaper image..."
if [ -f "$HOME_DIR/forArch/assets/wallpaper.png" ]; then
    cp "$HOME_DIR/forArch/assets/wallpaper.png" "$HOME_DIR/" || log_error "Failed to copy wallpaper.png."
    log_success "Wallpaper image copied to $HOME_DIR."
else
    log_error "$HOME_DIR/forArch/assets/wallpaper.png not found. Wallpaper not copied."
fi

# --- Copy Hyprland Configs ---
log_info "Copying Hyprland configurations..."
if [ -d "$HOME_DIR/forArch/.config/hypr" ]; then
    cp -r "$HOME_DIR/forArch/.config/hypr/" "$HOME_DIR/.config/" || log_error "Failed to copy hyprland config directory."
    log_success "Hyprland configurations copied for $ORIGINAL_USER."
else
    log_error "$HOME_DIR/forArch/.config/hypr not found. Hyprland configs not copied."
fi

log_success "Hyprland setup script completed!"
