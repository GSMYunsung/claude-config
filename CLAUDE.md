# 전역 지침

모든 프로젝트에 공통으로 적용되는 규칙이다. 프로젝트별 규칙은 해당 프로젝트의 `CLAUDE.md`에 있다.

## 커뮤니케이션

- 한국어로 응답한다.
- 구현 전 접근 방법을 먼저 확인한다 — 짧게 설계를 보여주고 진행 여부를 묻는다.

## 보안

- API 키·시크릿은 `.env.local` 또는 환경변수에만 둔다. 레포에 값을 커밋하지 않는다.
- `.env.local`, `*secret*`, `*credentials*` 파일은 절대 `git add`하지 않는다.

## 브랜치 전략

- `main` 브랜치에 직접 커밋·push 금지. `feat/`, `fix/`, `chore/` prefix 브랜치 → PR → CI 통과 → 머지.
- PR 머지 후 반드시 로컬 main 동기화: `git checkout main && git pull origin main`

## 코드 작성

- 같은 로직을 두 곳에 쓰지 않는다. 공통 로직은 공유 파일로 분리하고 양쪽이 import한다.
- 빠르게 변하는 프레임워크(Expo, React Native 등)는 훈련 데이터를 믿지 않는다. 항상 공식 문서나 `npx expo-doctor`로 버전을 확인한다.

## 스킬 자동 동기화

도구 실행 결과에 `[SKILL_SYNC_PENDING]` 블록이 포함되면:
1. 사용자에게 "프로젝트에서 새 스킬 'XXX'을 감지했습니다. 전역에 동기화할까요?" 라고 물어본다.
2. 유사 기존 스킬이 있으면 "YYY와 유사합니다. 신규 추가 대신 YYY를 보완할까요?" 도 함께 제안한다.
3. 사용자가 동의하면 `bash ~/.claude/hooks/do-skill-sync.sh` 를 실행한다.
4. 사용자가 거부하면 `/tmp/.claude-skill-sync-pending` 파일을 삭제하고 종료한다.

## 스킬 호출 조건

| 상황 | 스킬 |
|---|---|
| 반복 실행할 버그픽스·기능 사이클 | `bugfix-cycle` (프로젝트 스킬) |
| 에이전트 팀이 필요한 복잡한 다단계 작업 | `harness` |
| 에이전트 팀 피드백 반영·진화 | `harness-evolve` |
