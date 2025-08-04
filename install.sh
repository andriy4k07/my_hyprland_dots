#!/usr/bin/env bash
set -euo pipefail
# install.sh – Install packages and sync dotfiles for my_hyprland_dots
# Usage: ./install.sh

# Determine the script location and set BASE path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="$SCRIPT_DIR/config"
mkdir -p "$BASE"

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 0. Ensure multilib repository is enabled
if ! grep -Eq "^\[multilib\]" /etc/pacman.conf; then
  echo -e "${GREEN}The [multilib] repository is not enabled. Enable it now? (Y/n)${NC}"
  read -r yn
  if [[ ! "$yn" =~ ^[Nn] ]]; then
    echo "=> Enabling multilib in /etc/pacman.conf"
    sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;}' /etc/pacman.conf
    echo "=> Updating package database"
    sudo pacman -Syu --noconfirm
  else
    echo "Warning: multilib repository is required for some packages (e.g., lib32). You may encounter errors."
  fi
fi

# Package groups
base_dev=(
  rust starship
)

display_comp=(
  hyprland hyprpicker waybar wlsunset xorg-server-xephyr xorg-xhost sddm refind qt6-virtualkeyboard
)

network_bt=(
  inetutils net-tools network-manager-applet blueman bluez-utils
)

utilities=(
  brightnessctl btop htop cliphist evtest micro nano vim uwufetch unrar unzip rofi nemo kitty telegram-desktop mako ttf-jetbrains-mono-nerd swww
)

media_graphics=(
  firefox flatpak inkscape mpv viewnior swappy cava easyeffects grim slurp
)

graphics_vulkan=(
  mesa mesa-vdpau lib32-mesa vulkan-radeon lib32-vulkan-radeon
)

music_audio=(
  spotify-launcher spotifyd wireplumber pipewire-pulse
)

gaming=(
  steam
)

aur_packages=(
  brave-bin catppuccin-gtk-theme-mocha neofetch swaylock-effects touchegg-gce-git waypaper wlogout yay yay-debug
)

