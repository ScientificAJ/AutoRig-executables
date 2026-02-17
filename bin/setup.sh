#!/usr/bin/env bash
set -Eeuo pipefail

# =========================
# Global Configuration
# =========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${PROJECT_ROOT:-$SCRIPT_DIR}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

BACKEND_DIR="${BACKEND_DIR:-$PROJECT_ROOT/services/api}"
FRONTEND_DIR="${FRONTEND_DIR:-$PROJECT_ROOT/apps/web}"
LOG_FILE="${LOG_FILE:-$PROJECT_ROOT/setup.log}"

MODE="dev"
REQUESTED_FRONTEND_PORT="${REQUESTED_FRONTEND_PORT:-3000}"
REQUESTED_BACKEND_PORT="${REQUESTED_BACKEND_PORT:-8000}"

BACKEND_PORT=""
FRONTEND_PORT=""
BACKEND_PID=""
FRONTEND_PID=""
VENV_PATH=""
APT_UPDATED=0
INTERRUPTED=0

# =========================
# Colors and Logging
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() {
  echo -e "${BLUE}[INFO]${NC} $*" >&2
}

success() {
  echo -e "${GREEN}[OK]${NC} $*" >&2
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

error() {
  echo -e "${RED}[ERROR]${NC} $*" >&2
}

section() {
  echo >&2
  echo -e "${BLUE}========== $* ==========${NC}" >&2
}

init_logging() {
  mkdir -p "$(dirname "$LOG_FILE")"
  : > "$LOG_FILE"
  exec > >(tee -a "$LOG_FILE") 2>&1
}

# =========================
# Utility Functions
# =========================
run_as_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    if ! command -v sudo >/dev/null 2>&1; then
      error "sudo is required to install system dependencies."
      exit 1
    fi
    sudo "$@"
  fi
}

