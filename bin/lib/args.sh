#!/usr/bin/env bash

COMPOSE_ARGS=()
COMMAND_ARGS=()

parse_args() {
  COMPOSE_ARGS=()
  COMMAND_ARGS=()

  for arg in "$@"; do
    case "$arg" in
      --db)
        COMPOSE_ARGS+=(--profile db)
        ;;
      *)
        COMMAND_ARGS+=("$arg")
        ;;
    esac
  done
}