#!/usr/bin/env bash

show_env_hint() {
  if [[ ! -f "$PROJECT_DIR/.env" && -f "$PROJECT_DIR/.env.example" ]]; then
    info "using default environment values."
    info "copy .env.example to .env to customize them."
  fi
}

has_package_script() {
  local script_name="$1"

  compose exec -T app \
    node -e "
      const pkg = require('/workspace/package.json');
      process.exit(pkg.scripts?.['$script_name'] ? 0 : 1);
    "
}

require_package_json() {
  if [[ ! -f "$PROJECT_DIR/package.json" ]]; then
    error "package.json is missing"
    exit 1
  fi
}

load_node_version() {
  if [[ ! -f "$NODE_VERSION_FILE" ]]; then
    error "missing .node-version"
    exit 1
  fi

  NODE_VERSION="$(tr -d '[:space:]' < "$NODE_VERSION_FILE")"

  if [[ -z "$NODE_VERSION" ]]; then
    error ".node-version is empty"
    exit 1
  fi

  export NODE_VERSION
}

is_fdev_project() {
  [[ -f "$PROJECT_DIR/.fdev/config.yaml" ]]
}

require_fdev_project() {
  if ! is_fdev_project; then
    error "current directory is not an fdev project"
    info "missing .fdev/config.yaml"
    exit 1
  fi
}