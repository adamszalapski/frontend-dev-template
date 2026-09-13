#!/usr/bin/env bash

show_env_hint() {
  if [[ ! -f ".env" && -f ".env.example" ]]; then
    info "using default environment values."
    info "copy .env.example to .env to customize them."
  fi
}

has_package_script() {
  local script_name="$1"

  docker compose exec -T app \
    node -e "
      const pkg = require('/workspace/package.json');
      process.exit(pkg.scripts?.['$script_name'] ? 0 : 1);
    "
}

require_package_json() {
  if [[ ! -f "package.json" ]]; then
    error "package.json is missing"
    exit 1
  fi
}