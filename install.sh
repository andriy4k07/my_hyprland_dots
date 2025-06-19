#!/usr/bin/env bash
set -euo pipefail

# install.sh – Install packages and sync dotfiles for my_hyprland_dots
# Usage: ./install.sh

BASE="$HOME/project/my_hyprland_dots/config"
mkdir -p "$BASE"

# Package groups
base_dev=(
  amd-ucode base git base-devel rust starship
)
display_comp=(
  hyprland hyprpicker waybar wlsunset xorg-server-xephyr xorg-xhost sddm refind qt6-virtualkeyboard
)
network_bt=(
  inetutils net-tools network-manager-applet blueman bluez-utils
)
utilities=(
  brightnessctl btop htop cliphist evtest  micro nano vim uwufetch unrar unzip
)
media_graphics=(
  firefox flatpak inkscape mpv viewnior swappy cava easyeffects
)
graphics_vulkan=(
  mesa mesa-vdpau lib32-mesa vulkan-radeon lib32-vulkan-radeon
)
music_audio=(
  spotify-launcher spotifyd
)
gaming=(
  steam
)

aur_packages=(
  brave-bin catppuccin-gtk-theme-mocha neofetch swaylock-effects touchegg-gce-git waypaper wlogout yay yay-debug
)

# Function to prompt and install a group
install_group() {
  local name="$1[@]"; shift
  local label="$1"; shift
  local pkgs=("${!name}")

  read -rp "Install ${label}? (y/N) " yn
  if [[ "$yn" =~ ^[Yy] ]]; then
    echo "=> Installing ${label} packages..."
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
  fi
}

# Ensure yay is installed
if ! command -v yay &> /dev/null; then
  read -rp "yay is not installed. Install yay now? (y/N) " yn
  if [[ "$yn" =~ ^[Yy] ]]; then
    echo "=> Ensuring dependencies: git and base-devel..."
    sudo pacman -Syu --needed --noconfirm git base-devel
    tmpdir=$(mktemp -d)
    echo "=> Cloning and building yay..."
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    pushd "$tmpdir/yay" &> /dev/null
    makepkg -si --noconfirm
    popd &> /dev/null
    rm -rf "$tmpdir"
  fi
fi

# Install official package groups
install_group base_dev "Base & Development"
install_group display_comp "Display & Compositor"
install_group network_bt "Networking & Bluetooth"
install_group utilities "Utilities"
install_group media_graphics "Media & Graphics"
install_group graphics_vulkan "Mesa & Vulkan Drivers"
install_group music_audio "Music & Audio"
install_group gaming "Gaming"

# Install AUR packages
read -rp "Install AUR packages? (y/N) " yn
if [[ "$yn" =~ ^[Yy] ]]; then
  echo "=> Installing AUR packages..."
  for pkg in "${aur_packages[@]}"; do
    yay -S --needed --noconfirm "$pkg"
  done
fi

# Sync dotfiles
read -rp "Sync dotfiles to ~/.config? (y/N) " yn
if [[ "$yn" =~ ^[Yy] ]]; then
  echo "=> Syncing dotfiles..."
  if ! command -v rsync &> /dev/null; then
    echo "rsync not found, installing..."
    sudo pacman -S --needed --noconfirm rsync
  fi
  TARGET="$HOME/.config"
  for item in hypr waybar rofi starship.toml swaylock mako cava kitty neofetch; do
    SRC="$BASE/$item"
    DST="$TARGET/$item"
    if [[ -f "$SRC" ]]; then
      cp -f "$SRC" "$DST"
    else
      mkdir -p "$DST"
      if [[ -d "$SRC/$item" ]]; then
        rsync -a --delete "$SRC/$item/" "$DST/"
      else
        rsync -a --delete "$SRC/" "$DST/"
      fi
    fi
  done
fi

echo "All tasks complete!"
