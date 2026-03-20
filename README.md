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

`install.sh` is an interactive Bash script that guides you through setting up the full environment step by step. Run it with:

```bash
chmod +x install.sh
./install.sh
```

### Options

```
--noconfirm    Skip all prompts and install everything automatically.
               Both group menus and all Y/n questions are answered with yes.
               Useful for unattended installs.

--help, -h     Show usage information and exit.
```

### How it works

The script is split into two group selection menus, two separate prompts, and a final launch step.

**Menu 1 — Package groups.** A numbered list is shown and you enter which groups to **skip** (comma-separated). Press Enter to install all.

| # | Group | Packages |
|---|---|---|
| 1 | Hyprland & Wayland | `hyprland`, `hyprpicker`, `waybar`, `wlsunset`, `rofi`, `kitty`, `swww`, `mako`, `grim`, `slurp`, `swappy`, `sddm`, `rofimoji`, `xorg-server-xephyr`, `xorg-xhost`, `qt6-virtualkeyboard` |
| 2 | Audio & Video | `pipewire-pulse`, `wireplumber`, `easyeffects`, `mpv`, `cava`, `spotify-launcher` |
| 3 | Networking & Bluetooth | `inetutils`, `net-tools`, `network-manager-applet`, `blueman`, `bluez-utils`, `avahi`, `nss-mdns` |
| 4 | Utilities | `acpi`, `btop`, `htop`, `brightnessctl`, `cliphist`, `evtest`, `micro`, `nano`, `vim`, `unrar`, `unzip`, `nemo`, `less`, `gvfs-afc`, `tesseract` (+ eng/ukr data), `dmidecode` |
| 5 | Base & Development | `rust`, `starship`, `devtools` |
| 6 | Social | `discord`, `telegram-desktop`, `signal-desktop` |
| 7 | Apps | `firefox`, `obsidian`, `inkscape`, `viewnior`, `flatpak`, `nextcloud-client` |
| 8 | Proton | `proton-vpn-gtk-app` |
| 9 | Fonts | `ttf-jetbrains-mono-nerd`, `ttf-jetbrains-mono`, `ttf-dejavu`, `ttf-liberation`, `noto-fonts`, `noto-fonts-emoji`, `ttf-nerd-fonts-symbols`, `ttf-nerd-fonts-symbols-mono` |
| 10 | Mesa & Vulkan (AMD) | `mesa`, `lib32-mesa`, `vulkan-radeon`, `lib32-vulkan-radeon`, `vulkan-icd-loader`, `lib32-vulkan-icd-loader`, `libva-mesa-driver`, `lib32-libva-mesa-driver` |
| 11 | Gaming | `steam` |
| 12 | AUR packages | `brave-bin`, `catppuccin-gtk-theme-mocha`, `neofetch`, `touchegg-gce-git`, `waypaper`, `wlogout`, `yay`, `yay-debug`, `peaclock`, `pipes.sh`, `proton-pass`, `proton-authenticator-bin` |

If `yay` is not found, the script offers to build and install it from the AUR before the package menu.

**Separate prompts.** After the package menu, two optional components are prompted individually:

- **asusctl** — ASUS laptop power/fan control utility (AUR)
- **QEMU/KVM virtualization** — installs `qemu-full`, `virt-manager`, `virt-viewer`, `libvirt`, `dnsmasq`, `vde2`, `openbsd-netcat`; loads and persists `kvm`/`kvm_amd` modules; adds the current user to the `libvirt` group; enables `libvirtd`; starts and autostarts the default NAT network.

> **Note:** Log out and back in after QEMU/KVM setup for group changes to take effect.

**Menu 2 — Setup steps.** Same skip-by-number mechanic for the remaining configuration steps:

| # | Step | Description |
|---|---|---|
| 1 | Battery charge limit | Sets a persistent 80% charge threshold via udev rule at `/etc/udev/rules.d/99-asus-battery-threshold.rules`. Requires `/sys/class/power_supply/BAT0/charge_control_end_threshold`. |
| 2 | Microphone levels (ALSA) | Installs `alsa-utils`, sets `Internal Mic Boost` to 0 and `Capture` to 70% via `amixer`, then saves the state with `alsactl store`. |
| 3 | Wallpapers | Copies `wallpapers/wallpaper.jpg` to `~/Pictures/wallpapers/`. |
| 4 | Themes | Copies `Catppuccin-Mocha` from `themes/` to `~/.local/share/themes/` and applies it via `gsettings` (`gtk-theme`, `color-scheme prefer-dark`). Also installs `Bibata-Modern-Classic` and `Bibata-Modern-Ice` cursor themes to `/usr/share/icons/`. |
| 5 | SDDM Astronaut theme | Installs the theme from `themes/sddm-astronaut-theme/`, configures `/etc/sddm.conf`, enables the virtual keyboard, and sets SDDM as the active display manager. |
| 6 | Dotfiles sync | Copies `hypr`, `waybar`, `rofi`, `kitty`, `mako`, `cava`, `starship.toml`, `neofetch` from `config/` to `~/.config/`. Existing directories are replaced. |
| 7 | Starship prompt | Appends `eval "$(starship init bash)"` to `~/.bashrc` if not already present. |
| 8 | Windows dual-boot (GRUB) | Installs `os-prober`, enables it in `/etc/default/grub`, regenerates the GRUB config. |
| 9 | rEFInd boot manager | Installs `refind`, runs `refind-install`, and applies the Catppuccin Mocha theme from `themes/themes/` if present. |

**Launch Hyprland.** After all steps, the script offers to launch Hyprland immediately.

---

## Manual Package Installation

If you prefer to set up your system manually instead of using `install.sh`, install the following groups of packages via `pacman`:

### Base & Development
```
amd-ucode base git base-devel rust starship devtools
```

### Display & Compositor
```
hyprland hyprpicker waybar wlsunset swww grim slurp swappy kitty
xorg-server-xephyr xorg-xhost sddm refind qt6-virtualkeyboard rofimoji
```

### Networking & Bluetooth
```
inetutils net-tools network-manager-applet blueman bluez-utils avahi nss-mdns
```

### Utilities
```
acpi brightnessctl btop htop cliphist evtest micro nano vim unrar unzip nemo less
gvfs-afc tesseract tesseract-data-eng tesseract-data-ukr dmidecode
```

### Audio & Video
```
pipewire-pulse wireplumber easyeffects mpv cava spotify-launcher
```

### Fonts
```
ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-dejavu ttf-liberation
noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
```

### Mesa & Vulkan Drivers (AMD)
```
mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver
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
qemu-full virt-manager virt-viewer dnsmasq vde2 openbsd-netcat libvirt
```

### AUR packages
Install these with `yay` or your preferred AUR helper:
```
brave-bin catppuccin-gtk-theme-mocha neofetch touchegg-gce-git
waypaper wlogout peaclock pipes.sh yay yay-debug asusctl
proton-pass proton-authenticator-bin proton-vpn-gtk-app
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

*Last updated: 20-03-2026*
