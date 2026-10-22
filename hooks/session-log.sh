#!/bin/sh
# Stop 훅 — 세션 종료 시 날짜·프로젝트 한 줄 기록
# ~/.claude/sessions.log 에 누적됨

LOG="${HOME}/.claude/sessions.log"
DATE=$(date "+%Y-%m-%d %H:%M")
PROJECT=$(basename "$(pwd)")

printf '%s  %s\n' "$DATE" "$PROJECT" >> "$LOG"
