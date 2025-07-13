# Start uwsm if not already in a graphical session and on TTY1
if uwsm check may-start; then
    exec uwsm start hyprland-uwsm.desktop
fi
