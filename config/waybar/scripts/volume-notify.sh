#!/usr/bin/env bash

# ============================
# volume-notify.sh (with 120% cap)
# ============================

# 1) Отримати поточну гучність (0–∞%)
CUR=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | awk '/Volume/ {printf("%.0f\n",$2*100)}')

# 2) Вирахувати нову гучність із cap=120
case "$1" in
  up)
    NEW=$(( CUR + 5 ))
    (( NEW > 120 )) && NEW=120
    ;;
  down)
    NEW=$(( CUR - 5 ))
    (( NEW < 0 ))   && NEW=0
    ;;
  *)
    exit 1
    ;;
esac

# 3) Задати обчислену гучність
wpctl set-volume @DEFAULT_AUDIO_SINK@ "${NEW}%"

# 4) Обрати іконку
if   (( NEW == 0 ));    then ICON="🔇"
elif (( NEW < 30 ));    then ICON="🔈"
elif (( NEW < 70 ));    then ICON="🔉"
else                     ICON="🔊"
fi

# 5) Відправити сповіщення з правильними hints
notify-send \
  --hint=string:x-dunst-stack-tag:volume \
  --hint=string:synchronous:volume \
  --expire-time=1000 \
  "Поточна гучність: $ICON  ${NEW}%"
#!/usr/bin/env bash

# ============================
# volume-notify.sh (with 120% cap)
# ============================

# 1) Отримати поточну гучність (0–∞%)
CUR=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ \
      | awk '/Volume/ {printf("%.0f\n",$2*100)}')

# 2) Вирахувати нову гучність із cap=120
case "$1" in
  up)
    NEW=$(( CUR + 5 ))
    (( NEW > 120 )) && NEW=120
    ;;
  down)
    NEW=$(( CUR - 5 ))
    (( NEW < 0 ))   && NEW=0
    ;;
  *)
    exit 1
    ;;
esac

# 3) Задати обчислену гучність
wpctl set-volume @DEFAULT_AUDIO_SINK@ "${NEW}%"

# 4) Обрати іконку
if   (( NEW == 0 ));    then ICON="🔇"
elif (( NEW < 30 ));    then ICON="🔈"
elif (( NEW < 70 ));    then ICON="🔉"
else                     ICON="🔊"
fi

# 5) Відправити сповіщення з правильними hints
notify-send \
  --hint=string:x-dunst-stack-tag:volume \
  --hint=string:synchronous:volume \
  --expire-time=1000 \
  "Поточна гучність: $ICON  ${NEW}%"
