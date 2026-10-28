#!/bin/sh
# PostToolUse 훅 — 스킬 파일 작성 시 전역·claude-config 자동 동기화
#
# 처리하는 두 가지 경로:
#   A) ~/.claude/skills/*/SKILL.md → claude-config에 커밋
#   B) <project>/.claude/skills/*/SKILL.md → 전역으로 승격 후 claude-config에 커밋
#      (유사 스킬 존재 시 병합 제안 출력)

input=$(cat)

file_path=$(echo "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except:
    print('')
" 2>/dev/null)

GLOBAL_SKILLS="$HOME/.claude/skills"
REPO="$HOME/claude-config"

[ -d "$REPO/.git" ] || exit 0

# ── 경로 분류 ────────────────────────────────────────────────
case "$file_path" in
    "$GLOBAL_SKILLS"/*/SKILL.md)
        # Case A: 이미 전역 위치 → claude-config 동기화만
        skill_name=$(echo "$file_path" | sed "s|$GLOBAL_SKILLS/||" | cut -d'/' -f1)
        source_dir="$GLOBAL_SKILLS/$skill_name"
        ;;
    */.claude/skills/*/SKILL.md)
        # Case B: 프로젝트 내 스킬 → 전역으로 승격
        skill_name=$(echo "$file_path" | rev | cut -d'/' -f2 | rev)
        project_skill_dir=$(echo "$file_path" | sed "s|/SKILL.md$||")

        # 전역에 복사 (심링크 포함 실제 파일로)
        source_dir="$GLOBAL_SKILLS/$skill_name"
        rm -rf "$source_dir"
        cp -RL "$project_skill_dir" "$source_dir"
        printf '[sync] 프로젝트 스킬 "%s" 전역으로 승격\n' "$skill_name" >&2

        # ── 유사 스킬 탐지 ──────────────────────────────────
        # 1) 동일 이름 → 업데이트 (이미 위에서 복사됨, 별도 알림)
        # 2) 부분 이름 일치 or 설명 키워드 겹침 → 병합 제안
        new_desc=$(python3 -c "
import sys, re
try:
    text = open('$project_skill_dir/SKILL.md').read()
    m = re.search(r'description:\s*(.+)', text)
    print(m.group(1).strip() if m else '')
except: print('')
" 2>/dev/null)

        new_keywords=$(echo "$skill_name $new_desc" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' ' ')

        similar=""
        for existing_dir in "$GLOBAL_SKILLS"/*/; do
            existing=$(basename "$existing_dir")
            [ "$existing" = "$skill_name" ] && continue

            existing_desc=$(python3 -c "
import sys, re
try:
    text = open('${existing_dir}SKILL.md').read()
    m = re.search(r'description:\s*(.+)', text)
    print(m.group(1).strip() if m else '')
except: print('')
" 2>/dev/null)

            existing_keywords=$(echo "$existing $existing_desc" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' ' ')

            # 공통 단어 2개 이상이면 유사 스킬로 판단
            common=$(python3 -c "
a=set('$new_keywords'.split())
b=set('$existing_keywords'.split())
stop={'the','a','an','and','or','for','to','of','in','is','it','with','that','this','on','at','be','as','from'}
shared=(a & b) - stop - {''}
print(len(shared), ' '.join(shared))
" 2>/dev/null)
            count=$(echo "$common" | cut -d' ' -f1)
            words=$(echo "$common" | cut -d' ' -f2-)
            if [ "${count:-0}" -ge 2 ] 2>/dev/null; then
                similar="$similar\n  - '$existing' (공통 키워드: $words)"
            fi
        done

        if [ -n "$similar" ]; then
            printf '\n⚠️  유사 스킬 발견 — "%s"와 병합 검토를 권장합니다:%b\n기존 스킬을 보완할 경우 해당 스킬의 SKILL.md에 내용을 통합하세요.\n\n' \
                "$skill_name" "$similar" >&2
        fi
        ;;
    *)
        exit 0
        ;;
esac

# ── claude-config 동기화 ─────────────────────────────────────
rm -rf "$REPO/skills/$skill_name"
cp -RL "$source_dir" "$REPO/skills/$skill_name"

cd "$REPO"
git add "skills/$skill_name"
git diff --cached --quiet && exit 0

# 신규 vs 업데이트 구분
if git show HEAD:"skills/$skill_name/SKILL.md" > /dev/null 2>&1; then
    commit_msg="update: $skill_name 스킬 업데이트"
else
    commit_msg="feat: $skill_name 스킬 추가"
fi

git commit -m "$commit_msg"
git push origin main
printf '[sync] %s → claude-config 자동 커밋 완료\n' "$skill_name" >&2
