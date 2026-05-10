AddPackage amd-ucode # Microcode update image for AMD CPUs
AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage btrfs-progs # Btrfs filesystem utilities
AddPackage clamav # Anti-virus toolkit for Unix
AddPackage dysk # Get information on your mounted filesystems
AddPackage efibootmgr # Linux user-space application to modify the EFI Boot Manager
AddPackage geoipupdate # Update GeoIP2 and GeoIP Legacy binary databases from MaxMind
AddPackage grub # GNU GRand Unified Bootloader (2)
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set
AddPackage man-db # A utility for reading man pages
AddPackage networkmanager # Network connection manager and user applications
AddPackage network-manager-applet # Applet for managing network connections
AddPackage ntfs-3g # NTFS filesystem driver and utilities
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
AddPackage udiskie # Removable disk automounter using udisks
AddPackage udisks2 # Daemon, tools and libraries to access and manipulate disks, storage devices and technologies
AddPackage usbutils # A collection of USB tools to query connected USB devices
AddPackage vim # Vi Improved, a highly configurable, improved version of the vi text editor
AddPackage wayland # A computer display server protocol
AddPackage zram-generator # Systemd unit generator for zram devices
AddPackage dmidecode # Desktop Management Interface table related utilities
AddPackage dosfstools # DOS filesystem utilities
AddPackage grub-btrfs # Include btrfs snapshots in GRUB boot options
AddPackage inotify-tools # inotify-tools is a C library and a set of command-line programs for Linux providing a simple interface to inotify.
AddPackage linux-lts # The LTS Linux kernel and modules
AddPackage snap-pac # Pacman hooks that use snapper to create pre/post btrfs snapshots like openSUSE's YaST
AddPackage snapper # A tool for managing BTRFS and LVM snapshots

AddPackage --foreign yay-bin # Yet another yogurt. Pacman wrapper and AUR helper written in go. Pre-compiled.
AddPackage --foreign yay-bin-debug # Detached debugging symbols for yay-bin

CopyFile /etc/default/grub # grub config, edit and use grub-mkconfig to apply
CopyFile /etc/group
CopyFile /etc/locale.conf # specify what locale to use for what
CopyFile /etc/locale.gen # uncoment spanish Argentina and english US
CreateLink /etc/localtime /usr/share/zoneinfo/America/Argentina/Buenos_Aires # set timezone
CopyFile /etc/systemd/system/getty@tty1.service.d/override.conf # Set auto-login for malklera
CopyFile /etc/systemd/zram-generator.conf # Configuration for zRAM
CopyFile /etc/systemd/system/reflector.timer.d/override.conf # timer to run reflector
CopyFile /etc/vconsole.conf # keyboard config for tty
CopyFile /etc/X11/xorg.conf.d/00-keyboard.conf # keyboard configs
CopyFile /usr/share/xkeyboard-config-2/symbols/custom # custom keymap
CopyFile /usr/local/share/kbd/keymaps/es.map.gz # more custom keymap? which is the root?
CopyFile /etc/mkinitcpio.d/linux.preset # i think i uncommented one field
CopyFile /etc/mkinitcpio.d/linux-lts.preset
CopyFile /etc/mkinitcpio.conf # i think this are config for the init boot
CopyFile /etc/pacman.conf # pacman configs
CopyFile /etc/pacman.d/mirrorlist.pacnew
CopyFile /etc/shells # list of valid shells
CopyFile /etc/subuid # This is used for rootless containers

CopyFile /etc/xdg/reflector/reflector.conf # custom command to update mirrorlist

CopyFile /etc/conf.d/snapper
CopyFile /etc/snapper/configs/root 640
CopyFile /etc/sudoers

CreateLink /etc/systemd/system/getty.target.wants/getty@tty1.service /usr/lib/systemd/system/getty@.service
CreateLink /etc/systemd/system/multi-user.target.wants/grub-btrfsd.service /usr/lib/systemd/system/grub-btrfsd.service
CreateLink /etc/systemd/system/multi-user.target.wants/NetworkManager.service /usr/lib/systemd/system/NetworkManager.service
CreateLink /etc/systemd/system/multi-user.target.wants/remote-fs.target /usr/lib/systemd/system/remote-fs.target
CreateLink /etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service /usr/lib/systemd/system/NetworkManager-wait-online.service
CreateLink /etc/systemd/system/sockets.target.wants/systemd-userdbd.socket /usr/lib/systemd/system/systemd-userdbd.socket
CreateLink /etc/systemd/system/sysinit.target.wants/systemd-resolved.service /usr/lib/systemd/system/systemd-resolved.service
CreateLink /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service /usr/lib/systemd/system/systemd-timesyncd.service
CreateLink /etc/systemd/system/timers.target.wants/reflector.timer /usr/lib/systemd/system/reflector.timer
CreateLink /etc/systemd/system/timers.target.wants/snapper-cleanup.timer /usr/lib/systemd/system/snapper-cleanup.timer
CreateLink /etc/systemd/system/timers.target.wants/snapper-timeline.timer /usr/lib/systemd/system/snapper-timeline.timer
CreateLink /etc/systemd/user/graphical-session-pre.target.wants/xdg-user-dirs.service /usr/lib/systemd/user/xdg-user-dirs.service
CreateLink /etc/systemd/user/pipewire.service.wants/wireplumber.service /usr/lib/systemd/user/wireplumber.service
CreateLink /etc/systemd/user/sockets.target.wants/p11-kit-server.socket /usr/lib/systemd/user/p11-kit-server.socket
CreateLink /etc/systemd/user/sockets.target.wants/pipewire-pulse.socket /usr/lib/systemd/user/pipewire-pulse.socket
CreateLink /etc/systemd/user/sockets.target.wants/pipewire.socket /usr/lib/systemd/user/pipewire.socket
