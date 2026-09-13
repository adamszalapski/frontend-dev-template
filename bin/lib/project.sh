#!/usr/bin/env bash

copy_template_file() {
  local template_dir="$1"
  local relative_path="$2"
  local source="$template_dir/$relative_path"
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
  local template_name="${1:-$DEFAULT_TEMPLATE}"
  local template_dir
  local config_dir="$PROJECT_DIR/.fdev"
  local config_file="$config_dir/config.yaml"

  require_template "$template_name" || return 1

  template_dir="$(get_template_dir "$template_name")"

  if [[ -f "$config_file" ]]; then
    local current_template

    current_template="$(
      sed -n \
        's/^[[:space:]]*template:[[:space:]]*\(.*\)[[:space:]]*$/\1/p' \
        "$config_file" |
        head -n 1
    )"

    if [[ -n "$current_template" && "$current_template" != "$template_name" ]]; then
      error "project is already initialized with template '$current_template'"
      info "requested template: $template_name"
      return 1
    fi

    warn "project is already initialized"
  else
    mkdir -p "$config_dir"

    printf 'version: 1\ntemplate: %s\n' "$template_name" > "$config_file"

    success "created .fdev/config.yaml"
  fi

  copy_template_file "$template_dir" ".fdev/compose.yaml"
  copy_template_file "$template_dir" ".fdev/.env.example"

  create_node_version
  create_package_json

  copy_template_file "$template_dir" ".fdev/docker/app/Dockerfile"

  echo
  success "fdev project is ready"
  info "template: $template_name"
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

get_template_dir() {
  local template_name="$1"

  printf '%s/%s\n' "$TEMPLATES_DIR" "$template_name"
}

require_template() {
  local template_name="$1"
  local template_dir

  template_dir="$(get_template_dir "$template_name")"

  if [[ ! -d "$template_dir" ]]; then
    error "template '$template_name' does not exist"
    return 1
  fi

  if [[ ! -f "$template_dir/template.yaml" ]]; then
    error "template '$template_name' is invalid"
    return 1
  fi
}

list_templates() {
  local template_dir
  local metadata_file
  local template_name
  local name
  local description
  local found=0

  info "available templates"

  echo

  for template_dir in "$TEMPLATES_DIR"/*; do
    [[ -d "$template_dir" ]] || continue

    metadata_file="$template_dir/template.yaml"
    [[ -f "$metadata_file" ]] || continue

    template_name="$(basename "$template_dir")"

    name="$(
      sed -n \
        's/^[[:space:]]*name:[[:space:]]*\(.*\)[[:space:]]*$/\1/p' \
        "$metadata_file" |
        head -n 1
    )"

    description="$(
      sed -n \
        's/^[[:space:]]*description:[[:space:]]*\(.*\)[[:space:]]*$/\1/p' \
        "$metadata_file" |
        head -n 1
    )"

    printf "  %-12s %-18s %s\n" \
      "$template_name" \
      "${name:-$template_name}" \
      "$description"

    found=1
  done

  if [[ "$found" -eq 0 ]]; then
    warn "no templates are available"
    return 1
  fi
}