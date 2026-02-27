#!/usr/bin/env bash

get_battery_info() {
    local devices=""

    # Отримати всі bluetooth device paths з BlueZ
    mapfile -t devs < <(busctl tree org.bluez 2>/dev/null | grep -o '/org/bluez/hci[0-9]*/dev_[^ ]*')

    for dev in "${devs[@]}"; do
        # --- name ---
        name=$(busctl get-property org.bluez "$dev" org.bluez.Device1 Name 2>/dev/null | cut -d'"' -f2)

        # --- connected? ---
        connected=$(busctl get-property org.bluez "$dev" org.bluez.Device1 Connected 2>/dev/null | awk '{print $2}')
        [ "$connected" != "true" ] && continue

        # --- battery ---
        battery=$(busctl get-property org.bluez "$dev" org.bluez.Battery1 Percentage 2>/dev/null | awk '{print $2}')

        # якщо батареї нема — пропускаємо (як у твоєму скрипті)
        [ -z "$battery" ] && continue

        # --- icon selection (як було) ---
        icon="🔋"
        if [[ $name =~ [Kk]eyboard|K68 ]]; then
            icon="⌨️"
        elif [[ $name =~ [Mm]ouse ]]; then
            icon="🖱️"
        elif [[ $name =~ [Hh]eadphone|[Aa]ir[Pp]ods|[Ee]arbud ]]; then
            icon="🎧"
        fi

        devices+="$icon <b>$name</b>: ${battery}%\n"
    done

    echo -e "$devices"
}

info=$(get_battery_info)

if [ -n "$info" ]; then
    notify-send \
        --hint=string:x-dunst-stack-tag:bluetooth-battery \
        --hint=string:synchronous:bluetooth-battery \
        --expire-time=3000 \
        "Заряд Bluetooth пристроїв:" \
        "$info"
else
    notify-send \
        --hint=string:x-dunst-stack-tag:bluetooth-battery \
        --expire-time=2000 \
        "Немає підключених пристроїв" \
        "Bluetooth пристрої не знайдені"
fi
