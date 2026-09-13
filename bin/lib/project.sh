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
  copy_template_file ".node-version"
  copy_template_file "docker/app/Dockerfile"

  echo
  success "fdev project is ready"
}