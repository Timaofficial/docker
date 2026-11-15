
#!/bin/bash
set -Eeuo pipefail

echo "================================"
echo "          LAPIO PLAYS"
echo "================================"

SERVICE="${SERVICE:-gotty}"
PORT="${PORT:-10000}"

case "$SERVICE" in
    gotty)
        echo "[GoTTY] Starting..."

        GOTTY_USER="${GOTTY_USER:-admin}"
        GOTTY_PASSWORD="${GOTTY_PASSWORD:-}"

        if [ -z "$GOTTY_PASSWORD" ]; then
            echo "[ERROR] Set GOTTY_PASSWORD in Render Environment."
            exit 1
        fi

        exec /usr/local/bin/gotty \
            --address 0.0.0.0 \
            --port "$PORT" \
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

        READY=0

        for i in {1..20}; do
            if ! kill -0 "$HEALTH_PID" 2>/dev/null; then
                echo "[ERROR] Health server process stopped."
                exit 1
            fi

            if curl -fsS "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
                READY=1
                break
            fi

            sleep 1
        done

        if [ "$READY" -ne 1 ]; then
            echo "[ERROR] Health server did not become ready."
            exit 1
        fi

        echo "[HTTP] Health server is ready"
        echo "[SSHX] Starting..."

        exec /usr/local/bin/sshx \
            --enable-readers \
            --shell /bin/bash
        ;;

    *)
        echo "[ERROR] Unknown SERVICE: $SERVICE"
        exit 1
        ;;
esac
