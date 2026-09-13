#!/usr/bin/env bash

open_url() {
  local url="$1"
  local system

  system="$(uname -s)"

  case "$system" in
    Darwin)
      open "$url"
      ;;

    Linux)
      if [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        if command -v wslview >/dev/null 2>&1; then
          wslview "$url"
        elif command -v powershell.exe >/dev/null 2>&1; then
          powershell.exe -NoProfile -Command "Start-Process '$url'" >/dev/null 2>&1
        else
          error "cannot find a browser opener for WSL"
          return 1
        fi
      elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$url"
      else
        error "xdg-open is not available"
        return 1
      fi
      ;;

    MINGW*|MSYS*|CYGWIN*)
      cmd.exe /c start "" "$url" >/dev/null 2>&1
      ;;

    *)
      error "opening a browser is not supported on this platform"
      return 1
      ;;
  esac
}