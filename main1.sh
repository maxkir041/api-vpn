#!/bin/bash
set -e

LOG="/var/log/bootstrap.log"
mkdir -p /var/log
exec > >(tee -a "$LOG") 2>&1

echo "======================================"
echo "🚀 ANTI-HANG INSTALLER"
echo "======================================"

pause() {
  echo ""
  read -p "⏸ Нажми ENTER для продолжения..." < /dev/tty
}

download() {
  URL="$1"
  FILE="$2"

  echo "🌐 Пробую скачать: $URL"

  HTTP_CODE=$(curl -m 15 --retry 3 --retry-delay 2 -s -o "$FILE" -w "%{http_code}" "$URL")

  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ OK (GitHub)"
    return 0
  fi

  echo "⚠️ GitHub не ответил ($HTTP_CODE), пробую CDN..."

  # fallback через jsdelivr
  CDN_URL=$(echo "$URL" | sed 's#raw.githubusercontent.com#cdn.jsdelivr.net/gh#; s#/main/#@main/#')

  HTTP_CODE=$(curl -m 15 --retry 2 -s -o "$FILE" -w "%{http_code}" "$CDN_URL")

  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ OK (CDN fallback)"
    return 0
  fi

  echo "❌ Ошибка загрузки: $URL"
  exit 1
}

run_step() {
  NAME="$1"
  URL="$2"
  FILE="$3"

  echo ""
  echo "▶️ $NAME"
  echo "--------------------------------------"

  download "$URL" "$FILE"

  echo "🚀 Запуск $FILE"
  bash "$FILE"

  echo "✅ OK: $NAME"
  pause
}

# защита от non-interactive
if [ ! -t 0 ]; then
  echo "⚠️ Non-interactive mode detected (используется /dev/tty)"
fi

# STEP 1
run_step "Set time + reboot" \
"https://raw.githubusercontent.com/maxkir041/api-vpn/main/set_time_and_reboot.sh" \
"/tmp/set_time.sh"

# STEP 2
run_step "Install 3x-ui panel" \
"https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh" \
"/tmp/xui.sh"

echo ""
echo "======================================"
echo "🎉 DONE WITHOUT HANGS"
echo "📄 LOG: $LOG"
echo "======================================"
