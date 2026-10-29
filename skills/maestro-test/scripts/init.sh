#!/usr/bin/env bash
# Sets up maestro-test in the current project. Never overwrites existing files.
#   init.sh
# Creates .maestro/config.sh (bundle ID and scheme read from app.json when present),
# .maestro/subflows/{dismiss-overlays,tap-tab,tap-until}.yaml, .maestro/flows/00-setup.yaml, .maestro/TESTING.md,
# and ignores maestro-report/ in git.
set -euo pipefail
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

app_id="" scheme="" title="$(basename "$PWD")"
if [ -f app.json ]; then
  read -r app_id scheme title < <(python3 - <<'PY'
import json
e = json.load(open('app.json')).get('expo', {})
scheme = e.get('scheme') or ''
if isinstance(scheme, list): scheme = scheme[0] if scheme else ''
print(e.get('ios', {}).get('bundleIdentifier') or '-', scheme or '-', (e.get('name') or '-').replace(' ', '_'))
PY
)
  [ "$app_id" = - ] && app_id=""; [ "$scheme" = - ] && scheme=""; title="${title//_/ }"
fi

place() {  # place <template> <dest>
  if [ -e "$2" ]; then echo "keep    $2"; return; fi
  mkdir -p "$(dirname "$2")"
  sed -e "s|__APP_ID__|$app_id|" -e "s|__SCHEME__|$scheme|" -e "s|__TITLE__|$title|" "$SKILL_DIR/templates/$1" > "$2"
  echo "create  $2"
}
place config.sh .maestro/config.sh
place dismiss-overlays.yaml .maestro/subflows/dismiss-overlays.yaml
place tap-tab.yaml .maestro/subflows/tap-tab.yaml
place tap-until.yaml .maestro/subflows/tap-until.yaml
place TESTING.md .maestro/TESTING.md
[ -n "$(ls .maestro/flows/*.yaml 2>/dev/null)" ] && echo "keep    .maestro/flows/" || place 00-setup.yaml .maestro/flows/00-setup.yaml
if ! grep -qxF 'maestro-report/' .gitignore 2>/dev/null; then echo 'maestro-report/' >> .gitignore; echo "update  .gitignore"; fi

echo
[ -z "$app_id" ] && echo "TODO: set APP_ID in .maestro/config.sh"
[ -z "$scheme" ] && echo "note: EXPO_SCHEME is empty — not an Expo dev client app; remove openLink/Bundling steps from 00-setup.yaml"
grep -q __FIRST_SCREEN_TEXT__ .maestro/flows/00-setup.yaml 2>/dev/null && echo "TODO: put the first screen's text into .maestro/flows/00-setup.yaml (TARGET)"
echo "TODO: check METRO_PORT, LOCATION, GRANT in .maestro/config.sh"
