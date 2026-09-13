#!/usr/bin/env bash

if [[ -t 1 ]]; then
  RESET='\033[0m'
  BLUE='\033[34m'
  YELLOW='\033[33m'
  RED='\033[31m'
  GREEN='\033[32m'
  BOLD='\033[1m'
else
  RESET=''
  BLUE=''
  YELLOW=''
  RED=''
  GREEN=''
  BOLD=''
fi

info() {
  printf "%b\n" "${BLUE}${BOLD}fdev:${RESET} $*"
}

warn() {
  printf "%b\n" "${YELLOW}${BOLD}fdev:${RESET} $*"
}

error() {
  printf "%b\n" "${RED}${BOLD}fdev:${RESET} $*" >&2
}

success() {
  printf "%b\n" "${GREEN}${BOLD}fdev:${RESET} $*"
}