version_ge() {
  local current="$1"
  local minimum="$2"
  [[ "$(printf '%s\n%s\n' "$minimum" "$current" | sort -V | head -n1)" == "$minimum" ]]
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

sha256_file() {
  local file="$1"
  if command_exists sha256sum; then
    sha256sum "$file" | awk '{print $1}'
  else
    shasum -a 256 "$file" | awk '{print $1}'
  fi
}

sha256_text() {
  local text="$1"
  if command_exists sha256sum; then
    printf '%s' "$text" | sha256sum | awk '{print $1}'
  else
    printf '%s' "$text" | shasum -a 256 | awk '{print $1}'
  fi
}

add_pkg_once() {
  local pkg="$1"
  local existing
  for existing in "${APT_PACKAGES[@]:-}"; do
    if [[ "$existing" == "$pkg" ]]; then
      return
    fi
  done
  APT_PACKAGES+=("$pkg")
}

apt_update_once() {
  if [[ "$APT_UPDATED" -eq 0 ]]; then
    info "Running apt-get update..."
    if ! run_as_root apt-get update; then
      error "apt-get update failed."
      exit 1
    fi
    APT_UPDATED=1
  fi
}

apt_install() {
  local packages=("$@")
  if [[ "${#packages[@]}" -eq 0 ]]; then
    return
  fi

  apt_update_once
  info "Installing packages via apt: ${packages[*]}"
  if ! run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"; then
    error "Failed to install packages: ${packages[*]}"
    exit 1
  fi
}

is_port_in_use() {
  local port="$1"

  if command_exists ss; then
    if ss -H -ltn 2>/dev/null | awk -v needle=":$port" '$4 ~ needle"$" {found=1} END {exit(found ? 0 : 1)}'; then
      return 0
    fi
  fi

  if command_exists lsof; then
    if lsof -iTCP:"$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
      return 0
    fi
  fi

  return 1
}

port_owner() {
  local port="$1"
  lsof -iTCP:"$port" -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR==2 {print $1 " (PID " $2 ")"}' || true
}

resolve_port() {
  local requested="$1"
  local service_name="$2"
  local chosen="$requested"

  while is_port_in_use "$chosen"; do
    local owner
    owner="$(port_owner "$chosen")"
    warn "$service_name port $chosen is in use${owner:+ by $owner}."
    chosen=$((chosen + 1))
  done

  if [[ "$chosen" != "$requested" ]]; then
    warn "$service_name will use fallback port $chosen."
  else
    success "$service_name port $chosen is available."
  fi

  echo "$chosen"
}

wait_for_port() {
  local port="$1"
  local timeout="$2"
  local elapsed=0

  while (( elapsed < timeout )); do
    if is_port_in_use "$port"; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  return 1
}

wait_for_http() {
  local url="$1"
  local timeout="$2"
  local elapsed=0

  while (( elapsed < timeout )); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done

  return 1
}

stop_process() {
  local pid="$1"
  local name="$2"

  if [[ -n "$pid" ]] && kill -0 "$pid" >/dev/null 2>&1; then
    warn "Stopping $name (PID $pid)..."
    kill "$pid" >/dev/null 2>&1 || true
    wait "$pid" >/dev/null 2>&1 || true
  fi
}

# =========================
# Trap Handlers
# =========================
handle_error() {
  local exit_code="$1"
  local line="$2"
  local cmd="$3"
  set +e
  error "Critical failure at line $line (exit $exit_code): $cmd"
  exit "$exit_code"
}

handle_interrupt() {
  INTERRUPTED=1
  warn "Interrupt received. Shutting down gracefully..."
  exit 130
}

cleanup() {
  local exit_code=$?

  stop_process "$FRONTEND_PID" "frontend server"
  stop_process "$BACKEND_PID" "backend server"

  if [[ "$INTERRUPTED" -eq 1 ]]; then
    warn "Stopped by user."
  elif [[ "$exit_code" -eq 0 ]]; then
    success "Setup completed successfully."
  else
    error "Setup exited with code $exit_code. See $LOG_FILE for details."
  fi
}

trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR
trap handle_interrupt INT TERM
trap cleanup EXIT

# =========================
# Argument Parsing
# =========================
usage() {
  cat <<USAGE
Usage: $(basename "$0") [--dev|--prod|--mode <dev|prod>] [--frontend-port <port>] [--backend-port <port>]

Options:
  --dev                 Start frontend in development mode (default).
  --prod                Start frontend in production mode (build + start).
  --mode <dev|prod>     Explicitly set mode.
  --frontend-port <n>   Preferred frontend port (default: 3000).
  --backend-port <n>    Preferred backend port (default: 8000).
  -h, --help            Show this help.
USAGE
}

parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --dev)
        MODE="dev"
        ;;
      --prod)
        MODE="prod"
        ;;
      --mode)
        if [[ "$#" -lt 2 ]]; then
          error "Missing value for --mode"
          exit 1
        fi
        MODE="$2"
        shift
        ;;
      --frontend-port)
        if [[ "$#" -lt 2 ]]; then
          error "Missing value for --frontend-port"
          exit 1
        fi
        REQUESTED_FRONTEND_PORT="$2"
        shift
        ;;
      --backend-port)
        if [[ "$#" -lt 2 ]]; then
          error "Missing value for --backend-port"
          exit 1
        fi
        REQUESTED_BACKEND_PORT="$2"
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
    shift
  done

  if [[ "$MODE" != "dev" && "$MODE" != "prod" ]]; then
    error "Invalid mode: $MODE. Use 'dev' or 'prod'."
    exit 1
  fi

  if ! [[ "$REQUESTED_FRONTEND_PORT" =~ ^[0-9]+$ ]] || ! [[ "$REQUESTED_BACKEND_PORT" =~ ^[0-9]+$ ]]; then
    error "Ports must be numeric."
    exit 1
  fi
}

# =========================
# Dependency Check Section
# =========================
validate_os() {
  section "Dependency Check"

  if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect OS. /etc/os-release is missing."
    exit 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  if [[ "${ID:-}" != "ubuntu" ]]; then
    error "This script only supports Ubuntu 22.04+ (detected: ${ID:-unknown})."
    exit 1
  fi

  if ! version_ge "${VERSION_ID:-0}" "22.04"; then
    error "Ubuntu 22.04+ is required (detected: ${VERSION_ID:-unknown})."
    exit 1
  fi

  success "OS check passed: Ubuntu ${VERSION_ID}"
}

