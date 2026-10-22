# claude-config

맥을 바꿔도 Claude Code 환경을 그대로 복원하기 위한 개인 설정 저장소.

스킬, 전역 지침(CLAUDE.md), settings.json, 자동화 훅을 한 곳에서 관리한다.

## 새 맥에서 시작하기

```bash
git clone https://github.com/GSMYunsung/claude-config.git
cd claude-config && ./sync.sh
```

`sync.sh` 가 아래를 처리한다.

| 항목 | 동작 |
|---|---|
| `skills/` | `~/.claude/skills/` 에 전부 복사 |
| `hooks/*.sh` | `~/.claude/hooks/` 에 복사 후 실행 권한 부여 |
| `CLAUDE.md` | `~/.claude/CLAUDE.md` 에 배포 (기존 파일이 다르면 diff 확인 후 선택) |
| `settings.json` | `~/.claude/settings.json` 이 없을 때만 생성 (이미 있으면 수동 병합 안내) |

---

## 구조

```
claude-config/
├── sync.sh                   ← 환경 복원 스크립트
├── CLAUDE.md                 ← 전역 행동 지침 (모든 프로젝트에 적용)
├── settings.json             ← 기본 설정 + 범용 권한 + hooks 등록 템플릿
│
├── skills/                   ← 전역 스킬 (어느 프로젝트에서나 호출 가능)
│   ├── animate/              ← Framer Motion / CSS 애니메이션 패턴
│   ├── clarify-intent/       ← 구현 전 의도 확정 및 GitHub 이슈 생성
│   ├── find-skills/          ← npx skills CLI로 스킬 탐색
│   ├── frontend-design/      ← 차별화된 UI 디자인 가이드 (Anti-slop 포함)
│   ├── harness/              ← 에이전트 팀 설계 (복잡한 다단계 작업)
│   ├── harness-evolve/       ← 하네스 피드백 반영·진화
│   ├── pr-workflow/          ← 브랜치 전략·PR·릴리즈 전체 워크플로우
│   ├── senior-frontend/      ← React/Next.js 컴포넌트·번들 분석
│   └── verify-solution/      ← Testing Trophy 기반 해법 검증
│
├── hooks/
│   ├── guard-main-push.sh    ← main 브랜치 직접 push 차단 (PreToolUse)
│   └── session-log.sh        ← 세션 종료 시 ~/.claude/sessions.log 기록 (Stop)
│
└── agents/                   ← 전역 에이전트 (추후 추가)
```

---

## 스킬

스킬은 Claude Code 에서 `/스킬이름` 으로 호출하거나 특정 조건에서 자동 발동한다.

| 스킬 | 호출 시점 |
|---|---|
| `animate` | 애니메이션·트랜지션 구현 |
| `clarify-intent` | 수정·기능 추가·버그 요청 → 구현 전 의도 확정 및 이슈 생성 |
| `find-skills` | "이런 스킬 있어?" 탐색 |
| `frontend-design` | UI 시각 방향성 설계 (랜딩·포트폴리오 Anti-slop 포함) |
| `harness` | 에이전트 팀이 필요한 복잡한 다단계 작업 |
| `harness-evolve` | 기존 하네스 피드백 반영 |
| `pr-workflow` | 브랜치 생성 → 커밋 → PR → CI → 릴리즈 전체 흐름 |
| `senior-frontend` | React/Next.js 컴포넌트 생성·번들 분석 |
| `verify-solution` | 구현 완료 후 Testing Trophy로 해법 검증 |

---

## 훅

| 훅 | 시점 | 역할 |
|---|---|---|
| `guard-main-push.sh` | PreToolUse (Bash) | `git push ... main` 감지 → 실행 차단 + 경고 |
| `session-log.sh` | Stop | `~/.claude/sessions.log` 에 날짜·프로젝트 기록 |

---

## 스킬 추가하기

```bash
# 1. 스킬 디렉터리 생성
mkdir -p skills/새스킬이름

# 2. SKILL.md 작성
# (frontmatter: name, description 필수)

# 3. 커밋 & push
git add skills/새스킬이름 && git commit -m "feat: 새스킬이름 스킬 추가"
git push

# 4. 로컬에 즉시 반영
./sync.sh
```

---

## 나중에 추가할 것

- `agents/` — 범용 에이전트 (code-reviewer, researcher 등)
