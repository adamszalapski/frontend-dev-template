#!/usr/bin/env bash

compose() {
  local compose_args=(
    --project-directory "$PROJECT_DIR"
    -f "$PROJECT_DIR/.fdev/compose.yaml"
  )

  if [[ -f "$PROJECT_DIR/.fdev/.env" ]]; then
    compose_args+=(
      --env-file "$PROJECT_DIR/.fdev/.env"
    )
  fi

  COMPOSE_DISABLE_ENV_FILE=1 \
    docker compose "${compose_args[@]}" "$@"
}

check_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    error "Docker is not installed or not available on PATH."
    exit 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    error "Docker Compose is not available."
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    error "Docker daemon is not running."
    exit 1
  fi
}

is_running() {
  compose ps --status running --services | grep -q '^app$'
}

require_running() {
  if ! is_running; then
    echo "fdev: environment is not running."
    echo "Run: fdev up"
    exit 1
  fi
}

load_runtime_versions() {
  require_running

  NODE_RUNTIME_VERSION="$(compose exec -T app node --version 2>/dev/null || true)"
  NODE_RUNTIME_VERSION="${NODE_RUNTIME_VERSION#v}"

  PNPM_RUNTIME_VERSION="$(compose exec -T app pnpm --version 2>/dev/null || true)"
  COREPACK_RUNTIME_VERSION="$(compose exec -T app corepack --version 2>/dev/null || true)"
}

get_app_port() {
  local address

  address="$(compose port app 3000 2>/dev/null | head -n 1)"

  if [[ -z "$address" ]]; then
    return 1
  fi

  printf '%s\n' "${address##*:}"
}

get_app_url() {
  local port

  port="$(get_app_port)" || return 1

  printf 'http://localhost:%s\n' "$port"
}

is_docker_ready() {
  command -v docker >/dev/null 2>&1 \
    && docker compose version >/dev/null 2>&1 \
    && docker info >/dev/null 2>&1
}