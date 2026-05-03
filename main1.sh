#!/bin/bash
set -e

LOG="/var/log/bootstrap.log"
mkdir -p /var/log

echo "======================================"
echo "🚀 PIPE-SAFE INSTALLER (FINAL)"
echo "======================================"

pause() {
  echo ""
  read -p "⏸ ENTER to continue..." < /dev/tty
}

download_and_run() {
  URL="$1"
  FILE="$2"

  echo ""
  echo "🌐 Download: $URL"

  HTTP_CODE=$(curl -m 20 --retry 3 -s -o "$FILE" -w "%{http_code}" "$URL")

  if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ HTTP ERROR: $HTTP_CODE"
    exit 1
  fi

  if [ ! -s "$FILE" ]; then
    echo "❌ EMPTY FILE: $FILE"
    exit 1
  fi

  chmod +x "$FILE"

  echo "🚀 Running..."
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

  echo "✅ DONE: $NAME"

  pause
}

# detect non-interactive
if [ ! -t 0 ]; then
  echo "⚠️ Non-interactive mode detected (using /dev/tty for input)"
fi

# STEP 1
run_step "Set time + reboot" \
"https://raw.githubusercontent.com/maxkir041/api-vpn/main/set_time_and_reboot.sh" \
"/tmp/time.sh"

# STEP 2
run_step "Install 3x-ui" \
"https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh" \
"/tmp/xui.sh"

echo ""
echo "======================================"
echo "🎉 INSTALLATION COMPLETE"
echo "LOG: $LOG"
echo "======================================"
