# 화면 테스트 (Maestro)

실행·규칙은 전역 `maestro-test` 스킬에 있다. 이 파일은 **이 앱만의 지식**을 담는다.

- 설정: `.maestro/config.sh` · 시나리오: `.maestro/flows/NN-*.yaml` · 공통 흐름: `.maestro/subflows/`
- 실행: `~/.claude/skills/maestro-test/scripts/run.sh` (프로젝트 루트에서)

## 화면 ↔ 시나리오

기능·화면·문구를 바꾸면 아래 표에서 해당 시나리오를 찾아 같은 작업 안에서 고친다. 새 화면이면 행과 시나리오를 추가한다.

| 화면(소스) | 시나리오 |
|---|---|
| (예) `app/onboarding.tsx` | 00, 01 |

## 이 앱에서 겪은 실패와 해결

| 증상 | 원인 | 해결 |
|---|---|---|
