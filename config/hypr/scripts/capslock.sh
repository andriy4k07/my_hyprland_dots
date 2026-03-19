#!/usr/bin/env bash
# hyprctl devices: рядок capsLock йде ДО рядка "main: yes",
# тому шукаємо 6 рядків перед "main: yes"
CAPS=$(hyprctl devices | grep -B 6 "main: yes" | grep "capsLock" | head -1 | awk '{print $2}')

if [[ "$CAPS" == "yes" ]]; then
    echo "󰪛  CAPS LOCK"
else
    echo ""
fi
