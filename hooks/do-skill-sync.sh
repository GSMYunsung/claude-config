#!/bin/sh
# 사용자 확인 후 프로젝트 스킬을 전역·claude-config에 동기화
# sync-skill-to-repo.sh 의 Case B 에서 대기된 작업을 실행

PENDING_FILE="/tmp/.claude-skill-sync-pending"
GLOBAL_SKILLS="$HOME/.claude/skills"
REPO="$HOME/claude-config"

if [ ! -f "$PENDING_FILE" ]; then
    printf '대기 중인 스킬 동기화 작업이 없습니다.\n' >&2
    exit 0
fi

skill_name=$(python3 -c "import json; d=json.load(open('$PENDING_FILE')); print(d['skill_name'])" 2>/dev/null)
project_skill_dir=$(python3 -c "import json; d=json.load(open('$PENDING_FILE')); print(d['project_skill_dir'])" 2>/dev/null)

if [ -z "$skill_name" ] || [ -z "$project_skill_dir" ]; then
    printf '대기 파일 읽기 실패\n' >&2
    exit 1
fi

[ -d "$REPO/.git" ] || { printf 'claude-config 레포를 찾을 수 없습니다.\n' >&2; exit 1; }

# 전역에 복사
rm -rf "$GLOBAL_SKILLS/$skill_name"
cp -RL "$project_skill_dir" "$GLOBAL_SKILLS/$skill_name"

# claude-config에 반영
rm -rf "$REPO/skills/$skill_name"
cp -RL "$GLOBAL_SKILLS/$skill_name" "$REPO/skills/$skill_name"

cd "$REPO"
git add "skills/$skill_name"
git diff --cached --quiet && { printf '[sync] 변경 사항 없음\n'; rm -f "$PENDING_FILE"; exit 0; }

if git show HEAD:"skills/$skill_name/SKILL.md" > /dev/null 2>&1; then
    commit_msg="update: $skill_name 스킬 업데이트"
else
    commit_msg="feat: $skill_name 스킬 추가"
fi

git commit -m "$commit_msg"
git push origin main

rm -f "$PENDING_FILE"
printf '[sync] "%s" 전역 동기화 완료\n' "$skill_name"