install_missing_system_tools() {
  section "Installation"

  if ! command_exists apt-get; then
    error "apt-get is required but not available."
    exit 1
  fi

  if [[ "$EUID" -ne 0 ]] && ! command_exists sudo; then
    error "sudo is required to install missing dependencies."
    exit 1
  fi

  declare -ga APT_PACKAGES=()

  # Base utilities needed by this script.
  command_exists curl || add_pkg_once curl
  command_exists git || add_pkg_once git
  command_exists lsof || add_pkg_once lsof

  # Python tools.
  if ! command_exists python3; then
    add_pkg_once python3
    add_pkg_once python3-venv
    add_pkg_once python3-pip
  else
    python3 -c 'import venv' >/dev/null 2>&1 || add_pkg_once python3-venv
    if ! command_exists pip && ! command_exists pip3; then
      add_pkg_once python3-pip
    fi
  fi

  if [[ "${#APT_PACKAGES[@]}" -gt 0 ]]; then
    apt_install "${APT_PACKAGES[@]}"
  else
    success "No missing base apt packages detected."
  fi

  # Node.js + npm check and install/upgrade when necessary.
  local needs_node=0
  if ! command_exists node || ! command_exists npm; then
    needs_node=1
  else
    local node_version
    node_version="$(node -v | sed 's/^v//')"
    if ! version_ge "$node_version" "18.0.0"; then
      needs_node=1
      warn "Detected Node.js $node_version (< 18.0.0). Upgrade required."
    fi
  fi

  if [[ "$needs_node" -eq 1 ]]; then
    warn "Installing Node.js 20.x (includes npm) using NodeSource APT repository..."
    apt_install ca-certificates gnupg

    if [[ "$EUID" -eq 0 ]]; then
      if ! curl -fsSL https://deb.nodesource.com/setup_20.x | bash -; then
        error "Failed to configure NodeSource repository."
        exit 1
      fi
    else
      if ! curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -; then
        error "Failed to configure NodeSource repository."
        exit 1
      fi
    fi

    apt_install nodejs
  fi

  # Final hard checks for required tools.
  command_exists node || { error "node is missing after installation."; exit 1; }
  command_exists npm || { error "npm is missing after installation."; exit 1; }
  command_exists python3 || { error "python3 is missing after installation."; exit 1; }
  command_exists git || { error "git is missing after installation."; exit 1; }

  if ! command_exists pip && ! command_exists pip3; then
    error "pip is missing after installation (pip or pip3 expected)."
    exit 1
  fi

  local final_node_version
  final_node_version="$(node -v | sed 's/^v//')"
  if ! version_ge "$final_node_version" "18.0.0"; then
    error "Node.js >= 18 required. Found: $final_node_version"
    exit 1
  fi

  local final_python_version
  final_python_version="$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')"
  if ! version_ge "$final_python_version" "3.10.0"; then
    error "Python >= 3.10 required. Found: $final_python_version"
    exit 1
  fi

  success "Tooling ready: Node $final_node_version, Python $final_python_version"
}

# =========================
# Environment Setup Section
# =========================
validate_project_layout() {
  section "Environment Setup"

  if [[ ! -d "$BACKEND_DIR" ]]; then
    error "Backend directory not found: $BACKEND_DIR"
    exit 1
  fi

  if [[ ! -f "$BACKEND_DIR/requirements.txt" ]]; then
    error "Backend requirements file missing: $BACKEND_DIR/requirements.txt"
    exit 1
  fi

  if [[ ! -d "$FRONTEND_DIR" ]]; then
    error "Frontend directory not found: $FRONTEND_DIR"
    exit 1
  fi

  if [[ ! -f "$FRONTEND_DIR/package.json" ]]; then
    error "Frontend package file missing: $FRONTEND_DIR/package.json"
    exit 1
  fi

  success "Project layout validated."
}

setup_python_environment() {
  VENV_PATH="$BACKEND_DIR/.venv"

  if [[ ! -d "$VENV_PATH" ]]; then
    info "Creating Python virtual environment at $VENV_PATH"
    if ! python3 -m venv "$VENV_PATH"; then
      error "Failed to create Python virtual environment."
      exit 1
    fi
  else
    success "Python virtual environment already exists: $VENV_PATH"
  fi

  local venv_pip="$VENV_PATH/bin/pip"
  if [[ ! -x "$venv_pip" ]]; then
    error "pip not found in virtual environment: $venv_pip"
    exit 1
  fi

  local req_file="$BACKEND_DIR/requirements.txt"
  local req_hash
  req_hash="$(sha256_file "$req_file")"
  local req_stamp="$VENV_PATH/.requirements.sha256"

  if [[ -f "$req_stamp" ]] && [[ -x "$VENV_PATH/bin/uvicorn" ]] && [[ "$(cat "$req_stamp")" == "$req_hash" ]]; then
    success "Backend dependencies unchanged; skipping reinstall."
    return
  fi

  info "Installing backend dependencies from requirements.txt"
  "$venv_pip" install -r "$req_file"
  printf '%s\n' "$req_hash" > "$req_stamp"
  success "Backend dependencies installed/updated."
}

