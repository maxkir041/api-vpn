#!/bin/bash
set -e

SECRET="b1304a83a6a2f83e022cafc38a0edefd"

# Возможные порты
PORTS=(8443 2053 2083 2087 2096)

echo "📦 Проверка Docker..."
if ! command -v docker &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq docker.io >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
    echo "   ✅ Docker установлен"
else
    echo "   ✅ Docker уже есть"
fi

# Получаем IP
IP=$(curl -4 -s ifconfig.me || curl -4 -s icanhazip.com || hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"

# Проверка уже запущенного MTProxy
if docker ps --format '{{.Names}}' | grep -q '^mtproxy$'; then
    echo ""
    echo "❌ Контейнер mtproxy уже запущен!"
    echo "👉 Останови его командой:"
    echo "docker rm -f mtproxy"
    exit 1
fi

echo ""
echo "🔍 Поиск свободного порта..."

PORT=""

for p in "${PORTS[@]}"; do
    # Проверка занят ли порт
    if ss -tuln | grep -q ":$p "; then
        echo "   ⚠️ Порт $p занят"
    else
        PORT=$p
        echo "   ✅ Свободный порт найден: $PORT"
        break
    fi
done

# Если свободных портов нет
if [ -z "$PORT" ]; then
    echo ""
    echo "❌ Все порты заняты!"
    echo "Проверенные порты: ${PORTS[*]}"
    exit 1
fi

echo ""
echo "🚀 Запуск БЕЗ adtag..."

docker run -d \
  --name mtproxy \
  --restart unless-stopped \
  -p ${PORT}:443 \
  -e SECRET=$SECRET \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest >/dev/null

sleep 3

echo ""
echo "📋 Используй это в @MTProxybot:"
echo "${IP}:${PORT}"
echo "${SECRET}"
echo ""
echo "👉 Шаги:"
echo "1. Открой Telegram"
echo "2. Перейди в @MTProxybot"
echo "3. /newproxy"
echo "4. Вставь данные"
echo "5. Получи TAG"
echo ""

read -p "Вставь TAG сюда: " TAG

echo ""
echo "♻️ Перезапуск с adtag..."

docker rm -f mtproxy >/dev/null

docker run -d \
  --name mtproxy \
  --restart unless-stopped \
  -p ${PORT}:443 \
  -e SECRET=$SECRET \
  -e TAG=$TAG \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest >/dev/null

echo ""
echo "===================================="
echo "✅ ГОТОВО"
echo "IP: $IP"
echo "PORT: $PORT"
echo "SECRET: $SECRET"
echo "TAG: $TAG"
echo "===================================="
