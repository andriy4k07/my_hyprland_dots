#!/usr/bin/env bash
set -euo pipefail
# install.sh – Install packages and sync dotfiles for my_hyprland_dots
# Usage: ./install.sh [--noconfirm]

# ─── Flags ────────────────────────────────────────────────────────────────────
NOCONFIRM=false
for arg in "$@"; do
  [[ "$arg" == "--noconfirm" ]] && NOCONFIRM=true
done

# ─── Colors ───────────────────────────────────────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'

info()    { echo -e "${CYAN}${BOLD}  ──▶${RESET} ${CYAN}$*${RESET}"; }
success() { echo -e "${GREEN}${BOLD}  ✔${RESET}  ${GREEN}$*${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}  ⚠${RESET}  ${YELLOW}$*${RESET}"; }
error()   { echo -e "${RED}${BOLD}  ✘${RESET}  ${RED}$*${RESET}"; }
header()  { echo -e "\n${BLUE}${BOLD}══════════════════════════════════════${RESET}"; \
            echo -e "${BLUE}${BOLD}  $*${RESET}"; \
            echo -e "${BLUE}${BOLD}══════════════════════════════════════${RESET}"; }

# ─── Prompt helper ────────────────────────────────────────────────────────────
# ask "Question?" → returns 0 (yes) or 1 (no); auto-yes in --noconfirm mode
ask() {
  if $NOCONFIRM; then return 0; fi
  echo -e "${GREEN}${BOLD}  ?${RESET}  ${GREEN}$* (Y/n)${RESET}"
  read -r yn
  [[ ! "$yn" =~ ^[Nn] ]]
}

# ─── Script location ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$SCRIPT_DIR/config"
mkdir -p "$BASE"

# ─── Package groups ───────────────────────────────────────────────────────────
wayland=(
  hyprland hyprpicker waybar wlsunset swww grim slurp kitty swappy mako rofi sddm
  xorg-server-xephyr xorg-xhost qt6-virtualkeyboard rofimoji
)
audio_video=(
  pipewire-pulse wireplumber easyeffects mpv cava spotify-launcher
)
network_bt=(
  inetutils net-tools network-manager-applet blueman bluez-utils avahi nss-mdns
)
utilities=(
  acpi brightnessctl btop htop cliphist evtest micro nano vim unrar unzip nemo less
  gvfs-afc tesseract tesseract-data-eng tesseract-data-ukr dmidecode
)
dev_tools=(
  rust starship devtools
)
social=(
  discord telegram-desktop signal-desktop
)
apps=(
  firefox obsidian inkscape viewnior flatpak nextcloud-client
)
proton=(
  proton-vpn-gtk-app
)
fonts=(
  ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-dejavu ttf-liberation
  noto-fonts noto-fonts-emoji ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
)
graphics_vulkan=(
  mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon
  vulkan-icd-loader lib32-vulkan-icd-loader libva-mesa-driver lib32-libva-mesa-driver
)
gaming=(
  steam
)
aur_packages=(
  brave-bin catppuccin-gtk-theme-mocha neofetch touchegg-gce-git
  waypaper wlogout yay yay-debug peaclock pipes.sh
  proton-pass proton-authenticator-bin
)

# ─── Group metadata (parallel arrays) ────────────────────────────────────────
GROUP_NAMES=(
  "Hyprland & Wayland"
  "Audio & Video"
  "Networking & Bluetooth"
  "Utilities"
  "Base & Development"
  "Social"
  "Apps"
  "Proton"
  "Fonts"
  "Mesa & Vulkan (AMD)"
  "Gaming"
  "AUR packages"
)
GROUP_VARS=(
  wayland
  audio_video
  network_bt
  utilities
  dev_tools
  social
  apps
  proton
  fonts
  graphics_vulkan
  gaming
  aur_packages   # sentinel — handled separately below
)

