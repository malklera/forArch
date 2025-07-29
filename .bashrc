# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Set locale (good practice for Bash on Arch)
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Environment Variables
export XDG_CONFIG_HOME="$HOME/.config"

export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

export EDITOR="nvim"

# History configuration for Bash
export HISTFILE="$HOME/.bash_history" # Default Bash history file
shopt -s histappend                   # Append to history file, don't overwrite


# add mason installed tools to the path, because i may want then for use from
# the command line
# export PATH="/home/malklera/.config/local/share/nvim/mason/bin:$PATH"


# Enable color support for ls and add handy aliases
# Bash uses 'shopt' for options, not setopt/unsetopt like Zsh
# You might need to adjust .dircolors path if you moved it from ~/.config/zsh
if [[ -x /usr/bin/dircolors ]]; then
    # Ensure ~/.config/zsh/.dircolors exists or fallback to default
    if [[ -r ~/.config/zsh/.dircolors ]]; then
        eval "$(dircolors -b ~/.config/zsh/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi

    alias ls='ls -F --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# General aliases
alias python="python3"
alias btop="btop -p 1"
alias mv="mv -i"
alias cp="cp -i"
alias sqlite='sqlite3 -init <(echo ".mode box")'

shopt -s autocd         # Change directories by typing just the name
shopt -s extglob        # Enables extended globbing features (pattern matching)
shopt -s nocaseglob     # Optional: makes globbing case-insensitive
shopt -s dotglob        # Optional: include dotfiles in glob results


# Git Info Function for Bash
git_info() {
  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  # Bash equivalent for removing prefixes
  local GIT_LOCATION=$(git symbolic-ref -q HEAD 2>/dev/null || git name-rev --name-only --no-undefined --always HEAD 2>/dev/null)
  # Remove "refs/heads/" or "tags/" prefix using Bash's extended pattern matching
  # This pattern matches either "refs/heads/" OR "tags/" at the beginning of the string.
  GIT_LOCATION="${GIT_LOCATION##refs/heads/}"
  GIT_LOCATION="${GIT_LOCATION##tags/}"

  # ANSI color codes for Bash
  # These are correctly defined for Bash in your original function.
  local RED=$'\e[31m'
  local CYAN=$'\e[36m'
  local MAGENTA=$'\e[35m'
  local YELLOW=$'\e[33m'
  local GREEN=$'\e[32m'
  local WHITE=$'\e[38;5;15m'
  local RESET=$'\e[0m'
# 
# 
# 󰜷󰜮
  local AHEAD="${RED}NUM${RESET}"
  local BEHIND="${CYAN}NUM${RESET}"
  local MERGING="${MAGENTA}⚡︎${RESET}"
  local UNTRACKED="${RED}●${RESET}"
  local MODIFIED="${YELLOW}●${RESET}"
  local STAGED="${GREEN}●${RESET}"

  # Initialize arrays for Bash
  local DIVERGENCES=()
  local FLAGS=()

  # Note: 2> /dev/null is often better for suppressing stderr from commands like git log
  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  # Use double brackets [[ for string comparisons in Bash for robustness
  if [[ -n "$GIT_DIR" ]] && test -r "$GIT_DIR/MERGE_HEAD"; then
    FLAGS+=( "$MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --quiet 2> /dev/null; then
    FLAGS+=( "$MODIFIED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  local GIT_INFO=()
  # GIT_INFO+=( "${WHITE}git" )
  # Check if GIT_STATUS is set and non-empty (assuming it's an external variable from somewhere else)
  # If GIT_STATUS is intended to be internal to this function, it should be set here.
  # Otherwise, this line is fine to include it if it exists.
  [ -n "$GIT_STATUS" ] && GIT_INFO+=( "$GIT_STATUS" )

  # Append array elements (Bash joins with space by default)
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${DIVERGENCES[@]}" )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${FLAGS[@]}" )

  GIT_INFO+=( "$GIT_LOCATION${RESET}" )

  # Use printf to avoid trailing newline and better control spacing if needed,
  # but echo "${GIT_INFO[@]}" is fine if spaces are desired separators.
  # For joining with single spaces, echo "${GIT_INFO[*]}" or echo "${GIT_INFO[@]}" works.
  echo "${GIT_INFO[@]}"
}

# Prompt for Bash (PS1)
# Bash uses '\[...\]' to enclose non-printing characters (like color codes)
# so that the shell can correctly calculate the prompt length.
PROMPT_COLOR_MAGENTA='\[\e[35m\]'
PROMPT_COLOR_BLUE='\[\e[34m\]'
PROMPT_COLOR_WHITE='\[\e[38;5;15m\]'
PROMPT_COLOR_RESET='\[\e[0m\]'

PS1="${PROMPT_COLOR_MAGENTA}\w/${PROMPT_COLOR_RESET} \$(git_info)\n${PROMPT_COLOR_BLUE}\$ ${PROMPT_COLOR_RESET}"
