# Arch + Hyprland

Partition current disk from prompt of arch live usb

List block devices

    $ lsblk

See which is the disk that have debian on it

Check the root filesystem for errors

    $ fsck -f /path/to/root/partition

This will dealt with any errors


How much space do i leave to debian?

Disk sizes:
    Total: 455884.8 MB, 445.2 GB
    Debian: 153600 MB, 150 GB
    Arch: 302284.8 MB, 295.2 GB


Shrink debian filesystem

00 is the integer size

    $ resize2fs /path/to/root/partition 00G

Shrink debian partition entry

    $ parted /path/to/root/partition

Check which is the partition number of debian root 

> (parted) print

Resize the partition, use the same number as on resize2fs

0 is the partition number, 00 is the size

> (parted) resizepart 0 00GB

Confirm the resize worked

> (parted) print free
> (parted) quit


Create a new partition on the free space, disk is the name of the whole disk

not a partition, is the same this i found with lsblk

    $ fdisk /disk/

- Press n (for new partition)
- Press p (for primary, or Enter for default)
- Enter the next available partition number (e.g., 3)
- Press Enter for "First sector" (to use the start of the free space)
- For "Last sector, +/-sectors or +/-size...", specify the desired size for your Arch root (e.g., +25G)
- (Leave the type as default 'Linux filesystem' (83) for now; archinstall will set Btrfs.)
- Press p (for print, so you check that the operation worked)
- Press w (to write and quit)

After that everything is ready for the actual install, use the options from installOptions.txt

    $ archinstall


After intallation, from the tty, install curl

    $ sudo pacman -S --needed --noconfirm curl


Download setArch.sh script

    $ curl -o setArch.sh https://raw.githubusercontent.com/malklera/forArch/refs/heads/main/setArch.sh


Make the file executable

    $ chmod +x setArch.sh

Run the script

    $ sudo ./setArch.sh | tee setup_log.txt


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
