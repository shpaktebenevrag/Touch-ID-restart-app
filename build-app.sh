#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Restart Touch ID.app"
APP="$ROOT/$APP_NAME"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$ROOT/restart-touchid.sh" "$APP/Contents/Resources/restart-touchid.sh"
chmod +x "$APP/Contents/Resources/restart-touchid.sh"

cat > "$APP/Contents/MacOS/launcher" <<'LAUNCHER'
#!/usr/bin/env bash
RES="$(cd "$(dirname "$0")/../Resources" && pwd)"
SCRIPT="$RES/restart-touchid.sh"

if ! "$SCRIPT" user >/tmp/restart-touchid-last.log 2>&1; then
  /usr/bin/osascript -e 'display dialog "Не удалось перезапустить Touch ID. Подробности: /tmp/restart-touchid-last.log" buttons {"OK"} default button 1 with icon caution'
  exit 1
fi

/usr/bin/osascript -e 'display notification "Touch ID перезапущен (без запроса пароля)." with title "Restart Touch ID"'
LAUNCHER

chmod +x "$APP/Contents/MacOS/launcher"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>ru</string>
  <key>CFBundleExecutable</key>
  <string>launcher</string>
  <key>CFBundleIdentifier</key>
  <string>local.restart-touchid</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Restart Touch ID</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

echo "Built: $APP"
echo "Install: cp -R \"$APP\" ~/Applications/"
