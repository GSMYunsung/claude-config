# maestro-test project settings, sourced by run.sh (bash). Created by init.sh — edit freely.

# Bundle ID of the app on the simulator. Flows can use it as ${APP_ID}.
APP_ID="__APP_ID__"
# Heading of report.html
REPORT_TITLE="__TITLE__ 화면 테스트"
# Simulator used when none is booted (or pass SIM=<UDID>)
SIM_MODEL="iPhone 17 Pro"

# Expo dev client only: URL scheme and Metro port. run.sh checks Metro and passes ${DEV_URL} to flows
# (open it with `- openLink: ${DEV_URL}` after launchApp). Leave EXPO_SCHEME empty for other apps.
EXPO_SCHEME="__SCHEME__"
METRO_PORT=8081

# Simulated device location "lat,lng" (empty: leave as is)
LOCATION=""
# simctl privacy services granted before the run, e.g. (location-always photos).
# Per-scenario permissions belong in the flow instead: launchApp → permissions: { location: unset }
GRANT=()
