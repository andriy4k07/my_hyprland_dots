# ⚠️ WARNING

**THIS REPOSITORY AND THE `install.sh` SCRIPT ARE STILL UNDER ACTIVE DEVELOPMENT AND TESTING. THE AUTHOR ASSUMES NO LIABILITY FOR POTENTIAL BREAKAGES OR DATA LOSS. USE AT YOUR OWN RISK. AUTOMATED DOTFILES INSTALLATION IS NOT RECOMMENDED.**

---

## About

**my_hyprland_dots** is a collection of personal configuration files ("dotfiles") for Arch Linux Wayland utilities, including:

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

---

## install.sh

`install.sh` is an interactive Bash script that guides you through setting up the full environment step by step. Each section is optional — you can choose to skip any part. Run it with:

```bash
chmod +x install.sh
./install.sh
```

### What it does

#### 1. Multilib repository check
Detects if `[multilib]` is enabled in `/etc/pacman.conf`. If not, offers to enable it automatically (required for 32-bit libraries like `lib32-mesa`).

#### 2. Package installation
Offers to install all package groups at once, or lets you pick each group individually:

| Group | Packages |
|---|---|
| Hyprland & Wayland | `hyprland`, `waybar`, `rofi`, `kitty`, `swww`, `mako`, `grim`, `slurp`, `sddm`, `rofimoji` and more |
| Audio & Video | `pipewire-pulse`, `wireplumber`, `easyeffects`, `mpv`, `cava`, `spotify-launcher` |
| Networking & Bluetooth | `network-manager-applet`, `blueman`, `bluez-utils`, `avahi`, `nss-mdns` |
| Utilities | `btop`, `htop`, `brightnessctl`, `cliphist`, `nemo`, `tesseract` (+ eng/ukr data), `gvfs-afc`, `dmidecode` and more |
| Base & Development | `rust`, `starship`, `devtools` |
| Social | `discord`, `telegram-desktop`, `signal-desktop` |
| Apps | `firefox`, `obsidian`, `inkscape`, `viewnior`, `flatpak`, `nextcloud-client` |
| Proton | `proton-pass-bin`, `proton-authenticator-bin`, `proton-vpn-gtk-app` |
| Fonts | `ttf-jetbrains-mono-nerd`, `noto-fonts-emoji`, `ttf-liberation` |
| Mesa & Vulkan (AMD) | `mesa`, `mesa-vdpau`, `lib32-mesa`, `vulkan-radeon`, `lib32-vulkan-radeon` and more |
| Gaming | `steam` |

#### 3. AUR packages
Installs AUR packages via `yay`. If `yay` is not found, the script offers to build and install it automatically from the AUR.

AUR packages included: `brave-bin`, `catppuccin-gtk-theme-mocha`, `neofetch`, `swaylock-effects`, `touchegg-gce-git`, `waypaper`, `wlogout`, `peaclock`, `pipes.sh`, `yay`, `yay-debug`

#### 4. asusctl
Separately prompts to install `asusctl` (ASUS laptop power/fan control utility) from the AUR.

#### 5. QEMU/KVM virtualization
Sets up a full virtualization stack:
- Installs `qemu-full`, `virt-manager`, `virt-viewer`, `libvirt`, `dnsmasq`, `bridge-utils` and more
- Loads `kvm` and `kvm_amd` kernel modules and persists them in `/etc/modules-load.d/kvm.conf`
- Adds the current user to the `libvirt` group
- Enables and starts `libvirtd`
- Starts and sets the default NAT network to autostart

> **Note:** Log out and back in after this step for group changes to take effect.

#### 6. Battery charge limit (ASUS laptops)
Sets a persistent 80% charge threshold to protect battery longevity. Creates a udev rule at `/etc/udev/rules.d/99-asus-battery-threshold.rules` and reloads udev. Requires `/sys/class/power_supply/BAT0/charge_control_end_threshold` to exist on your device.

#### 7. Wallpapers
Copies `wallpapers/wallpaper.jpg` from the repo to `~/Pictures/wallpapers/`.

#### 8. Cursor themes
Installs `Bibata-Modern-Classic` and `Bibata-Modern-Ice` cursor themes from the `themes/` directory to `/usr/share/icons/`.

#### 9. SDDM Astronaut theme
Installs the SDDM login screen theme from `themes/sddm-astronaut-theme/`, installs its fonts, configures `/etc/sddm.conf`, enables the virtual keyboard, and sets SDDM as the active display manager.

#### 10. Dotfiles sync
Copies all config directories (`hypr`, `waybar`, `rofi`, `kitty`, `mako`, `cava`, `swaylock`, `neofetch`, `starship.toml`) from `config/` to `~/.config/`. Existing directories are replaced with a clean copy.

#### 11. Starship prompt
Appends `eval "$(starship init bash)"` to `~/.bashrc` if not already present.

#### 12. Windows dual-boot (GRUB)
Installs `os-prober`, enables it in `/etc/default/grub`, and regenerates the GRUB config to detect Windows automatically.

#### 13. rEFInd boot manager
Installs `refind` and runs `refind-install`. Optionally installs the Catppuccin Mocha theme from `themes/themes/` and appends it to `refind.conf`.

#### 14. Launch Hyprland
Offers to launch Hyprland immediately after everything is done.

---

## Manual Package Installation

If you prefer to set up your system manually instead of using `install.sh`, install the following groups of packages via `pacman`:

### Base & Development
```
amd-ucode base git base-devel rust starship devtools
```

### Display & Compositor
```
hyprland hyprpicker waybar wlsunset swww grim slurp swappy
xorg-server-xephyr xorg-xhost sddm refind qt6-virtualkeyboard rofimoji
```

### Networking & Bluetooth
```
inetutils net-tools network-manager-applet blueman bluez-utils avahi nss-mdns
```

### Utilities
```
brightnessctl btop htop cliphist evtest micro nano vim unrar unzip nemo less
gvfs-afc tesseract tesseract-data-eng tesseract-data-ukr dmidecode
```

### Audio & Video
```
pipewire-pulse wireplumber easyeffects mpv cava spotify-launcher
```

### Mesa & Vulkan Drivers (AMD)
```
mesa mesa-vdpau lib32-mesa vulkan-radeon lib32-vulkan-radeon
vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools
```

### Apps
```
firefox obsidian inkscape viewnior flatpak nextcloud-client
discord telegram-desktop signal-desktop
```

### Gaming
```
steam
```

### Virtualization
```
qemu-full virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat libvirt
```

### AUR packages
Install these with `yay` or your preferred AUR helper:
```
brave-bin catppuccin-gtk-theme-mocha neofetch swaylock-effects touchegg-gce-git
waypaper wlogout peaclock pipes.sh yay yay-debug asusctl
proton-pass-bin proton-authenticator-bin proton-vpn-gtk-app
```

---

## Syncing Dotfiles

1. Clone this repository:
   ```bash
   git clone https://github.com/andriy4k07/my_hyprland_dots.git
   cd my_hyprland_dots
   ```
2. Manually copy or symlink each folder/file from `config/` to your `~/.config`:
   ```bash
   for item in config/*; do
     cp -r "$item" ~/.config/
   done
   ```

Alternatively, use the provided `install.sh` to prompt-install packages and sync configs (at your own risk).

---

*Last updated: 10-03-2026*
