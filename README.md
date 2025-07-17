# forArch
Steps to copy configs from debian 12 and set up arch+hyprland

Things on the main directory of the repo go to the home directory of arch

Follow this steps, leave the extras for after everything works
- installOptions
- setUp
Install all basics i need for a working arch os
Copy backup configs
- hyprland
Install each item and make sure it orks before moving foward
Ensure i can log in and log out as i want first
- software

---------
Keyboard layout
check how to add an icon to waybar so i can change it from current to next

---------
Remapping Caps Lock

You can customize the behavior of the Caps Lock key using kb_options.

To view all available options related to Caps Lock, run:

$ rg 'caps' /usr/share/X11/xkb/rules/base.lst

To swap Caps Lock and Escape:

input {
    kb_options = caps:swapescape
}

You can also find additional kb_options unrelated to Caps Lock in
/usr/share/X11/xkb/rules/base.lst

--------
Windows
Change the behaivor of the dwindle layout, make it so i have 4 windows, i do not
want to have windows i can not use
- terminals can be fullscreen, half screen, quater screen, a little smaller to
fit below the browser
- browser can be fullscren, half screen, half screen and smaller still so i can
see a video and have a terminal below
- tmux always fullscreen
- Do i set up default places for each application? or remember when it was closed?
-----
