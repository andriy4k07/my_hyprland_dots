#!/usr/bin/env bash

# 1) Гучність у 0%
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%

# 2) Повідомлення
notify-send \
notify-send \
  --hint=string:x-dunst-stack-tag:volume \
  --hint=string:synchronous:volume \
  "🔇  0%"
