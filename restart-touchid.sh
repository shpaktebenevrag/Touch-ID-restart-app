#!/usr/bin/env bash
# Restart Touch ID–related services. Default mode needs no administrator password.
set -euo pipefail

MODE="${1:-user}"

log() {
  printf '%s\n' "$*"
}

gui_domain() {
  printf 'gui/%s' "$(id -u)"
}

kickstart_if_exists() {
  local target="$1"
  if launchctl print "$target" &>/dev/null; then
    if launchctl kickstart -k "$target" 2>/dev/null; then
      log "  kickstarted $target"
      return 0
    fi
  fi
  return 1
}

user_restart() {
  local domain
  domain="$(gui_domain)"
  local ok=0

  log "User restart (no admin password): Local Authentication UI…"

  if kickstart_if_exists "$domain/com.apple.LocalAuthentication.UIAgent"; then
    ok=1
  elif killall coreautha 2>/dev/null; then
    log "  restarted coreautha via killall"
    ok=1
  else
    log "  note: launchctl/killall blocked or unchanged (SIP may apply)"
  fi

  if (( ok )); then
    log "Done. Try Touch ID."
  else
    log "Limited restart finished. For full daemon restart, run: $0 system"
    log "Or once: ./install-helper.sh — then the app can restart system services without prompts."
  fi
}

system_restart() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    if sudo -n true 2>/dev/null; then
      exec sudo -n -- "$0" system
    fi
    exec sudo -- "$0" system
  fi

  log "System restart: biometrickitd + sensor daemon…"

  killall biometrickitd 2>/dev/null || true
  kickstart_if_exists "system/com.apple.biometrickitd" || true
  kickstart_if_exists "system/com.apple.biometricsensord" || true

  log "Done. Try Touch ID."
}

full_reset() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    exec sudo -- "$0" --full-reset
  fi

  log "Full reset: clears biometric prefs (re-enroll fingerprints)…"

  killall -9 biometrickitd 2>/dev/null || true
  rm -rf /var/db/biome/streams/restricted/com.apple.biomekit* 2>/dev/null || true
  defaults delete com.apple.touchid 2>/dev/null || true
  defaults delete com.apple.biometrickitd 2>/dev/null || true
  kickstart_if_exists "system/com.apple.biometricsensord" || true
  kickstart_if_exists "system/com.apple.biometrickitd" || true

  log "Full reset complete. System Settings → Touch ID & Password → add fingerprints."
}

app_restart() {
  if [[ -x /usr/local/bin/restart-touchid-system ]]; then
    if sudo -n /usr/local/bin/restart-touchid-system soft 2>/dev/null; then
      log "System restart via helper (no password prompt)."
      return 0
    fi
  fi
  user_restart
}

case "$MODE" in
  user | --user | soft | --soft | "")
    app_restart
    ;;
  system | --system)
    system_restart
    ;;
  full | --full-reset)
    full_reset
    ;;
  *)
    log "Usage: $0 [user|--user|system|--system|full|--full-reset]"
    exit 1
    ;;
esac
