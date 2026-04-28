#!/bin/bash
# ============================================
#  MTProto Proxy — установка одной командой
# ============================================
set -e

echo ""
echo "🛡  Установка MTProto Proxy для Telegram"
echo "========================================="
echo ""

# 1. Docker
if ! command -v docker &>/dev/null; then
    echo "📦 Устанавливаю Docker..."
    apt-get update -qq
    apt-get install -y -qq docker.io >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
    echo "   ✅ Docker установлен"
else
    echo "   ✅ Docker уже установлен"
fi

# 2. Генерируем fake-TLS секрет
# Формат: ee + b1304a83a6a2f83e022cafc38a0edefd + 7mpNQIygFFNIF3DCdG2Z0ep3d3cuaWNsb3VkLmNvbQ (www.icloud.com)
SECRET="eeb1304a83a6a2f83e022cafc38a0edefd7mpNQIygFFNIF3DCdG2Z0ep3d3cuaWNsb3VkLmNvbQ"
echo "🔑 Сгенерирован fake-TLS секрет"

# 3. Определяем IP (принудительно IPv4)
IP=$(curl -4 -s ifconfig.me || curl -4 -s icanhazip.com || hostname -I | awk '{print $1}')
echo "🌐 IP сервера: $IP"

# 4. Создаём конфиг
mkdir -p /opt/mtg
cat > /opt/mtg/config.toml <<EOF
secret = "${SECRET}"
bind-to = "0.0.0.0:3128"
prefer-ip = "prefer-ipv4"
allow-fallback-on-unknown-dc = true
concurrency = 8192
tolerate-time-skewness = "5s"

[network]
doh-ip = "1.1.1.1"

[network.timeout]
tcp = "10s"
http = "10s"
idle = "60s"
EOF

# 5. Останавливаем старый контейнер (если есть)
docker rm -f mtg 2>/dev/null || true

# 6. Запускаем
echo "🚀 Запускаю прокси..."
docker run -d \
    --name mtg \
    --restart always \
    -p 8443:3128 \
    -v /opt/mtg/config.toml:/config.toml:ro \
    nineseconds/mtg:2 run /config.toml >/dev/null

sleep 2

# 7. Проверка
if docker ps | grep -q mtg; then
    echo "   ✅ Прокси запущен"
else
    echo "   ❌ Ошибка запуска! Логи:"
    docker logs mtg
    exit 1
fi

# 8. Формируем ссылку
LINK="https://t.me/proxy?server=${IP}&port=8443&secret=${SECRET}"

echo ""
echo "========================================="
echo "✅ Готово! Ваш прокси работает."
echo ""
echo "📎 Ссылка для подключения:"
echo ""
echo "   $LINK"
echo ""
echo "Отправьте эту ссылку в Telegram и нажмите"
echo "«Подключить прокси»."
echo "========================================="
