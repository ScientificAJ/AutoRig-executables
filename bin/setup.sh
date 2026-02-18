#!/usr/bin/env bash
set -Eeuo pipefail

# AutoRig Distribution Setup Helper
#
# This repository ships prebuilt artifacts (CLI binary + Blender add-on).
# No Python/Node installation is required.
#
# EXPERIMENTAL: pass --geometric to launch the "Draw -> Recognize -> Correct" UI.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CLI_BIN="${ROOT_DIR}/bin/autorig_cli-linux-x86_64"

HOST="${AUTORIG_API_HOST:-127.0.0.1}"
PORT="${AUTORIG_API_PORT:-8000}"
GEOMETRIC=0
NO_OPEN=0

usage() {
  cat <<USAGE
Usage: $(basename "$0") [options]

Options:
  --host <host>        Bind host for local API server (default: ${HOST}).
  --port <port>        Bind port for local API server (default: ${PORT}).
  --geometric          Launch EXPERIMENTAL geometric inference drawing UI.
  --no-open            Do not auto-open the browser window.
  -h, --help           Show this help.

Examples:
  # Run API server (Swagger docs at /docs)
  bash ./bin/setup.sh --host 127.0.0.1 --port 8000

  # EXPERIMENTAL: open the drawing window and run geometric inference rigs
  bash ./bin/setup.sh --geometric
USAGE
}

parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --host)
        HOST="${2:-}"
        [[ -n "$HOST" ]] || { echo "Missing value for --host" >&2; exit 2; }
        shift
        ;;
      --port)
        PORT="${2:-}"
        [[ "$PORT" =~ ^[0-9]+$ ]] || { echo "Invalid port: $PORT" >&2; exit 2; }
        shift
        ;;
      --geometric)
        GEOMETRIC=1
        ;;
      --no-open)
        NO_OPEN=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage
        exit 2
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if [[ ! -x "$CLI_BIN" ]]; then
    echo "Missing CLI binary: $CLI_BIN" >&2
    echo "Verify your checkout includes bin/autorig_cli-linux-x86_64" >&2
    exit 2
  fi

  if [[ "$GEOMETRIC" -eq 1 ]]; then
    # `geometric-ui` sets AUTORIG_ENABLE_GEOMETRIC_AUTORIG=1 internally.
    if [[ "$NO_OPEN" -eq 1 ]]; then
      exec "$CLI_BIN" geometric-ui --host "$HOST" --port "$PORT" --no-open
    fi
    exec "$CLI_BIN" geometric-ui --host "$HOST" --port "$PORT"
  fi

  echo "Starting AutoRig API server..." >&2

  OPEN_HOST="$HOST"
  if [[ "$OPEN_HOST" == "0.0.0.0" || "$OPEN_HOST" == "::" ]]; then
    OPEN_HOST="127.0.0.1"
  fi
  if [[ "$OPEN_HOST" == *:* && "$OPEN_HOST" != \\[* ]]; then
    OPEN_HOST="[$OPEN_HOST]"
  fi

  echo "Open: http://${OPEN_HOST}:${PORT}/docs" >&2
  echo "Health: http://${OPEN_HOST}:${PORT}/healthz" >&2
  echo "Stop: Ctrl+C" >&2

  exec "$CLI_BIN" server --host "$HOST" --port "$PORT"
}

main "$@"
