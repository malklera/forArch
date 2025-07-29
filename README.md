# Arch + Hyprland

    $ archinstall


Download setArch.sh script

    $ curl -o setArch.sh https://raw.githubusercontent.com/malklera/forArch/refs/heads/main/setArch.sh


Make the file executable

    $ chmod +x setArch.sh

Run the script

    $ sudo ./setArch.sh


Once everything finished, reboot


If i have a working system do.

Set Zsh as the default shell

    $ which zsh
    $ sudo chsh -s zsh-path-from-above


Open nvim for the first time to install all plugins

    $ nvim


Open both browsers and log in for sync


See if thunar populate the default files, otherwise check to do manually

    $ thunar

https://wiki.archlinux.org/title/Xdg-utils


Add my email to git

    $ git config --global user.email "myEmail"

Set up github account

    $ gh auth

Generate SSH key pair
Write the passphrase on a piece of paper, not on the PC. Aim for 64 characters,
easy to remember.

    sudo ssh-keygen -C "$(whoami)@$(uname -n)-$(date -I)"


Create my custom IDE using tmux+neovim

Check if my scripts for tmux are executables


Modify the xdg-user-dirs

    $ nvim .config/user-dirs.dirs

Leave
- Documents
- Downloads
- Pictures
- Videos

Point all others to

"$HOME/"


Install software after i have a functional system

---
Check out udiskie how and if i should do something besides installing

---
Windows
- tmux always fullscreen
- Do i set up default places for each application? or remember when it was closed?
- custom ide on workspace 1
- zen browser on workspace 2
