#!/bin/bash
set -Eeuo pipefail

case "${SERVICE:-gotty}" in
    gotty)
        if [ -z "${GOTTY_CREDENTIAL:-}" ]; then
            echo "[ERROR] GOTTY_CREDENTIAL is required"
            exit 1
        fi

        echo "[GoTTY] Starting web terminal..."

        exec /usr/local/bin/gotty \
            --address 0.0.0.0 \
            --port 8080 \
            --credential "$GOTTY_CREDENTIAL" \
            --permit-write \
            --reconnect \
            /bin/bash
        ;;

    sshx)
        echo "[SSHX] Starting SSHX..."

        exec /usr/local/bin/sshx
        ;;

    *)
        echo "[ERROR] Unknown SERVICE: ${SERVICE}"
        exit 1
        ;;
esac
