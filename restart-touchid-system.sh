#!/usr/bin/env bash
# System-only helper (installed to /usr/local/bin by install-helper.sh).
set -euo pipefail

[[ ${EUID:-$(id -u)} -eq 0 ]] || {
  echo "Must run as root." >&2
  exit 1
}

ACTION="${1:-soft}"
[[ "$ACTION" == soft ]] || {
  echo "Only 'soft' is allowed from the helper." >&2
  exit 1
}

kickstart_if_exists() {
  local target="$1"
  if launchctl print "$target" &>/dev/null; then
    launchctl kickstart -k "$target" 2>/dev/null || true
  fi
}

killall biometrickitd 2>/dev/null || true
kickstart_if_exists "system/com.apple.biometrickitd"
kickstart_if_exists "system/com.apple.biometricsensord"
