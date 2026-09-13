#!/usr/bin/env bash

compose() {
  docker compose --project-directory "$PROJECT_DIR" "$@"
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