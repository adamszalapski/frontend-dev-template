#!/usr/bin/env bash

copy_template_file() {
  local relative_path="$1"
  local source="$TEMPLATE_DIR/$relative_path"
  local target="$PROJECT_DIR/$relative_path"

  if [[ -e "$target" ]]; then
    warn "skipping $relative_path (already exists)"
    return 0
  fi

  if [[ ! -e "$source" ]]; then
    error "template file is missing: $relative_path"
    return 1
  fi

  mkdir -p "$(dirname "$target")"
  cp -R "$source" "$target"

  success "created $relative_path"
}

initialize_project() {
  local config_dir="$PROJECT_DIR/.fdev"
  local config_file="$config_dir/config.yaml"

  if [[ ! -d "$TEMPLATE_DIR" ]]; then
    error "base template is not available"
    return 1
  fi

  if [[ -f "$config_file" ]]; then
    warn "project is already initialized"
  else
    mkdir -p "$config_dir"
    printf 'version: 1\n' > "$config_file"
    success "created .fdev/config.yaml"
  fi

  copy_template_file "compose.yaml"
  copy_template_file ".env.example"

  create_node_version
  create_package_json

  copy_template_file "docker/app/Dockerfile"

  echo
  success "fdev project is ready"
}

get_package_manager() {
  local package_file="$FDEV_ROOT/package.json"

  if [[ ! -f "$package_file" ]]; then
    error "fdev package.json is missing"
    return 1
  fi

  sed -n \
    's/.*"packageManager"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
    "$package_file" |
    head -n 1
}

create_package_json() {
  local target="$PROJECT_DIR/package.json"
  local package_manager

  if [[ -f "$target" ]]; then
    warn "skipping package.json (already exists)"
    return 0
  fi

  package_manager="$(get_package_manager)"

  if [[ -z "$package_manager" ]]; then
    error "packageManager is not defined in fdev package.json"
    return 1
  fi

  printf '{\n  "private": true,\n  "packageManager": "%s"\n}\n' \
    "$package_manager" > "$target"

  success "created package.json ($package_manager)"
}

get_node_version() {
  local version_file="$FDEV_ROOT/.node-version"

  if [[ ! -f "$version_file" ]]; then
    error "fdev .node-version is missing"
    return 1
  fi

  tr -d '[:space:]' < "$version_file"
}

create_node_version() {
  local target="$PROJECT_DIR/.node-version"
  local node_version

  if [[ -f "$target" ]]; then
    warn "skipping .node-version (already exists)"
    return 0
  fi

  node_version="$(get_node_version)"

  if [[ -z "$node_version" ]]; then
    error "Node version is not defined in fdev"
    return 1
  fi

  printf '%s\n' "$node_version" > "$target"

  success "created .node-version (Node $node_version)"
}