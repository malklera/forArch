# forArch
Steps to copy configs from debian 12 and set up arch+hyprland

Things on the main directory of the repo go to the home directory of arch

Follow this steps, leave the extras for after everything works
Install curl
$ sudo pacman -S --needed --noconfirm curl
Download setArch.sh script
$ curl -o setArch.sh 
Make the file executable
$ chmod +x setArch.sh
Run the script
$ ./setArch.sh
- installOptions
- setUp
Install some basics then go to install hyprland first part, then come back here
Copy backup configs
- hyprland
Install each item and make sure it works before moving foward
Ensure i can log in and log out as i want first
- software

---
Check out udiskie how and if i should do something besides installing

---
Keyboard layout
check how to add an icon to waybar so i can change it from current to next
Make a custom/keyboard script, put it on the waybar directory, that script will
run a cicle between custom and latam and us layouts
I not think i will really use this, see how i can hide this, or make it so i
call this from rofi and/terminal, then i will need a way of opening a terminal
with clicking with the mouse, this for when i ruin my layout

---
Windows
Change the behaivor of the dwindle layout, make it so i have 4 windows, i do not
want to have windows i can not use
- terminals can be fullscreen, half screen, quater screen, a little smaller to
fit below the browser
- browser can be fullscren, half screen, half screen and smaller still so i can
see a video and have a terminal below
- tmux always fullscreen
- Do i set up default places for each application? or remember when it was closed?
- custom ide on workspace 1
- zen browser on workspace 2
---
