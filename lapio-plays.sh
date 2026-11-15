
#!/bin/bash
set -Eeuo pipefail

echo "================================"
echo "          LAPIO PLAYS"
echo "================================"

SERVICE="${SERVICE:-gotty}"

case "$SERVICE" in
    gotty)
        echo "[GoTTY] Starting..."

        GOTTY_USER="${GOTTY_USER:-admin}"
        GOTTY_PASSWORD="${GOTTY_PASSWORD:-}"

        if [ -z "$GOTTY_PASSWORD" ]; then
            echo "[ERROR] Set GOTTY_PASSWORD"
            exit 1
        fi

        exec /usr/local/bin/gotty \
            --address 0.0.0.0 \
            --port "${PORT:-10000}" \
            --credential "${GOTTY_USER}:${GOTTY_PASSWORD}" \
            --permit-write \
            --reconnect \
            /bin/bash
        ;;

    sshx)
        echo "[HTTP] Starting health server..."

        python3 -u /health_server.py &
        HEALTH_PID=$!

        echo "[HTTP] PID: $HEALTH_PID"

        for i in {1..20}; do
            if curl -fsS "http://127.0.0.1:${PORT:-10000}/health" >/dev/null; then
                echo "[HTTP] Health server is ready"
                break
            fi
            sleep 1
        done

        if ! kill -0 "$HEALTH_PID" 2>/dev/null; then
            echo "[ERROR] Health server stopped"
            exit 1
        fi

        echo "[SSHX] Starting..."
        exec /usr/local/bin/sshx --enable-readers
        ;;

    *)
        echo "[ERROR] Unknown SERVICE: $SERVICE"
        exit 1
        ;;
esac
