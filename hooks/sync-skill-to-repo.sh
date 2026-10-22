#!/bin/sh
# PostToolUse 훅 — ~/.claude/skills/*/SKILL.md 작성 완료 시 claude-config에 자동 커밋
# 스킬 디렉토리 전체를 레포에 복사하고 push

input=$(cat)

file_path=$(echo "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

SKILLS_DIR="$HOME/.claude/skills"
REPO="$HOME/claude-config"

# ~/.claude/skills/*/SKILL.md 패턴인지 확인
case "$file_path" in
    "$SKILLS_DIR"/*/SKILL.md)
        ;;
    *)
        exit 0
        ;;
esac

# claude-config 레포 없으면 건너뜀
[ -d "$REPO/.git" ] || exit 0

skill_name=$(echo "$file_path" | sed "s|$SKILLS_DIR/||" | cut -d'/' -f1)

# 스킬 디렉토리 전체 복사
rm -rf "$REPO/skills/$skill_name"
cp -R "$SKILLS_DIR/$skill_name" "$REPO/skills/$skill_name"

# 변경 없으면 종료
cd "$REPO"
git add "skills/$skill_name"
git diff --cached --quiet && exit 0

git commit -m "feat: $skill_name 스킬 추가"
git push origin main
printf '  [sync] %s → claude-config 자동 커밋 완료\n' "$skill_name" >&2
