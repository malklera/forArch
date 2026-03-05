#!/bin/bash

# TODO: check this, to put the themes where my config are and point to it if needed

# Copy Rofi themes to system-wide location (requires root)
if [ -f "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi" ]; then
    cp "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi" /usr/share/rofi/themes/ || log_error "Failed to copy t4-s4.rasi theme."
    log_success "Rofi theme t4-s4.rasi copied."
else
    log_error "$HOME_DIR/forArch/assets/rofi/themes/t4-s4.rasi not found. Theme not copied."
fi

if [ -f "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi" ]; then
    cp "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi" /usr/share/rofi/themes/ || log_error "Failed to copy tokyoNight.rasi theme."
    log_success "Rofi theme tokyoNight.rasi copied."
else
    log_error "$HOME_DIR/forArch/assets/rofi/themes/tokyoNight.rasi not found. Theme not copied."
fi
