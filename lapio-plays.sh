
#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# LAPIO PLAYS
# Docker Terminal Launcher
# GoTTY + SSHX + HTTP Health Server
# ==========================================

SERVICE="${SERVICE:-gotty}"
PORT="${PORT:-10000}"

HEALTH_SERVER="/health_server.py"
GOTTY_BIN="/usr/local/bin/gotty"
SSHX_BIN="/usr/local/bin/sshx"

HEALTH_PID=""

log() {
    echo "[LAPIO] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

cleanup() {
    if [[ -n "${HEALTH_PID}" ]]; then
        log "Stopping health server..."
        kill "${HEALTH_PID}" 2>/dev/null || true
        wait "${HEALTH_PID}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

check_binary() {
    if [[ ! -x "$1" ]]; then
        error "Executable not found: $1"
        exit 1
    fi
}

start_health_server() {
    log "Starting HTTP health server..."

    if [[ ! -f "$HEALTH_SERVER" ]]; then
        error "Missing file: $HEALTH_SERVER"
        exit 1
    fi

    python3 -u "$HEALTH_SERVER" &
    HEALTH_PID=$!

    log "Health server PID: $HEALTH_PID"

    for attempt in {1..30}; do
        if ! kill -0 "$HEALTH_PID" 2>/dev/null; then
            error "Health server process stopped."
            wait "$HEALTH_PID" || true
            exit 1
        fi

        if curl -fsS \
            "http://127.0.0.1:${PORT}/health" \
            >/dev/null 2>&1; then

            log "Health server is ready on port ${PORT}"
            return 0
        fi

        sleep 1
    done

    error "Health server did not become ready."
    exit 1
}

start_gotty() {
    log "Starting GoTTY..."

    check_binary "$GOTTY_BIN"

    local username="${GOTTY_USER:-admin}"
    local password="${GOTTY_PASSWORD:-}"

    if [[ -z "$password" ]]; then
        error "GOTTY_PASSWORD is not configured."
        exit 1
    fi

    exec "$GOTTY_BIN" \
        --address 0.0.0.0 \
        --port "$PORT" \
        --credential "${username}:${password}" \
        --permit-write \
        --reconnect \
        /bin/bash
}

start_sshx() {
    log "Starting SSHX mode..."

    check_binary "$SSHX_BIN"

    start_health_server

    log "Starting SSHX terminal..."

    exec "$SSHX_BIN" \
        --enable-readers \
        --shell /bin/bash
}

main() {
    echo
    echo "================================"
    echo "          LAPIO PLAYS"
    echo "================================"
    echo

    log "Service: ${SERVICE}"
    log "Port: ${PORT}"

    case "$SERVICE" in
        gotty)
            start_gotty
            ;;

        sshx)
            start_sshx
            ;;

        *)
            error "Unknown SERVICE: ${SERVICE}"
            error "Available services: gotty, sshx"
            exit 1
            ;;
    esac
}

main "$@"