# SDDM theme installation function
install_sddm_theme() {
  local date=$(date +%s)
  local theme_source="$SCRIPT_DIR/themes/sddm-astronaut-theme"
  
  if [[ ! -d "$theme_source" ]]; then
    echo "=> Error: SDDM theme not found at $theme_source"
    echo "=> Please copy the theme files to your dotfiles directory first"
    return 1
  fi
  
  echo "=> Installing SDDM theme dependencies..."
  sudo pacman --noconfirm --needed -S qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
  
  echo "=> Installing SDDM Astronaut theme from dotfiles..."
  [ -d /usr/share/sddm/themes/sddm-astronaut-theme ] && sudo mv /usr/share/sddm/themes/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme_$date
  
  sudo mkdir -p /usr/share/sddm/themes/sddm-astronaut-theme
  sudo cp -r "$theme_source"/* /usr/share/sddm/themes/sddm-astronaut-theme/
  
  # Install theme fonts
  if [[ -d "$theme_source/Fonts" ]]; then
    sudo cp -r "$theme_source/Fonts"/* /usr/share/fonts/
  fi
  
  # Configure SDDM
  echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf > /dev/null
  
  sudo mkdir -p /etc/sddm.conf.d
  echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null
  
  # Enable SDDM
  echo "=> Enabling SDDM service..."
  sudo systemctl disable display-manager.service 2>/dev/null || true
  sudo systemctl enable sddm.service
  
  echo "=> SDDM Astronaut theme installed successfully!"
}

# Function to prompt and install a group
install_group() {
  local name="$1[@]"; shift
  local label="$1"; shift
  local pkgs=("${!name}")
  
  echo -e "${GREEN}Install ${label}? (Y/n)${NC}"
  read -r yn
  if [[ ! "$yn" =~ ^[Nn] ]]; then
    echo "=> Installing ${label} packages..."
    sudo pacman -Syu --needed --noconfirm "${pkgs[@]}"
  fi
}

# Ensure yay is installed
if ! command -v yay &> /dev/null; then
  echo -e "${GREEN}yay is not installed. Install yay now? (Y/n)${NC}"
  read -r yn
  if [[ ! "$yn" =~ ^[Nn] ]]; then
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
echo -e "${GREEN}Install AUR packages? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Installing AUR packages..."
  for pkg in "${aur_packages[@]}"; do
    yay -S --needed --noconfirm "$pkg"
  done
fi

# Install asusctl from AUR (separate prompt)
echo -e "${GREEN}Install asusctl from AUR? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Installing asusctl..."
  yay -S --needed --noconfirm asusctl
fi

# Install wallpapers
echo -e "${GREEN}Install wallpapers? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Installing wallpapers..."
  local wallpaper_source="$SCRIPT_DIR/wallpapers/wallpaper.jpg"
  local wallpaper_dest="$HOME/Pictures/wallpaper"
  
  if [[ -f "$wallpaper_source" ]]; then
    echo "=> Copying wallpaper to ~/Pictures/wallpaper/"
    mkdir -p "$wallpaper_dest"
    cp "$wallpaper_source" "$wallpaper_dest/"
    echo "=> Wallpaper installed successfully!"
  else
    echo "=> Warning: wallpaper.jpg not found in $SCRIPT_DIR/wallpapers/"
  fi
fi

# Install cursor themes
echo -e "${GREEN}Install cursor themes (Bibata-Modern)? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Installing cursor themes..."
  local cursors_source="$SCRIPT_DIR/themes"
  
  if [[ -d "$cursors_source/Bibata-Modern-Classic" && -d "$cursors_source/Bibata-Modern-Ice" ]]; then
    echo "=> Installing Bibata cursor themes..."
    sudo mv "$cursors_source"/Bibata-Modern-* /usr/share/icons/
    echo "=> Bibata cursor themes installed successfully!"
  else
    echo "=> Warning: Bibata cursor themes not found in $cursors_source"
    echo "=> Expected: Bibata-Modern-Classic and Bibata-Modern-Ice directories"
  fi
fi

# Install SDDM Astronaut Theme
echo -e "${GREEN}Install SDDM Astronaut Theme? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  install_sddm_theme
fi

# Sync dotfiles
echo -e "${GREEN}Sync dotfiles to ~/.config? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Syncing dotfiles..."
  
  TARGET="$HOME/.config"
  for item in hypr waybar rofi starship.toml swaylock mako cava kitty neofetch; do
    SRC="$BASE/$item"
    DST="$TARGET/$item"
    
    if [[ -f "$SRC" ]]; then
      # Copy single file
      mkdir -p "$(dirname "$DST")"
      cp -f "$SRC" "$DST"
    elif [[ -d "$SRC" ]]; then
      # Copy directory recursively
      mkdir -p "$TARGET"
      # Remove destination if exists to ensure clean copy
      [[ -e "$DST" ]] && rm -rf "$DST"
      cp -r "$SRC" "$DST"
    fi
  done
fi

# Add starship init to ~/.bashrc
echo -e "${GREEN}Add starship init to ~/.bashrc? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Adding starship init to ~/.bashrc..."
  if ! grep -q 'eval "$(starship init bash)"' ~/.bashrc 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    echo "=> Starship init added to ~/.bashrc"
  else
    echo "=> Starship init already exists in ~/.bashrc"
  fi
fi

# Add Windows dualboot to grub
echo -e "${GREEN}Add Windows dualboot to grub? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Setting up Windows dualboot in GRUB..."
  sudo pacman -Sy --noconfirm os-prober
  echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
  echo "=> Windows dualboot added to GRUB successfully!"
fi

# Add rEFInd
echo -e "${GREEN}Add rEFInd boot manager? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Installing and configuring rEFInd..."
  sudo pacman -S --noconfirm refind
  sudo refind-install
  echo "=> rEFInd boot manager installed successfully!"
fi

# Customize rEFInd
echo -e "${GREEN}Customize rEFInd theme? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Customizing rEFInd theme..."
  local refind_themes_source="$SCRIPT_DIR/themes/themes"
  local refind_config_path="/boot/EFI/refind"
  
  if [[ -d "$refind_themes_source" ]]; then
    echo "=> Copying rEFInd themes to /boot/EFI/refind/"
    sudo cp -r "$refind_themes_source" "$refind_config_path/"
    echo "=> Adding Catppuccin Mocha theme to refind.conf..."
    cd "$refind_config_path"
    echo 'include themes/catppuccin/mocha.conf' | sudo tee -a refind.conf
    cd - > /dev/null
    echo "=> rEFInd theme customized successfully!"
  else
    echo "=> Warning: rEFInd themes not found in $refind_themes_source"
    echo "=> Expected: themes/themes directory"
  fi
fi

echo "All tasks complete!"

# Launch Hyprland
echo -e "${GREEN}Launch Hyprland now? (Y/n)${NC}"
read -r yn
if [[ ! "$yn" =~ ^[Nn] ]]; then
  echo "=> Launching Hyprland..."
  Hyprland
fi