# ─── Functions ────────────────────────────────────────────────────────────────
install_virtualization() {
  local virt_pkgs=(qemu-full virt-manager virt-viewer dnsmasq vde2 openbsd-netcat libvirt)

  info "Installing virtualization packages..."
  sudo pacman -S --needed --noconfirm "${virt_pkgs[@]}"

  info "Loading KVM kernel modules..."
  sudo modprobe kvm
  sudo modprobe kvm_amd

  info "Persisting KVM modules across reboots..."
  echo -e "kvm\nkvm_amd" | sudo tee /etc/modules-load.d/kvm.conf > /dev/null

  info "Adding $USER to libvirt group..."
  sudo usermod -aG libvirt "$USER"

  info "Enabling and starting libvirtd..."
  sudo systemctl enable --now libvirtd

  info "Starting and setting default NAT network to autostart..."
  sudo virsh net-start default 2>/dev/null || warn "Default network may already be running"
  sudo virsh net-autostart default

  success "Virtualization setup complete! Log out and back in for group changes to take effect."
}

setup_battery_threshold() {
  local threshold_file="/sys/class/power_supply/BAT0/charge_control_end_threshold"
  local rules_file="/etc/udev/rules.d/99-asus-battery-threshold.rules"

  if [[ ! -f "$threshold_file" ]]; then
    warn "$threshold_file not found. Your device may not support this feature."
    return 1
  fi

  info "Creating udev rule for 80% charge limit..."
  echo 'ACTION=="add|change", SUBSYSTEM=="power_supply", KERNEL=="BAT0", ATTR{charge_control_end_threshold}!="80", ATTR{charge_control_end_threshold}="80"' \
    | sudo tee "$rules_file" > /dev/null

  info "Reloading udev rules..."
  sudo udevadm control --reload-rules
  sudo udevadm trigger --subsystem-match=power_supply

  success "Battery charge limit set to 80%."
}

