# ~/.config/hypr/scripts/restart-hyprland.sh
#!/bin/bash

# Перезапуск Waybar
killall waybar
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css &
waybar -c ~/.config/waybar/config_hdmi.jsonc -s ~/.config/waybar/style_hdmi.css &
# Перезавантаження конфігурації Hyprland
hyprctl reload

notify-send "Hyprland + Waybar" "Перезапущено успішно"
