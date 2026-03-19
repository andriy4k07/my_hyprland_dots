#!/bin/sh

USERNAME="andriy4k07"
GH="https://api.github.com"
CACHE="/tmp/waybar-github-cache.json"

# ── Спільні дані ─────────────────────────────────────────────
fetch_data() {
    last_repo=$(curl -sf --netrc \
      "$GH/users/$USERNAME/events?per_page=30" \
      | jq -r '[.[] | select(.type == "PushEvent")] | first | .repo.name' \
      | cut -d'/' -f2)
    [ -z "$last_repo" ] || [ "$last_repo" = "null" ] && last_repo="?"

    notif_count=$(curl -sf --netrc \
      "$GH/notifications?per_page=50" | jq 'length')
    [ -z "$notif_count" ] || [ "$notif_count" = "null" ] && notif_count=0
}

# ── Режим waybar ─────────────────────────────────────────────
waybar_mode() {
    profile=$(powerprofilesctl get 2>/dev/null)
    if [ "$profile" = "power-saver" ]; then
        if [ -f "$CACHE" ]; then
            cat "$CACHE"
        else
            printf '{"text":"󰊤 …","class":"none"}\n'
        fi
        return
    fi

    fetch_data

    if [ "$notif_count" -gt 0 ]; then
        css_class="notify"
    else
        css_class="none"
    fi

    result=$(printf '{"text":"󰊤 %s","class":"%s"}\n' \
        "$last_repo" "$css_class")

    # Зберігаємо в кеш
    echo "$result" > "$CACHE"
    echo "$result"
}

# ── Режим сповіщень — по кліку ───────────────────────────────
notify_mode() {
    fetch_data

    # 1) Коміти
    commits=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/commits?per_page=2" \
      | jq -r '.[] | "• " + .commit.message' \
      | while IFS= read -r line; do
            short=$(echo "$line" | cut -c1-50)
            [ ${#line} -gt 50 ] && short="${short}…"
            echo "$short"
        done)

    notify-send \
      --hint=string:x-dunst-stack-tag:github-commits \
      --expire-time=10000 \
      "󰊤  $last_repo — коміти" "$commits"

    # 2) PR
    pr_count=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/pulls?state=open&per_page=10" \
      | jq 'length')
    [ -z "$pr_count" ] || [ "$pr_count" = "null" ] && pr_count=0

    if [ "$pr_count" -gt 0 ]; then
        pr_body=$(curl -sf --netrc \
          "$GH/repos/$USERNAME/$last_repo/pulls?state=open&per_page=3" \
          | jq -r '.[] | "• " + .title' \
          | while IFS= read -r line; do
                short=$(echo "$line" | cut -c1-50)
                [ ${#line} -gt 50 ] && short="${short}…"
                echo "$short"
            done)
    else
        pr_body="Відкритих PR немає"
    fi

    notify-send \
      --hint=string:x-dunst-stack-tag:github-pr \
      --expire-time=10000 \
      "󰊤  $last_repo — PR ($pr_count)" "$pr_body"

    # 3) Гілки
    branches=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/branches?per_page=10" \
      | jq -r '.[] | "• " + .name')

    notify-send \
      --hint=string:x-dunst-stack-tag:github-branches \
      --expire-time=10000 \
      "󰊤  $last_repo — гілки" "$branches"
}

# ── Точка входу ──────────────────────────────────────────────
case "$1" in
    notify) notify_mode ;;
    *)      waybar_mode ;;
esac
