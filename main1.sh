#!/bin/bash
set -e

LOG="/var/log/bootstrap.log"
mkdir -p /var/log
exec > >(tee -a "$LOG") 2>&1

echo "======================================"
echo "🚀 ZERO-BUG INSTALLER"
echo "======================================"

pause() {
  echo ""
  read -p "⏸ Нажми ENTER для продолжения..." < /dev/tty
}

download() {
  URL="$1"
  FILE="$2"

  echo "🌐 Download: $URL"

  HTTP_CODE=$(curl -m 15 --retry 3 --retry-delay 2 -s -o "$FILE" -w "%{http_code}" "$URL")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ HTTP ERROR: $HTTP_CODE"
    exit 1
  fi

  if [ ! -s "$FILE" ]; then
    echo "❌ Файл пустой: $FILE"
    exit 1
  fi

  # Проверка что это bash-скрипт
  if ! head -n 1 "$FILE" | grep -q "bash"; then
    echo "❌ Файл не похож на bash-скрипт"
    exit 1
  fi

  echo "✅ OK (size: $(stat -c%s "$FILE") bytes)"
}

run_step() {
  NAME="$1"
  URL="$2"
  FILE="$3"

  echo ""
  echo "▶️ $NAME"
  echo "--------------------------------------"

  download "$URL" "$FILE"

  echo "🚀 Запуск..."
  bash "$FILE"

  echo "✅ OK: $NAME"
  pause
}

# защита от non-interactive
if [ ! -t 0 ]; then
  echo "⚠️ Non-interactive mode (используем /dev/tty)"
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
echo "🎉 ВСЁ ГОТОВО"
echo "📄 LOG: $LOG"
echo "======================================"
