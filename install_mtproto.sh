#!/bin/bash
set -e

SECRET="b1304a83a6a2f83e022cafc38a0edefd"

echo "📦 Проверка Docker..."
if ! command -v docker &>/dev/null; then
    apt-get update -qq
    apt-get install -y -qq docker.io >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
    echo "   ✅ Docker установлен"
else
    echo "   ✅ Docker уже есть"
fi

# IP
IP=$(curl -4 -s ifconfig.me || curl -4 -s icanhazip.com || hostname -I | awk '{print $1}')
echo "🌐 IP: $IP"

# Удаляем старый контейнер
docker rm -f mtproxy 2>/dev/null || true

echo ""
echo "🚀 Запуск БЕЗ adtag (получаем ссылку)..."

docker run -d \
  --name mtproxy \
  --restart unless-stopped \
  -p 8443:443 \
  -e SECRET=$SECRET \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest >/dev/null

sleep 3

echo ""
echo "📋 Используй это в @MTProxybot:"
echo "${IP}:8443"
echo "${SECRET}"
echo ""
echo "👉 Шаги:"
echo "1. Открой @MTProxybot"
echo "2. /newproxy"
echo "3. Вставь необходимые данные"
echo "4. Получи TAG"
echo ""

read -p "Вставь TAG сюда: " TAG

echo "♻️ Перезапуск с adtag..."

docker rm -f mtproxy

docker run -d \
  --name mtproxy \
  --restart unless-stopped \
  -p 8443:443 \
  -e SECRET=$SECRET \
  -e TAG=$TAG \
  -v proxy-config:/data \
  telegrammessenger/proxy:latest >/dev/null

echo ""
echo "===================================="
echo "✅ ГОТОВО"
echo "IP: $IP"
echo "PORT: 8443"
echo "SECRET: $SECRET"
echo "TAG: $TAG"
echo "===================================="
