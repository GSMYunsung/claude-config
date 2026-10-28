#!/bin/sh
# PostToolUse 훅 — 스킬 파일 작성 시 전역·claude-config 자동 동기화
#
# Case A) ~/.claude/skills/*/SKILL.md → claude-config에 자동 커밋
# Case B) <project>/.claude/skills/*/SKILL.md
#         → 대기 파일 저장 후 Claude에게 확인 요청 메시지 출력
#         → 사용자 확인 후 bash ~/.claude/hooks/do-skill-sync.sh 로 실행

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
PENDING_FILE="/tmp/.claude-skill-sync-pending"

[ -d "$REPO/.git" ] || exit 0

case "$file_path" in
    "$GLOBAL_SKILLS"/*/SKILL.md)
        # Case A: 전역 위치 → claude-config 자동 동기화
        skill_name=$(echo "$file_path" | sed "s|$GLOBAL_SKILLS/||" | cut -d'/' -f1)
        source_dir="$GLOBAL_SKILLS/$skill_name"

        rm -rf "$REPO/skills/$skill_name"
        cp -RL "$source_dir" "$REPO/skills/$skill_name"

        cd "$REPO"
        git add "skills/$skill_name"
        git diff --cached --quiet && exit 0

        if git show HEAD:"skills/$skill_name/SKILL.md" > /dev/null 2>&1; then
            commit_msg="update: $skill_name 스킬 업데이트"
        else
            commit_msg="feat: $skill_name 스킬 추가"
        fi

        git commit -m "$commit_msg"
        git push origin main
        printf '[sync] %s → claude-config 자동 커밋 완료\n' "$skill_name" >&2
        ;;

    */.claude/skills/*/SKILL.md)
        # Case B: 프로젝트 스킬 → 사용자 확인 후 동기화
        skill_name=$(echo "$file_path" | rev | cut -d'/' -f2 | rev)
        project_skill_dir=$(echo "$file_path" | sed "s|/SKILL.md$||")

        # 스킬 설명 추출
        skill_desc=$(python3 -c "
import re
try:
    text = open('$file_path').read()
    m = re.search(r'description:\s*(.+)', text)
    print(m.group(1).strip() if m else '설명 없음')
except: print('설명 없음')
" 2>/dev/null)

        # 유사 스킬 탐색
        new_keywords=$(echo "$skill_name $skill_desc" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' ' ')
        similar=""
        for existing_dir in "$GLOBAL_SKILLS"/*/; do
            existing=$(basename "$existing_dir")
            [ "$existing" = "$skill_name" ] && continue
            existing_desc=$(python3 -c "
import re
try:
    text = open('${existing_dir}SKILL.md').read()
    m = re.search(r'description:\s*(.+)', text)
    print(m.group(1).strip() if m else '')
except: print('')
" 2>/dev/null)
            existing_keywords=$(echo "$existing $existing_desc" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' ' ')
            common_count=$(python3 -c "
a=set('$new_keywords'.split())
b=set('$existing_keywords'.split())
stop={'the','a','an','and','or','for','to','of','in','is','it','with','that','this','on','at','be','as','from'}
print(len((a & b) - stop - {''}))
" 2>/dev/null)
            if [ "${common_count:-0}" -ge 2 ] 2>/dev/null; then
                similar="$similar $existing"
            fi
        done

        # 대기 파일 저장
        python3 -c "
import json
data = {
    'skill_name': '$skill_name',
    'project_skill_dir': '$project_skill_dir',
    'skill_desc': '$skill_desc',
    'similar': '$similar'.strip().split() if '$similar'.strip() else []
}
open('$PENDING_FILE', 'w').write(json.dumps(data))
" 2>/dev/null

        # Claude가 읽을 확인 요청 메시지 출력 (stdout → tool result로 전달됨)
        printf '\n[SKILL_SYNC_PENDING]\n'
        printf '프로젝트에서 새 스킬이 감지되었습니다. 전역에 반영하기 전에 사용자에게 확인하세요.\n'
        printf '  스킬: %s\n' "$skill_name"
        printf '  설명: %s\n' "$skill_desc"
        if [ -n "$similar" ]; then
            printf '  유사 기존 스킬:%s\n' "$similar"
        fi
        printf '확인 후 동기화하려면: bash ~/.claude/hooks/do-skill-sync.sh\n'
        printf '[/SKILL_SYNC_PENDING]\n\n'
        ;;

    *)
        exit 0
        ;;
esac
