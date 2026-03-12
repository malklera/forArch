# Arch + Hyprland

`archinstall`


Download setArch.sh script

`curl -o setArch.sh https://raw.githubusercontent.com/malklera/forArch/refs/heads/main/setArch.sh`


Make the file executable

`chmod +x setArch.sh`

Run the script

`sudo ./setArch.sh`


Once everything finished, reboot


If i have a working system continue


Open nvim for the first time to install all plugins

`nvim`

Open tmux and install plugins with prefix + I (shift+i)


Set up KeepassXC

Open browsers and log in for sync


See if thunar populate the default files, otherwise check to do manually

`thunar`

https://wiki.archlinux.org/title/Xdg-utils


Open nwg-look and on Color scheme put it to prefer dark


Add my email to git

`git config --global user.email "myEmail"`


Generate SSH key pair
Write the passphrase on a piece of paper, not on the PC. Aim for 64 characters,
easy to remember. DO NOT USE SUDO

`ssh-keygen -C "$(whoami)@$(uname -n)-$(date -I)"`

Add the key to ssh agent

`ssh-add ~/.ssh/id_ed25519`

Go to

    https://github.com/settings/keys

Click on add and copy your public key with

`cat ~/.ssh/id_ed25519.pub`

Then check that it is ok

`ssh -T git@github.com`

You can see the github public keys here to compare

    https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints


Set up github account

`gh auth login`


Add a task, copy from ~/study/mutual-task/crontab.txt

`crontab -e`
