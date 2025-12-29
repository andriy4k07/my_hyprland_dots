# ⚠️ WARNING

**THIS REPOSITORY AND THE `install.sh` SCRIPT ARE STILL UNDER ACTIVE DEVELOPMENT AND TESTING. THE AUTHOR ASSUMES NO LIABILITY FOR POTENTIAL BREAKAGES OR DATA LOSS. USE AT YOUR OWN RISK. AUTOMATED DOTFILES INSTALLATION IS **NOT** RECOMMENDED.**

---

## About

**my_hyprland_dots** is a collection of personal configuration files (“dotfiles”) for Arch Linux Wayland utilities, including:

- **Hyprland** (compositor)
- **Waybar** (status bar)
- **Rofi** (application launcher)
- **Starship** (shell prompt)
- **Swaylock** (screen locker)
- **Mako** (notification daemon)
- **Cava** (audio visualizer)
- **Kitty** (terminal emulator)
- **Neofetch** (system info)

These files live in the `config/` directory and can be symlinked or copied into your `~/.config/`.

## Manual Package Installation

If you prefer to set up your system manually instead of using `install.sh`, install the following groups of packages via `pacman`: 

### Base & Development
```
amd-ucode base git base-devel rust starship
```

### Display & Compositor
```
hyprland hyprpicker waybar wlsunset xorg-server-xephyr xorg-xhost sddm refind qt6-virtualkeyboard
```

### Networking & Bluetooth
```
inetutils net-tools network-manager-applet blueman bluez-utils
```

### Utilities
```
brightnessctl btop htop cliphist evtest micro nano vim uwufetch unrar unzip
```

### Media & Graphics
```
firefox flatpak inkscape mpv viewnior swappy cava easyeffects
```

### Mesa & Vulkan Drivers (for AMD CPU/GPU)
```
mesa mesa-vdpau lib32-mesa vulkan-radeon lib32-vulkan-radeon
```

### Music & Audio
```
spotify-launcher spotifyd
```

### Gaming
```
steam
```

You will also need an AUR helper (e.g. `yay`) to install AUR packages listed below.

## AUR Packages

Install these AUR packages with your preferred helper:

```
brave-bin catppuccin-gtk-theme-mocha neofetch swaylock-effects touchegg-gce-git \
waypaper wlogout yay yay-debug
```

## Syncing Dotfiles

1. Clone this repository:
   ```bash
   git clone https://github.com/andriy4k07/my_hyprland_dots.git
   cd my_hyprland_dots
   ```
2. Manually copy or symlink each folder/file from `config/` to your `~/.config`:
   ```bash
   for item in config/*; do
     cp -r "$item" ~/.config/"
   done
   ```

Alternatively, you can use the provided `install.sh` to prompt-install packages and sync configs (at your own risk).

---

*Last updated: 29-12-2025*
