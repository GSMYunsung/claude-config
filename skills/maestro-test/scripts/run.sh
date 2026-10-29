#!/usr/bin/env bash
# Runs the project's Maestro scenarios (.maestro/flows) on an iOS simulator, in order, and builds one report.
#   run.sh                 all scenarios
#   run.sh 05 06           only scenarios whose file starts with these numbers (state is NOT reset)
# Project settings come from .maestro/config.sh (create it with init.sh).
# Env: SIM (simulator UDID), WATCH=0 to skip opening a Terminal window with watch.sh
set -uo pipefail
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Everything runs inside main, so editing this file during a run cannot change the running copy.
main() {
  cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  [ -f .maestro/config.sh ] || { echo "no .maestro/config.sh — run $SKILL_DIR/scripts/init.sh first" >&2; exit 1; }
  APP_ID=""; REPORT_TITLE="화면 테스트"; SIM_MODEL="iPhone 17 Pro"; EXPO_SCHEME=""; METRO_PORT=8081
  LOCATION=""; GRANT=()
  # shellcheck disable=SC1091
  source .maestro/config.sh
  [ -n "$APP_ID" ] || { echo "APP_ID is empty in .maestro/config.sh" >&2; exit 1; }

  export PATH="/opt/homebrew/opt/openjdk@17/bin:$HOME/.maestro/bin:$PATH"
  command -v maestro >/dev/null || { echo "maestro not installed (brew install openjdk@17 mobile-dev-inc/tap/maestro)" >&2; exit 1; }

  SIM="${SIM:-$(xcrun simctl list devices booted | awk -F'[()]' '/iPhone/ {print $2; exit}')}"
  [ -z "$SIM" ] && SIM="$(xcrun simctl list devices available | awk -F'[()]' -v m="$SIM_MODEL (" 'index($0, m) {print $2; exit}')"
  [ -z "$SIM" ] && { echo "no iPhone simulator (SIM_MODEL=$SIM_MODEL)" >&2; exit 1; }
  xcrun simctl boot "$SIM" 2>/dev/null; open -a Simulator
  xcrun simctl get_app_container "$SIM" "$APP_ID" >/dev/null 2>&1 || {
    echo "$APP_ID is not installed on simulator $SIM — build it once (Expo: npx expo run:ios --device $SIM --no-bundler)" >&2; exit 1; }

  ENVS=(--env APP_ID="$APP_ID")
  if [ -n "$EXPO_SCHEME" ]; then
    curl -sf "http://localhost:$METRO_PORT/status" | grep -q running || {
      echo "Metro is not running on $METRO_PORT — start it first" >&2; exit 1; }
    # Expo dev client deep link: no dev-menu intro, floating button or auto-opened dev menu over the screens under test.
    local url; url="$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "http://localhost:$METRO_PORT")"
    ENVS+=(--env DEV_URL="exp+$EXPO_SCHEME://?__expo_url=$url&__expo_disable_fab=1&__expo_disable_onboarding=1&__expo_disable_auto_launch=1")
  fi

  [ -n "$LOCATION" ] && xcrun simctl location "$SIM" set "$LOCATION"
  for service in "${GRANT[@]}"; do xcrun simctl privacy "$SIM" grant "$service" "$APP_ID" 2>/dev/null || true; done

  RUN="maestro-report/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$RUN"
  # Live progress in its own Terminal window; failing to open it never stops the run.
  if [ "${WATCH:-1}" != 0 ]; then
    osascript -e "tell application \"Terminal\" to do script \"cd '$PWD' && '$SKILL_DIR/scripts/watch.sh' '$RUN'\"" \
      -e 'tell application "Terminal" to activate' >/dev/null 2>&1 || true
  fi

  local flows=(.maestro/flows/*.yaml)
  if [ $# -gt 0 ]; then
    flows=(); for n in "$@"; do flows+=(.maestro/flows/"$n"*.yaml); done
  fi

  echo "[]" > "$RUN/results.json"
  for flow in "${flows[@]}"; do
    local name out start code secs status
    name="$(basename "$flow" .yaml)"
    out="$RUN/$name"; mkdir -p "$out"
    start=$(date +%s)
    # Screenshots from takeScreenshot land in the working directory, so run inside the scenario folder.
    ( cd "$out" && maestro --device "$SIM" test "${ENVS[@]}" --test-output-dir . "$OLDPWD/$flow" ) > "$out/log.txt" 2>&1
    code=$?
    secs=$(( $(date +%s) - start ))
    status=$([ $code -eq 0 ] && echo pass || echo fail)
    printf '%-28s %s (%ss)\n' "$name" "$status" "$secs"
    python3 - "$RUN/results.json" "$name" "$status" "$secs" "$flow" <<'PY'
import json, sys
path, name, status, secs, flow = sys.argv[1:]
title = next((l.split(':', 1)[1].strip().strip('"') for l in open(flow, encoding='utf-8') if l.startswith('name:')), name)
r = json.load(open(path)); r.append({'id': name, 'title': title, 'status': status, 'seconds': int(secs)})
json.dump(r, open(path, 'w'), ensure_ascii=False, indent=1)
PY
  done

  REPORT_TITLE="$REPORT_TITLE" python3 "$SKILL_DIR/scripts/report.py" "$RUN"
  echo "report: $RUN/report.html"
}

main "$@"
exit
