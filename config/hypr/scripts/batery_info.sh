#!/bin/bash

# Отримати список підключених Bluetooth пристроїв та їх заряд
get_battery_info() {
    local devices=""
    
    # Шукаємо всі підключені пристрої через bluetoothctl
    while IFS= read -r line; do
        if [[ $line =~ Device\ ([0-9A-F:]+)\ (.+) ]]; then
            mac="${BASH_REMATCH[1]}"
            name="${BASH_REMATCH[2]}"
            
            # Перевіряємо чи пристрій підключений
            if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
                # Отримуємо рівень батареї через upower або bluetoothctl
                battery=$(bluetoothctl info "$mac" | grep "Battery Percentage" | awk '{print $4}' | tr -d '()')
                
                if [ -z "$battery" ]; then
                    # Альтернативний метод через upower
                    battery=$(upower -d | grep -A 20 "$mac" | grep "percentage" | awk '{print $2}' | tr -d '%')
                fi
                
                if [ -n "$battery" ]; then
                    # Визначаємо іконку в залежності від типу пристрою
                    icon="🔋"
                    if [[ $name =~ [Kk]eyboard|K68 ]]; then
                        icon="⌨️"
                    elif [[ $name =~ [Mm]ouse ]]; then
                        icon="🖱️"
                    elif [[ $name =~ [Hh]eadphone|[Aa]ir[Pp]ods|[Ee]arbud ]]; then
                        icon="🎧"
                    fi
                    
                    devices+="$icon <b>$name</b>: ${battery}%\n"
                fi
            fi
        fi
    done < <(bluetoothctl devices)
    
    echo -e "$devices"
}

# Отримуємо інформацію
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