setup_frontend_environment() {
  local pkg_json="$FRONTEND_DIR/package.json"
  local lock_json="$FRONTEND_DIR/package-lock.json"
  local dep_state=""
  local dep_hash=""
  local dep_stamp="$FRONTEND_DIR/node_modules/.deps.sha256"

  dep_state+="pkg:$(sha256_file "$pkg_json")"
  if [[ -f "$lock_json" ]]; then
    dep_state+="|lock:$(sha256_file "$lock_json")"
  fi
  dep_hash="$(sha256_text "$dep_state")"

  if [[ -d "$FRONTEND_DIR/node_modules" ]] && [[ -x "$FRONTEND_DIR/node_modules/.bin/next" ]] && [[ -f "$dep_stamp" ]] && [[ "$(cat "$dep_stamp")" == "$dep_hash" ]]; then
    success "Frontend dependencies unchanged; skipping reinstall."
  else
    info "Installing frontend dependencies from package.json"
    if [[ -f "$lock_json" ]]; then
      npm --prefix "$FRONTEND_DIR" ci
    else
      npm --prefix "$FRONTEND_DIR" install
    fi
    mkdir -p "$FRONTEND_DIR/node_modules"
    printf '%s\n' "$dep_hash" > "$dep_stamp"
    success "Frontend dependencies installed/updated."
  fi

  # Build frontend only when needed (production mode).
  if [[ "$MODE" == "prod" ]]; then
    info "Building frontend for production"
    npm --prefix "$FRONTEND_DIR" run build
    success "Frontend build completed."
  else
    warn "Development mode selected; skipping production build."
  fi
}

# =========================
# Server Startup Section
# =========================
start_backend_server() {
  BACKEND_PORT="$(resolve_port "$REQUESTED_BACKEND_PORT" "Backend")"

  local -a backend_cmd=("$VENV_PATH/bin/uvicorn" "app.main:app" "--host" "0.0.0.0" "--port" "$BACKEND_PORT")
  if [[ "$MODE" == "dev" ]]; then
    backend_cmd+=("--reload")
  fi

  info "Starting backend server on port $BACKEND_PORT"
  (
    cd "$BACKEND_DIR"
    "${backend_cmd[@]}"
  ) &
  BACKEND_PID=$!

  if ! wait_for_port "$BACKEND_PORT" 30; then
    error "Backend server failed to bind to port $BACKEND_PORT within timeout."
    exit 1
  fi

  if ! wait_for_http "http://127.0.0.1:${BACKEND_PORT}/healthz" 30; then
    error "Backend health check failed at /healthz."
    exit 1
  fi

  success "Backend server is healthy at http://127.0.0.1:${BACKEND_PORT}"
}

start_frontend_server() {
  FRONTEND_PORT="$(resolve_port "$REQUESTED_FRONTEND_PORT" "Frontend")"

  local frontend_script="dev"
  if [[ "$MODE" == "prod" ]]; then
    frontend_script="start"
  fi

  info "Starting frontend (${MODE}) on port $FRONTEND_PORT"
  (
    cd "$FRONTEND_DIR"
    npm run "$frontend_script" -- -p "$FRONTEND_PORT"
  ) &
  FRONTEND_PID=$!

  if ! wait_for_port "$FRONTEND_PORT" 60; then
    error "Frontend server failed to bind to port $FRONTEND_PORT within timeout."
    exit 1
  fi

  if ! wait_for_http "http://127.0.0.1:${FRONTEND_PORT}" 90; then
    error "Frontend HTTP readiness check failed at http://127.0.0.1:${FRONTEND_PORT}"
    exit 1
  fi

  success "Frontend server is running at http://127.0.0.1:${FRONTEND_PORT}"
}

monitor_servers() {
  section "Server Monitor"
  success "Backend URL : http://127.0.0.1:${BACKEND_PORT}"
  success "Frontend URL: http://127.0.0.1:${FRONTEND_PORT}"
  info "Servers are running. Press Ctrl+C to stop."

  while true; do
    if [[ -n "$BACKEND_PID" ]] && ! kill -0 "$BACKEND_PID" >/dev/null 2>&1; then
      error "Backend server exited unexpectedly."
      exit 1
    fi

    if [[ -n "$FRONTEND_PID" ]] && ! kill -0 "$FRONTEND_PID" >/dev/null 2>&1; then
      error "Frontend server exited unexpectedly."
      exit 1
    fi

    sleep 2
  done
}

# =========================
# Main Execution Flow
# =========================
main() {
  parse_args "$@"
  init_logging

  section "AutoRig Setup Started"
  info "Project root: $PROJECT_ROOT"
  info "Mode: $MODE"
  info "Log file: $LOG_FILE"

  validate_os
  install_missing_system_tools
  validate_project_layout
  setup_python_environment
  setup_frontend_environment

  section "Server Startup"
  start_backend_server
  start_frontend_server

  monitor_servers
}

main "$@"
