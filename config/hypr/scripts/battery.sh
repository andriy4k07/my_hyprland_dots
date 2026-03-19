#!/usr/bin/env bash
# Шукаємо першу батарею
battery_path=""
for bat in /sys/class/power_supply/*BAT*; do
    [[ -f "$bat/capacity" ]] && { battery_path="$bat"; break; }
done

# Якщо батареї нема — тільки блок живлення
if [[ -z "$battery_path" ]]; then
    echo "󰚥  AC"
    exit 0
fi

capacity=$(cat "$battery_path/capacity")
status=$(cat "$battery_path/status")   # Charging | Discharging | Full | Not charging

# Іконка за рівнем заряду
level_icon() {
    local pct=$1
    if   [[ $pct -ge 95 ]]; then echo "󰁹"   # 100%
    elif [[ $pct -ge 80 ]]; then echo "󰂂"   # 90%
    elif [[ $pct -ge 65 ]]; then echo "󰂀"   # 80% / 70%
    elif [[ $pct -ge 45 ]]; then echo "󰁾"   # 60% / 50%
    elif [[ $pct -ge 25 ]]; then echo "󰁼"   # 40% / 30%
    elif [[ $pct -ge 10 ]]; then echo "󰁻"   # 20%
    else echo "󰁺"                            # критично
    fi
}

case "$status" in
    Full)
        echo "󰁹  100%"
        ;;
    Charging)
        echo "󰂄  ${capacity}%"
        ;;
    *)
        # Discharging / Not charging
        icon=$(level_icon "$capacity")
        echo "${icon}  ${capacity}%"
        ;;
esac
