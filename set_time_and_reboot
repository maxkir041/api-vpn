#!/bin/bash
set -e

echo "🌍 Установка timezone Europe/Samara..."

# 1. Установка часового пояса
timedatectl set-timezone Europe/Samara

echo "   ✅ Timezone установлен: $(timedatectl | grep 'Time zone')"

# 2. Включаем NTP синхронизацию времени
echo "⏱ Включение синхронизации времени..."
timedatectl set-ntp true

echo "   ✅ NTP включён"

# 3. Создаём cron задачу на перезагрузку в 04:00
echo "🔁 Настройка автоматической перезагрузки в 04:00..."

CRON_JOB="0 4 * * * /sbin/shutdown -r now"

# Проверяем есть ли уже такая строка
( crontab -l 2>/dev/null | grep -v -F "$CRON_JOB" ; echo "$CRON_JOB" ) | crontab -

echo "   ✅ Cron добавлен"

# 4. Проверка
echo ""
echo "===================================="
echo "📌 Готово!"
echo "Timezone: Europe/Samara"
echo "Reboot: каждый день в 04:00"
echo "===================================="

timedatectl