install_sddm_theme() {
  local date; date=$(date +%s)
  local theme_source="$SCRIPT_DIR/themes/sddm-astronaut-theme"

  if [[ ! -d "$theme_source" ]]; then
    error "SDDM theme not found at $theme_source"
    return 1
  fi

  info "Installing SDDM theme dependencies..."
  sudo pacman --noconfirm --needed -S qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

  info "Installing SDDM Astronaut theme..."
  [[ -d /usr/share/sddm/themes/sddm-astronaut-theme ]] && \
    sudo mv /usr/share/sddm/themes/sddm-astronaut-theme \
            /usr/share/sddm/themes/sddm-astronaut-theme_"$date"

  sudo mkdir -p /usr/share/sddm/themes/sddm-astronaut-theme
  sudo cp -r "$theme_source"/* /usr/share/sddm/themes/sddm-astronaut-theme/

  [[ -d "$theme_source/Fonts" ]] && sudo cp -r "$theme_source/Fonts"/* /usr/share/fonts/

  printf '[Theme]\nCurrent=sddm-astronaut-theme\n' | sudo tee /etc/sddm.conf > /dev/null
  sudo mkdir -p /etc/sddm.conf.d
  printf '[General]\nInputMethod=qtvirtualkeyboard\n' | sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null

  info "Enabling SDDM service..."
  sudo systemctl disable display-manager.service 2>/dev/null || true
  sudo systemctl enable sddm.service

  success "SDDM Astronaut theme installed."
}

# ─── 0. Multilib check ────────────────────────────────────────────────────────
header "0. Multilib repository"
if ! grep -Eq "^\[multilib\]" /etc/pacman.conf; then
  warn "[multilib] is not enabled."
  if ask "Enable [multilib] now?"; then
    info "Enabling multilib in /etc/pacman.conf..."
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;}' /etc/pacman.conf
    info "Updating package database..."
    sudo pacman -Syu --noconfirm
    success "Multilib enabled."
  else
    warn "Skipping multilib. Some packages (e.g. lib32-*) may fail to install."
  fi
else
  success "[multilib] is already enabled."
fi

# ─── 1. yay ───────────────────────────────────────────────────────────────────
header "1. AUR helper (yay)"
if ! command -v yay &> /dev/null; then
  warn "yay is not installed."
  if ask "Build and install yay from AUR?"; then
    info "Installing git and base-devel..."
    sudo pacman -Syu --needed --noconfirm git base-devel
    tmpdir=$(mktemp -d)
    info "Cloning and building yay..."
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    pushd "$tmpdir/yay" &> /dev/null
    makepkg -si --noconfirm
    popd &> /dev/null
    rm -rf "$tmpdir"
    success "yay installed."
  fi
else
  success "yay is already installed."
fi

# ─── 2. Package group selection ───────────────────────────────────────────────
header "2. Package groups"

echo -e "\n${BOLD}  Available groups:${RESET}"
for i in "${!GROUP_NAMES[@]}"; do
  printf "  ${CYAN}${BOLD}[%2d]${RESET}  %s\n" "$((i+1))" "${GROUP_NAMES[$i]}"
done

SKIP_INDICES=()
if ! $NOCONFIRM; then
  echo -e "\n${GREEN}  Enter group numbers to ${BOLD}SKIP${RESET}${GREEN} (comma-separated), or press Enter to install all:${RESET}"
  read -r skip_input
  if [[ -n "$skip_input" ]]; then
    IFS=',' read -ra raw_skip <<< "$skip_input"
    for idx in "${raw_skip[@]}"; do
      idx="${idx// /}"
      SKIP_INDICES+=("$idx")
    done
  fi
fi

should_skip() {
  local num="$1"
  for s in "${SKIP_INDICES[@]:-}"; do
    [[ "$s" == "$num" ]] && return 0
  done
  return 1
}

# ─── 3. Install pacman groups ─────────────────────────────────────────────────
header "3. Installing packages"

GROUP_VARNAMES=(wayland audio_video network_bt utilities dev_tools social apps proton fonts graphics_vulkan gaming)
GROUP_DISPLAY_NAMES=(
  "Hyprland & Wayland"
  "Audio & Video"
  "Networking & Bluetooth"
  "Utilities"
  "Base & Development"
  "Social"
  "Apps"
  "Proton"
  "Fonts"
  "Mesa & Vulkan (AMD)"
  "Gaming"
)

for i in "${!GROUP_VARNAMES[@]}"; do
  group_num=$((i+1))
  varname="${GROUP_VARNAMES[$i]}"
  label="${GROUP_DISPLAY_NAMES[$i]}"

  if should_skip "$group_num"; then
    warn "Skipping [$group_num] $label"
    continue
  fi

  # Dereference array by name
  declare -n pkgs="$varname"
  info "[$group_num] Installing: ${BOLD}$label${RESET}${CYAN}..."
  sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  success "[$group_num] $label — done."
  unset -n pkgs
done

# ─── 4. AUR packages ──────────────────────────────────────────────────────────
aur_group_num=12
if should_skip "$aur_group_num"; then
  warn "Skipping [12] AUR packages"
elif command -v yay &> /dev/null; then
  info "[12] Installing: ${BOLD}AUR packages${RESET}${CYAN}..."
  for pkg in "${aur_packages[@]}"; do
    info "  yay: $pkg"
    yay -S --needed --noconfirm "$pkg"
  done
  success "[12] AUR packages — done."
else
  warn "yay not found, skipping AUR packages."
fi

# ─── 5. asusctl ───────────────────────────────────────────────────────────────
header "4. asusctl"
if ask "Install asusctl from AUR?"; then
  info "Installing asusctl..."
  yay -S --needed --noconfirm asusctl
  success "asusctl installed."
fi

# ─── 6. QEMU/KVM ──────────────────────────────────────────────────────────────
header "5. QEMU/KVM Virtualization"
if ask "Install and configure QEMU/KVM virtualization?"; then
  install_virtualization
fi

# ─── 7. Battery threshold ─────────────────────────────────────────────────────
header "6. Battery Charge Limit"
if ask "Set battery charge limit to 80%?"; then
  setup_battery_threshold
fi

# ─── 8. Wallpapers ────────────────────────────────────────────────────────────
header "7. Wallpapers"
if ask "Install wallpapers?"; then
  wallpaper_source="$SCRIPT_DIR/wallpapers/wallpaper.jpg"
  wallpaper_dest="$HOME/Pictures/wallpapers"
  if [[ -f "$wallpaper_source" ]]; then
    info "Copying wallpaper to ~/Pictures/wallpapers/..."
    mkdir -p "$wallpaper_dest"
    cp "$wallpaper_source" "$wallpaper_dest/"
    success "Wallpaper installed."
  else
    warn "wallpaper.jpg not found at $wallpaper_source"
  fi
fi

# ─── 9. Cursor themes ─────────────────────────────────────────────────────────
header "8. Cursor Themes"
if ask "Install Bibata cursor themes?"; then
  cursors_source="$SCRIPT_DIR/themes"
  if [[ -d "$cursors_source/Bibata-Modern-Classic" && -d "$cursors_source/Bibata-Modern-Ice" ]]; then
    info "Installing Bibata cursor themes to /usr/share/icons/..."
    sudo mv "$cursors_source"/Bibata-Modern-* /usr/share/icons/
    success "Bibata cursor themes installed."
  else
    warn "Bibata cursor theme directories not found in $cursors_source"
  fi
fi

# ─── 10. SDDM theme ───────────────────────────────────────────────────────────
header "9. SDDM Astronaut Theme"
if ask "Install SDDM Astronaut theme?"; then
  install_sddm_theme
fi

# ─── 11. Dotfiles ─────────────────────────────────────────────────────────────
header "10. Dotfiles Sync"
if ask "Sync dotfiles to ~/.config?"; then
  info "Syncing dotfiles..."
  TARGET="$HOME/.config"
  for item in hypr waybar rofi starship.toml mako cava kitty neofetch; do
    SRC="$BASE/$item"
    DST="$TARGET/$item"
    if [[ -f "$SRC" ]]; then
      mkdir -p "$(dirname "$DST")"
      cp -f "$SRC" "$DST"
      success "  $item → $DST"
    elif [[ -d "$SRC" ]]; then
      mkdir -p "$TARGET"
      [[ -e "$DST" ]] && rm -rf "$DST"
      cp -r "$SRC" "$DST"
      success "  $item/ → $DST/"
    else
      warn "  $item not found in $BASE, skipping."
    fi
  done
fi

# ─── 12. Starship prompt ──────────────────────────────────────────────────────
header "11. Starship Prompt"
if ask "Add starship init to ~/.bashrc?"; then
  if ! grep -q 'eval "$(starship init bash)"' ~/.bashrc 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    success "Starship init added to ~/.bashrc."
  else
    success "Starship init already present in ~/.bashrc."
  fi
fi

# ─── 13. GRUB dual-boot ───────────────────────────────────────────────────────
header "12. Windows Dual-Boot (GRUB)"
if ask "Add Windows dual-boot to GRUB?"; then
  info "Installing os-prober and updating GRUB config..."
  sudo pacman -Sy --noconfirm os-prober
  echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub > /dev/null
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  success "Windows dual-boot added to GRUB."
fi

# ─── 14. rEFInd ───────────────────────────────────────────────────────────────
header "13. rEFInd Boot Manager"
if ask "Install rEFInd boot manager?"; then
  info "Installing rEFInd..."
  sudo pacman -S --noconfirm refind
  sudo refind-install
  success "rEFInd installed."

  if ask "Apply Catppuccin Mocha theme to rEFInd?"; then
    refind_themes_source="$SCRIPT_DIR/themes/themes"
    refind_config_path="/boot/EFI/refind"
    if [[ -d "$refind_themes_source" ]]; then
      info "Copying rEFInd themes..."
      sudo cp -r "$refind_themes_source" "$refind_config_path/"
      echo 'include themes/catppuccin/mocha.conf' | sudo tee -a "$refind_config_path/refind.conf" > /dev/null
      success "rEFInd Catppuccin Mocha theme applied."
    else
      warn "rEFInd themes not found at $refind_themes_source"
    fi
  fi
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
header "All tasks complete!"

if ask "Launch Hyprland now?"; then
  info "Launching Hyprland..."
  Hyprland
fi
