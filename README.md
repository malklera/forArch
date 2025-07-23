# Arch + Hyprland

Steps to copy configs from debian 12 and set up arch+hyprland


Install curl

$ sudo pacman -S --needed --noconfirm curl


Download setArch.sh script

$ curl -o setArch.sh https://raw.githubusercontent.com/malklera/forArch/refs/heads/main/setArch.sh


Make the file executable

$ chmod +x setArch.sh

Run the script

$ sudo ./setArch.sh | tee setup_log.tx


Once everything finished, reboot


If i have a working system do.

Open nvim for the first time to install all plugins

$ nvim


Open both browsers and log in for sync


See if thunar populate the default files, otherwise check to do manually

$ thunar

https://wiki.archlinux.org/title/Xdg-utils


Modify the xdg-user-dirs

$ nvim .config/user-dirs.dirs

Leave
- Documents
- Downloads
- Pictures
- Videos

Point all others to

"$HOME/"

Add my email to git

$ git config --global user.email "myEmail"

Set up github account

$ gh auth


Copy files backup from debian if i can, otherwise from drive


Create my custom IDE using tmux+neovim

Check if my scripts for tmux are executables

Install software after i have a functional system

---
Check out udiskie how and if i should do something besides installing

---
Windows
- tmux always fullscreen
- Do i set up default places for each application? or remember when it was closed?
- custom ide on workspace 1
- zen browser on workspace 2
