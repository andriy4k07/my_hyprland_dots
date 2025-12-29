#!/usr/bin/env bash
# Fast keyboard layout toggle for Hyprland + Waybar

# get main keyboard name
read -r KBD KEYMAP <<<"$(
  hyprctl devices -j | jq -r '
    .keyboards[] | select(.main == true) | "\(.name) \(.active_keymap)"
  '
)"

# fallback if main keyboard not found
if [ -z "$KBD" ]; then
  KBD=$(hyprctl devices -j | jq -r '.keyboards[0].name')
fi

# switch layout
hyprctl switchxkblayout "$KBD" next 2>/dev/null

# read updated keymap
KEYMAP=$(hyprctl devices -j | jq -r '
  .keyboards[] | select(.main == true) | .active_keymap
')

# normalize label
case "$KEYMAP" in
  *Ukrainian*|*ua*)
    LABEL="UA — Ukrainian"
    ;;
  *English*|*us*)
    LABEL="EN — English (US)"
    ;;
  *)
    LABEL="$KEYMAP"
    ;;
esac

# notify
notify-send \
  --hint=string:x-dunst-stack-tag:volume \
  --hint=string:synchronous:volume \
  --expire-time=1000 \
  -u normal "Keyboard layout" "$LABEL"

echo "$LABEL"
