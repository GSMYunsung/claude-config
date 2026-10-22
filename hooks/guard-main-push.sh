#!/bin/sh
# PreToolUse 훅 — main 브랜치 직접 push 차단
# exit 2 → Claude Code가 해당 Bash 명령을 실행하지 않음

input=$(cat)

result=$(echo "$input" | python3 - <<'PY'
import json, sys, re

try:
    d = json.load(sys.stdin)
    cmd = d.get('tool_input', {}).get('command', '')
    # 'git push ... main' 패턴 감지 (main- 이나 main/ 로 시작하는 브랜치명은 제외)
    if re.search(r'git push\b.*\s+main(\s|$)', cmd):
        print("BLOCK")
    else:
        print("OK")
except Exception:
    print("OK")
PY
)

if [ "$result" = "BLOCK" ]; then
    printf '⛔ main 브랜치 직접 push 차단.\nfeat/fix/chore 브랜치를 만들어 PR로 머지하세요.\n' >&2
    exit 2
fi
