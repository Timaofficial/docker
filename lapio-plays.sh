
#!/bin/bash

set -Eeuo pipefail

echo "================================"
echo "          LAPIO PLAYS"
echo "================================"

SERVICE="${SERVICE:-gotty}"

case "$SERVICE" in
    gotty)
        echo "[GoTTY] Starting..."

        if [ -z "${GOTTY_CREDENTIAL:-}" ]; then
            echo "[ERROR] GOTTY_CREDENTIAL is missing"
            exit 1
        fi

        exec /usr/local/bin/gotty \
            --address 0.0.0.0 \
            --port 8080 \
            --credential "$GOTTY_CREDENTIAL" \
            --permit-write \
            --reconnect \
            /bin/bash
        ;;

    sshx)
        echo "[SSHX] Starting..."

        exec /usr/local/bin/sshx
        ;;

    *)
        echo "[ERROR] Unknown service: $SERVICE"
        exit 1
        ;;
esac
