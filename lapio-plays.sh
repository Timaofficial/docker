
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
            echo "[ERROR] Set GOTTY_PASSWORD in Render Environment."
            exit 1
        fi

        exec /usr/local/bin/gotty \
            --address 0.0.0.0 \
            --port "${PORT:-8080}" \
            --credential "${GOTTY_USER}:${GOTTY_PASSWORD}" \
            --permit-write \
            --reconnect \
            /bin/bash
        ;;

    sshx)
        echo "[SSHX] Starting..."
        exec /usr/local/bin/sshx --enable-readers
        ;;

    *)
        echo "[ERROR] Unknown SERVICE: $SERVICE"
        exit 1
        ;;
esac
