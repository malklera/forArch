#!/usr/bin/zsh
# Define the configuration file path
CONFIG_FILE="$HOME/.config/tmux/tmux.conf"

# Set the name of the tmux session
SESSION_NAME="ide"

# Check if the session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
	tmux attach -t "$SESSION_NAME"
else
	# Start tmux in detached mode
	tmux new-session -d -s "$SESSION_NAME" -f "$CONFIG_FILE" 

	# Give tmux a moment to initialize
	sleep 1

	# tmux send-keys -t "$SESSION_NAME" "~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh" C-m
	# Restore the tmux session
	~/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
	sleep 1

	# Attach to the session
	tmux attach -t "$SESSION_NAME"
fi
