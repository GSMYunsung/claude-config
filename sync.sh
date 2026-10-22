#!/bin/sh
# 새 맥에서: git clone <repo> && cd claude-config && ./sync.sh
# 기존 ~/.claude/ 설정은 최대한 보존하고, 없는 것만 추가한다.

set -e

REPO="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

mkdir -p "$DEST/skills" "$DEST/hooks" "$DEST/agents"

echo "claude-config 동기화 시작..."
echo

# ── 스킬 배포 ──────────────────────────────────────────────────────────────
for skill_dir in "$REPO/skills"/*/; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    rm -rf "$DEST/skills/$name"
    cp -R "$skill_dir" "$DEST/skills/$name"
    echo "  skill   $name"
done

# ── 에이전트 배포 ───────────────────────────────────────────────────────────
for agent in "$REPO/agents"/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    cp "$agent" "$DEST/agents/$name"
    echo "  agent   $name"
done

# ── 훅 스크립트 배포 ────────────────────────────────────────────────────────
for hook in "$REPO/hooks"/*.sh; do
    [ -f "$hook" ] || continue
    name=$(basename "$hook")
    cp "$hook" "$DEST/hooks/$name"
    chmod +x "$DEST/hooks/$name"
    echo "  hook    $name"
done

# ── CLAUDE.md ───────────────────────────────────────────────────────────────
if [ -f "$DEST/CLAUDE.md" ] && ! cmp -s "$REPO/CLAUDE.md" "$DEST/CLAUDE.md"; then
    echo
    echo "  ~/.claude/CLAUDE.md 가 다릅니다. 차이:"
    diff "$DEST/CLAUDE.md" "$REPO/CLAUDE.md" || true
    echo
    printf "  덮어쓸까요? [y/N] "; read -r ans
    case "$ans" in
        [yY]*) cp "$REPO/CLAUDE.md" "$DEST/CLAUDE.md"; echo "  CLAUDE.md 업데이트" ;;
        *) echo "  CLAUDE.md 건너뜀" ;;
    esac
else
    cp "$REPO/CLAUDE.md" "$DEST/CLAUDE.md"
    echo "  CLAUDE.md 배포"
fi

# ── settings.json ───────────────────────────────────────────────────────────
# 없을 때만 생성 (~ → $HOME 치환)
if [ ! -f "$DEST/settings.json" ]; then
    sed "s|~|$HOME|g" "$REPO/settings.json" > "$DEST/settings.json"
    echo "  settings.json 생성"
else
    echo
    echo "  settings.json 이미 있음 — hooks 섹션을 수동으로 병합하세요:"
    echo "  참고: $REPO/settings.json"
fi

echo
echo "완료. 새 세션부터 적용됩니다."
