#!/bin/bash
set -e

LOG="/var/log/bootstrap.log"
mkdir -p /var/log

exec > >(tee -a "$LOG") 2>&1

echo "======================================"
echo "🚀 PRO BOOTSTRAP INSTALLER START"
echo "======================================"

pause() {
  echo ""
  read -p "⏸ Нажми ENTER для продолжения..." < /dev/tty
}

run_step() {
  STEP_NAME="$1"
  COMMAND="$2"

  echo ""
  echo "▶️ $STEP_NAME"
  echo "--------------------------------------"

  if eval "$COMMAND"; then
    echo "✅ OK: $STEP_NAME"
  else
    echo "❌ ERROR: $STEP_NAME"
    exit 1
  fi

  pause
}

check_tty() {
  if [ ! -t 0 ]; then
    echo "⚠️ Non-interactive mode detected"
    echo "👉 forcing input from /dev/tty"
  fi
}

check_tty

# STEP 1
run_step "Set time + reboot script" \
"bash <(curl -fsSL https://raw.githubusercontent.com/maxkir041/api-vpn/refs/heads/main/set_time_and_reboot.sh)"

# STEP 2
run_step "Install MTProto proxy" \
"bash <(curl -fsSL https://raw.githubusercontent.com/maxkir041/api-vpn/refs/heads/main/install_mtproto.sh)"

# STEP 3
run_step "Install 3x-ui panel" \
"bash <(curl -fsSL https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)"

echo ""
echo "======================================"
echo "🎉 INSTALLATION COMPLETED SUCCESSFULLY"
echo "📄 LOG: $LOG"
echo "======================================"
