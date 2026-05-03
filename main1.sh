#!/bin/bash
set -e

LOG="/var/log/bootstrap.log"
mkdir -p /var/log
exec > >(tee -a "$LOG") 2>&1

echo "======================================"
echo "🚀 PRO INSTALLER (SAFE MODE)"
echo "======================================"

pause() {
  echo ""
  read -p "⏸ Нажми ENTER для продолжения..." < /dev/tty
}

download_and_run() {
  URL="$1"
  FILE="$2"

  echo "🌐 Downloading: $URL"

  HTTP_CODE=$(curl -s -o "$FILE" -w "%{http_code}" "$URL")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Ошибка загрузки ($HTTP_CODE): $URL"
    exit 1
  fi

  echo "▶️ Запуск $FILE"
  bash "$FILE"
}

run_step() {
  NAME="$1"
  URL="$2"
  FILE="$3"

  echo ""
  echo "▶️ $NAME"
  echo "--------------------------------------"

  download_and_run "$URL" "$FILE"

  echo "✅ OK: $NAME"
  pause
}

# Проверка TTY
if [ ! -t 0 ]; then
  echo "⚠️ Non-interactive mode detected (OK, using /dev/tty)"
fi

# STEP 1
run_step "Set time + reboot" \
"https://raw.githubusercontent.com/maxkir041/api-vpn/main/set_time_and_reboot.sh" \
"/tmp/set_time.sh"

# STEP 2
run_step "Install 3x-ui panel" \
"https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh" \
"/tmp/3x-ui.sh"

echo ""
echo "======================================"
echo "🎉 INSTALLATION COMPLETED"
echo "📄 LOG: $LOG"
echo "======================================"
