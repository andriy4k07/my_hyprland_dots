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
      "$GH/repos/$USERNAME/$last_repo/commits?per_page=4" \
      | jq -r '.[] | "• " + .commit.message' \
      | while IFS= read -r line; do
            short=$(echo "$line" | cut -c1-50)
            [ ${#line} -gt 50 ] && short="${short}…"
            echo "$short"
        done)

    notify-send --urgency=critical \
      --hint=string:x-dunst-stack-tag:github-commits \
      --expire-time=0 \
      "󰊤  $last_repo — commits" "$commits"

    # 2) PR (відкриті + останні закриті)
    open_prs=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/pulls?state=open&per_page=10" \
      | jq 'length')
    [ -z "$open_prs" ] || [ "$open_prs" = "null" ] && open_prs=0

    closed_count=$(curl -sf --netrc \
          "$GH/repos/$USERNAME/$last_repo/pulls?state=closed&per_page=3" \
          | jq 'length')
        [ -z "$closed_count" ] || [ "$closed_count" = "null" ] && closed_count=0

    closed_prs=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/pulls?state=closed&per_page=3" \
      | jq -r '.[] | "✓ " + .title' \
      | while IFS= read -r line; do
            short=$(echo "$line" | cut -c1-50)
            [ ${#line} -gt 50 ] && short="${short}…"
            echo "$short"
        done)

    if [ "$open_prs" -gt 0 ]; then
        open_body=$(curl -sf --netrc \
          "$GH/repos/$USERNAME/$last_repo/pulls?state=open&per_page=3" \
          | jq -r '.[] | "• " + .title' \
          | while IFS= read -r line; do
                short=$(echo "$line" | cut -c1-50)
                [ ${#line} -gt 50 ] && short="${short}…"
                echo "$short"
            done)
    else
        open_body="No open PRs"
    fi

    pr_body=$(printf "%s\n―――――――――――――――――――\n%s" "$open_body" "$closed_prs")

      notify-send --urgency=critical \
      --hint=string:x-dunst-stack-tag:github-pr \
      --expire-time=0 \
       "󰊤  $last_repo — PR (open: $open_prs) (closed: $closed_count)" "$pr_body"

    # 3) Гілки
    branches=$(curl -sf --netrc \
      "$GH/repos/$USERNAME/$last_repo/branches?per_page=10" \
      | jq -r '.[] | "• " + .name')

    notify-send --urgency=normal \
      --hint=string:x-dunst-stack-tag:github-branches \
      --expire-time=0 \
      "󰊤  $last_repo — branches" "$branches"
}


# ── Точка входу ──────────────────────────────────────────────
case "$1" in
    notify) notify_mode ;;
    *)      waybar_mode ;;
esac
