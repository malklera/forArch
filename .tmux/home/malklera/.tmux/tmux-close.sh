#!/usr/bin/bash

# Trigger save
~/.config/tmux/plugins/tmux-resurrect/scripts/save.sh

# Wait to ensure the save completes
sleep 3

# Confirm save file is updated
last_file="$HOME/.tmux/resurrect/last"
if [ -f "$last_file" ] && [ "$(find "$last_file" -mmin -1)" ]; then
	tmux kill-server
else
	tmux display-message "Resurrect save failed - aborting kill"
fi
