#!/bin/bash

# Отримуємо поточний профіль
current=$(powerprofilesctl get)

# Визначаємо іконки для профілів
declare -A icons=(
    ["performance"]="⚡"
    ["balanced"]="⚖️"
    ["power-saver"]="🔋"
)

# Перемикаємо на наступний профіль
case $current in
    "performance")
        next="balanced"
        ;;
    "balanced")
        next="power-saver"
        ;;
    "power-saver")
        next="performance"
        ;;
    *)
        next="balanced"
        ;;
esac

# Встановлюємо новий профіль
powerprofilesctl set $next

# Форматуємо назву для виводу (з великої літери)
next_display=$(echo $next | sed 's/-/ /g' | sed 's/\b\w/\u&/g')

# Відправляємо повідомлення
notify-send \
    --hint=string:x-dunst-stack-tag:power-profile \
    --hint=string:synchronous:power-profile \
    --expire-time=1000 \
    -u normal \
    "Профіль живлення" \
    "${icons[$next]} <b>$next_display</b>"
