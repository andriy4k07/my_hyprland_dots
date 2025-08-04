#!/usr/bin/env bash

# =============================
# toggle-mic-mute.sh
# =============================

# Перемикаємо mute для DEFAULT source
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Перевіряємо mute-статус
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo true || echo false)

# Обираємо іконку
if [ "$MUTED" = "true" ]; then
  ICON="🎤❌"
  MSG="Мікрофон вимкнено"
else
  ICON="🎤"
  MSG="Мікрофон увімкнено"
fi

# Надсилаємо одиночне повідомлення
notify-send \
  --hint=string:x-dunst-stack-tag:mic \
  --hint=string:synchronous:mic \
  --expire-time=1000 \
  "$ICON  $MSG"
