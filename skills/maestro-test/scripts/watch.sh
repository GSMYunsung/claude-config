#!/usr/bin/env bash
# Live view of a run.sh run: one line per scenario, redrawn every few seconds. Read-only.
# Run from the project root (run.sh opens it in a Terminal window automatically).
#   watch.sh                     latest run in maestro-report/
#   watch.sh maestro-report/<run>
# Env: INTERVAL (seconds, default 2)
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RUN="${1:-$(ls -td maestro-report/*/ 2>/dev/null | head -1)}"
RUN="${RUN%/}"
[ -d "$RUN" ] || { echo "no run in maestro-report/ — start one with run.sh" >&2; exit 1; }
INTERVAL="${INTERVAL:-2}"

while :; do
  frame="$(python3 - "$RUN" "$(tput cols 2>/dev/null || echo 100)" <<'PY'
import glob, json, os, re, sys, time
run, cols = sys.argv[1], int(sys.argv[2])
try:
    results = {r['id']: r for r in json.load(open(os.path.join(run, 'results.json')))}
except Exception:
    results = {}
flows = sorted(os.path.basename(f)[:-5] for f in glob.glob('.maestro/flows/*.yaml'))
started = {d for d in os.listdir(run) if os.path.isdir(os.path.join(run, d))}

def log_lines(name):
    try:
        return [l.strip() for l in open(os.path.join(run, name, 'log.txt'), encoding='utf-8', errors='replace') if l.strip()]
    except OSError:
        return []

def cut(s, n):
    return s if len(s) <= n else s[:max(n - 1, 0)] + '…'

done = os.path.exists(os.path.join(run, 'report.html'))
npass = sum(r['status'] == 'pass' for r in results.values())
nfail = len(results) - npass
print(f"Maestro  {run}   {time.strftime('%H:%M:%S')}")
print(f"✅ {npass}  ❌ {nfail}  남음 {len(flows) - len(results)} / {len(flows)}" + ("   — 완료" if done else ""))
print()
for name in flows:
    r = results.get(name)
    if r:
        icon, secs = ('✅' if r['status'] == 'pass' else '❌'), r['seconds']
        detail = ''
        if r['status'] == 'fail':
            detail = next((l for l in log_lines(name) if 'FAILED' in l), '')
    elif name in started and not done:
        icon = '⏳'
        secs = int(time.time() - os.path.getctime(os.path.join(run, name)))
        lines = log_lines(name)
        detail = lines[-1] if lines else '시작 중'
    else:
        icon, secs, detail = '·', None, ''
    t = f"{secs:>4}s" if secs is not None else '     '
    head = f"{icon} {name:<26} {t}  "
    print(head + cut(detail, cols - len(head) - 2))
if done:
    print(f"\nreport: {run}/report.html")
PY
)"
  clear; printf '%s\n' "$frame"
  [ -f "$RUN/report.html" ] && break
  sleep "$INTERVAL"
done
