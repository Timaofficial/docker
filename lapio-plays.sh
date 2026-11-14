#!/bin/bash

# Скачиваем и распаковываем sshx напрямую в /usr/local/bin, если его там еще нет
if [ ! -f /usr/local/bin/sshx ]; then
    curl -sSfL https://amazonaws.com | tar -xz -C /usr/local/bin
    chmod +x /usr/local/bin/sshx
fi

# Запускаем sshx в фоне с автоперезапуском и выводом ссылки в логи
(while true; do /usr/local/bin/sshx; sleep 5; done) &

# Запускаем GoTTY на основном порту для удержания веб-сервера и пингов
/usr/local/bin/gotty --permit-write --reconnect /bin/bash
