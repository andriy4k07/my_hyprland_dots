#!/usr/bin/env bash

# =============================
# toggle-audio-mute.sh
# =============================

# Перемикаємо mute для DEFAULT sink
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Перевіряємо mute-статус
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo true || echo false)

# Обираємо іконку
if [ "$MUTED" = "true" ]; then
  ICON="🔇"
  MSG="Звук вимкнено"
else
  ICON="🔊"
  MSG="Звук увімкнено"
fi

# Надсилаємо одиночне повідомлення
notify-send \
  --hint=string:x-dunst-stack-tag:audio \
  --hint=string:synchronous:audio \
  --expire-time=1000 \
  "$ICON  $MSG"
