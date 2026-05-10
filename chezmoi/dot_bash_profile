#
# ~/.bash_profile
#
# Hyprland v0.53+ recommended startup method
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec start-hyprland
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
