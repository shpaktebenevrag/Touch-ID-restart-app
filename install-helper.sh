#!/usr/bin/env bash
# One-time setup: install a fixed helper + sudoers rule so the .app can restart
# system Touch ID daemons without asking for a password on each launch.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
HELPER_SRC="$ROOT/restart-touchid-system.sh"
HELPER_DST="/usr/local/bin/restart-touchid-system"
SUDOERS="/etc/sudoers.d/restart-touchid"
USER_NAME="$(whoami)"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo -- "$0" "$@"
fi

install -d /usr/local/bin
install -m 755 "$HELPER_SRC" "$HELPER_DST"

cat > "$SUDOERS" <<EOF
# Allow ${USER_NAME} to restart Touch ID system daemons without a password prompt.
${USER_NAME} ALL=(root) NOPASSWD: ${HELPER_DST} soft
EOF
chmod 440 "$SUDOERS"
visudo -cf "$SUDOERS"

echo "Installed ${HELPER_DST}"
echo "Sudoers: ${SUDOERS}"
echo "The Restart Touch ID.app can now run full system restarts without prompts."
