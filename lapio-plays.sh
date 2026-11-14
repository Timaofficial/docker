#!/bin/bash

# Скачиваем и устанавливаем sshx, если его еще нет в контейнере
if ! command -v sshx &> /dev/null; then
    curl -sSf https://sshx.io/get | sh
fi

# Запускаем sshx в фоне с переподключением и выводим ссылку в логи Render
(while true; do sshx; sleep 5; done) &

# Запускаем GoTTY на основном порту, чтобы Render и cron-job.org видели активный веб-сервер
/usr/local/bin/gotty --permit-write --reconnect /bin/bash
