#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BINARY_PATH="${BINARY_PATH:-$REPO_ROOT/bin/autorig_cli-linux-x86_64}"
CHECKSUM_FILE="${CHECKSUM_FILE:-$REPO_ROOT/SHA256SUMS}"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8000}"
RUN_SERVER=0
SKIP_CHECKSUM=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

usage() {
  cat <<EOF
AutoRig executable setup helper

Usage:
  bash bin/setup.sh [options]

Options:
  --run                 Start API server after setup
  --host <host>         Server host (default: 127.0.0.1)
  --port <port>         Server port (default: 8000)
  --skip-checksum       Skip SHA256 verification
  -h, --help            Show this help

Examples:
  bash bin/setup.sh
  bash bin/setup.sh --run --host 127.0.0.1 --port 8000
EOF
}

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "Missing required command: $cmd"
    return 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)
      RUN_SERVER=1
      shift
      ;;
    --host)
      HOST="$2"
      shift 2
      ;;
    --port)
      PORT="$2"
      shift 2
      ;;
    --skip-checksum)
      SKIP_CHECKSUM=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

info "Repository root: $REPO_ROOT"
info "Binary path: $BINARY_PATH"

if [[ ! -f "$BINARY_PATH" ]]; then
  error "Binary not found: $BINARY_PATH"
  error "Expected file: bin/autorig_cli-linux-x86_64"
  exit 1
fi

chmod +x "$BINARY_PATH"
success "Binary executable permission ensured"

if [[ "$SKIP_CHECKSUM" -eq 0 ]]; then
  if [[ ! -f "$CHECKSUM_FILE" ]]; then
    warn "Checksum file not found: $CHECKSUM_FILE (continuing)"
  else
    require_cmd sha256sum
    info "Verifying artifact checksums..."
    (
      cd "$REPO_ROOT"
      sha256sum -c "$CHECKSUM_FILE"
    )
    success "Checksum verification passed"
  fi
else
  warn "Checksum verification skipped"
fi

require_cmd "$BINARY_PATH"

info "CLI check:"
"$BINARY_PATH" --help | sed -n '1,8p'

echo
success "Setup completed"
info "Run API server manually with:"
echo "  $BINARY_PATH server --host $HOST --port $PORT"
info "Then open:"
echo "  http://$HOST:$PORT/docs"
echo "  http://$HOST:$PORT/healthz"

if [[ "$RUN_SERVER" -eq 1 ]]; then
  echo
  info "Starting AutoRig API server..."
  exec "$BINARY_PATH" server --host "$HOST" --port "$PORT"
fi
