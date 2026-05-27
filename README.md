# Hellx2's Niri Shell

This Quickshell configuration is my personal implementation of a shell, it'll
evolve as I need it to, and may eventually become a fully functioning shell.
A [roadmap](#roadmap) is listed below for anyone who would like to see.

## Installation

1. Git clone this repo to your Quickshell configuration directory

    ```bash
    # Back up existing configuration if it exists (e.g. former versions)
    [ -e ~/.config/quickshell/niri_shell ] && mv ~/.config/quickshell/niri_shell{,.bkp}
    # Clone this repo
    git clone https://codeberg.org/Hellx2/niri_shell ~/.config/quickshell/niri_shell

    ## OR GLOBALLY (requires root)

    [ -e /usr/share/quickshell/niri_shell ] && mv /usr/share/quickshell/niri_shell{,.bkp}
    git clone https://codeberg.org/Hellx2/niri_shell /usr/share/quickshell/niri_shell
    ```

2. Make the `nsh` file executable and copy it to `~/.local/bin` or `/usr/local/bin`
    for ease of use

    ```bash
    chmod +x ./nsh
    # User-wide
    cp ./nsh ~/.local/bin
    # Globally
    sudo cp ./nsh /usr/local/bin
        ```
3. Add an auto-start entry in Niri

    ```kdl
    spawn-at-startup "nsh"
    ```

4. Add key-bindings for various IPC handlers to Niri.

    ```kdl
    // Example keybinds
    binds {
        // ...

        Alt+X { spawn "nsh" "ipc" "call" "appMenu" "toggle"; }
        Alt+P { spawn "nsh" "ipc" "call" "pomodoro" "toggle"; }

        // Volume keybinds are not needed, any calls to pipewire will call the OSD
        XF86MonBrightnessUp allow-when-locked=true {
            spawn "nsh" "ipc" "call" "brightness" "set" "5%+";
        }
        XF86MonBrightnessDown allow-when-locked=true {
            spawn "nsh" "ipc" "call" "brightness" "set" "5%-";
        }
        XF86AudioPause { spawn "nsh" "ipc" "call" "players" "playPause"; }
        XF86AudioPlay  { spawn "nsh" "ipc" "call" "players" "playPause"; }
        XF86AudioNext  { spawn "nsh" "ipc" "call" "players" "next"; }
        XF86AudioPrev  { spawn "nsh" "ipc" "call" "players" "prev"; }

        // ...
    }
    ```

## Roadmap

[x] Make major parts of the project modular to allow user configuration in future.
[ ] Restructure repo to include multiple configurations in subfolders
[ ] Implement a settings back-end in the project and create a QML front-end to
    allow users to pick their own settings.
[ ] Add more parts to the UI toolkit in `common/` to encourage quicker development.
[ ] Make a polkit implementation.
[ ] Make a greetd or sddm theme
[ ] Make a custom Bluetooth module
[ ] Make a disks module (i.e. to replace `udiskie`)
[ ] Make a networks module (i.e. to replace `nm-applet`)
[ ] Make a system monitor
[ ] Make a calendar module (to replace or integrate with GNOME Calendar)
[ ] Add more things to the dashboard and/or control centre
[ ] Possibly remove either the dashboard or control centre if one is unnecessary.
[ ] Make either the current app menu or a new menu have `dmenu` support.
