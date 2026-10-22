---
name: pr-workflow
description: clarify-intent에서 확정한 의도를 GitHub 이슈로 만들고, 작업 브랜치·Draft PR·의도 중심 커밋·진행 댓글·PR 검증 보고·머지까지 관리한다. 마일스톤에 도달해 검증을 통과하면 통합 브랜치를 main(또는 master)에 릴리스하고 태그를 붙인다. 브리프가 확정됐을 때, 작업 중 커밋·push할 때, PR 상태를 정리하거나 머지할 때, 머지 후 작업 브랜치를 정리할 때, "PR 올려줘", "머지해줘", "이슈 만들어줘", "PR 현황", "최종 머지", "릴리스", "마일스톤" 같은 요청에 사용한다.
---

# 이슈·PR 작업 흐름 (pr-workflow)

코드만으로는 "왜 시작했고, 무엇을 하기로 했고, 정한 대로 했는지"가 남지 않는다.
이 맥락을 따로 문서로 관리하지 않고 GitHub 흐름 안에 남긴다.

| 어디에 | 무엇을 | 언제 |
| --- | --- | --- |
| **이슈** | 확정한 의도(브리프), 작업 중 발견·범위 변경·막힌 점 | 확정 직후, 작업 중 |
| **커밋** | 이 변경을 왜 했는지 | push할 때마다 |
| **PR** | 무엇을 어떻게 바꿨는지, 이슈에서 정한 대로 했는지 대조한 결과 | 작업을 끝낼 때 |
| **README** | 프로젝트 구조, 가정, API | 가정·API가 바뀔 때 |

wiki는 쓰지 않는다. 여러 작업에 걸친 지식은 README나 이슈에 둔다.

## 브랜치 구조

```
main(또는 master)  ← 릴리스 가능한 상태만. 마일스톤마다 develop에서 릴리스 PR로 머지 (merge commit + 태그)
  └ develop        ← 통합 브랜치. 작업 PR이 여기로 들어온다 (squash). 선택적으로 운용
      └ <type>/<이슈번호>-<동사-대상>  ← 작업 브랜치. 이슈 하나에 브랜치 하나
```

> develop 없이 main 단일 브랜치로 운용하는 경우, 작업 브랜치를 main에 직접 squash 머지한다.

- `type`: `feat`(기능) · `fix`(버그) · `refactor`(동작 변화 없는 구조 변경) · `test` · `docs` · `chore`(설정·도구)
- main(또는 master)·develop에는 직접 커밋하지 않는다. force push하지 않는다.

### 브랜치 이름: 무엇을 구현하는지 드러나게

브랜치 목록만 봐도 각 브랜치가 무엇을 하는지 알 수 있어야 한다. 이슈 번호 뒤의 이름은 **`동사-대상`** 형태로 짓는다.

- **동사**: 이 작업이 대상에 무엇을 하는지. 아래 목록에서 고른다.

  | 동사 | 쓰는 경우 |
  | --- | --- |
  | `add` | 없던 기능·화면·항목을 새로 만든다 |
  | `change` | 있던 동작이나 값을 다르게 바꾼다 |
  | `replace` | 기존 것을 다른 구현·라이브러리로 통째로 갈아 끼운다 |
  | `fix` | 잘못된 동작을 바로잡는다 |
  | `remove` | 기능·코드·의존성을 없앤다 |
  | `guard` | 잘못된 입력·상태·접근을 막는다 |
  | `sync` | 두 곳(화면과 서버, 코드와 문서 등)을 맞춘다 |
  | `split` / `extract` | 하나를 나누거나, 일부를 떼어 낸다 |
  | `rename` / `move` | 이름이나 위치만 바꾼다 |
  | `test` / `document` | 테스트나 문서를 보탠다 |

- **대상**: 코드에서 실제로 쓰는 이름을 쓴다.
- 2~4단어, 영어 소문자 kebab-case.
- 이슈 제목(상위 목표)에서 출발해, 그 목표를 이루려고 **실제로 손대는 것**을 이름으로 삼는다.

| 작업 | 좋음 | 나쁨 |
| --- | --- | --- |
| 시계 동작을 바꾼다 | `feat/15-change-clock` | `feat/15-clock`, `feat/15-update` |
| 새로고침 후 MSW 제어권을 되찾는다 | `fix/12-guard-msw-hard-reload` | `fix/12-fix-bug`, `fix/12-msw` |
| 이벤트를 목록에 바로 반영한다 | `feat/16-sync-list-on-start` | `feat/16-list-refetch-improvement` |
| 규칙을 별도 파일로 뺀다 | `refactor/17-extract-edit-policy` | `refactor/17-cleanup` |

나쁜 예는 대상만 있거나(`clock`), 동작이 없거나(`update`, `cleanup`), 너무 길다.

## 절대 규칙

- **머지는 사용자가 승인한 뒤에만 한다.** 작업 PR과 릴리스 PR 모두 같다. 검증을 통과해도 자동으로 머지하지 않는다.
- 이슈·PR·커밋은 clarify-intent에서 **확정된 뒤에만** 만든다.
- 비밀값(토큰, `.env`)을 커밋하지 않는다. 커밋 전에 `git status`와 `git diff --staged`로 확인한다.
- force push는 내 작업 브랜치에서만 `--force-with-lease`로 한다.

## 1. 이슈 만들기 (확정 직후)

clarify-intent 브리프가 확정되면 바로 이슈를 만든다.

- **제목**: `[type] 상위 목표를 한 줄로` — 해결책이 아니라 의도를 쓴다.
  - 좋음: `[fix] 강력 새로고침 후에도 모킹 API가 동작하게 하기`
  - 나쁨: `[fix] main.tsx 수정`
- **본문**: 확정된 브리프 그대로. 마지막 확정 질문 줄은 빼고, 확정으로 사실이 된 `(추측)` 표시는 지운다.

```bash
gh issue create --title "[fix] 제목" --body-file - <<'EOF'
(확정된 브리프)

### 결정 사항
- (질문 → 사용자의 선택)
EOF
```

마일스톤이 있는 프로젝트라면 `--milestone vX.Y.Z`를 붙인다.

## 2. 브랜치와 Draft PR

```bash
git switch develop && git pull --ff-only   # develop 없으면 main 기준
git switch -c fix/12-guard-msw-hard-reload
```

첫 커밋을 push하면서 **Draft PR**을 연다.

```bash
git push -u origin fix/12-guard-msw-hard-reload
gh pr create --draft --base develop --title "fix: 제목" --body-file - <<'EOF'
(아래 "PR 본문" 형식. 검증 결과는 작업이 끝날 때 채운다)
EOF
```

- PR의 base는 통합 브랜치(develop 또는 main)다.
- PR 제목은 squash 머지 때 커밋 제목이 되므로 커밋 메시지 규칙을 따른다.

## 3. 작업 중: 커밋과 진행 기록

### 커밋 메시지

**제목은 무엇을, 본문은 왜를 쓴다.**

```
fix: 서비스 워커가 페이지를 제어하지 않으면 한 번 새로고침

강력 새로고침은 서비스 워커를 거치지 않아 /api 요청이 개발 서버의
index.html(200)로 떨어지고, 화면에 오류가 떴다.
MSW 시작 후 controller가 없으면 한 번만 일반 새로고침해서 제어권을 되찾는다.
무한 새로고침을 막기 위해 sessionStorage에 표시를 남긴다.

Refs #12
```

- 형식: `<type>: <한국어 제목>` (Conventional Commits). 제목은 50자 안팎, 마침표 없이.
- 본문에는 코드로 알 수 없는 "왜"와 "택하지 않은 것"을 쓴다.
- 꼬리말에 `Refs #이슈번호`를 단다.
- 커밋은 의미 단위로 나눈다.

### 진행 기록 (이슈 댓글)

커밋마다 쓰지 않는다. **나중에 맥락을 이해하는 데 필요한 순간**에만 남긴다.

| 이럴 때 | 댓글 내용 |
| --- | --- |
| 브리프에 없던 사실을 발견했을 때 | 발견한 것, 근거, 영향 |
| 범위·해법이 바뀌었을 때 | 무엇이 왜 바뀌었는지, 사용자가 확정한 내용 |
| 막혔을 때 | 막힌 지점, 시도한 것, 필요한 결정 |
| 범위 밖 문제를 발견했을 때 | 문제 요약과 "별도 이슈 제안" (고치지 않는다) |

범위나 해법을 바꾸는 결정은 clarify-intent 규칙대로 **사용자에게 먼저 확정받고** 댓글로 남긴다.

## 4. 작업 마무리: PR을 보고서로

1. `verify-solution` 스킬로 검증하고, 결과를 PR 본문 "검증 결과"에 채운다.
2. PR 본문 전체를 최신 상태로 갱신한다.
3. 통합 브랜치가 앞서 나갔으면 최신화한다: `git fetch && git rebase origin/develop` 후 `git push --force-with-lease`.
4. `gh pr ready <번호>`로 Draft를 해제한다.
5. 사용자에게 PR 링크와 한두 줄 요약을 알리고 **머지 승인을 요청한다.** 그 턴은 거기서 끝낸다.

### PR 본문

````markdown
## 이슈
#12

## 의도
(이슈의 상위 목표 한두 줄)

## 해법을 바꾼 경위
(작업 중 해법이 바뀌었을 때만)

## 그림으로 보기
(구조를 바꿨을 때만. Mermaid 다이어그램)

## 무엇을 바꿨나
- (동작·개념 단위로)

## 어떻게 바꿨나
- (구현 단위로, 파일 링크와 함께)

## 검증 결과
(verify-solution의 이슈 대조표, 실행 결과, 확인하지 못한 것)

## 리뷰 포인트
- (사용자가 특히 확인하면 좋을 판단이나 위험)

## 이후 비용·위험
(새 복잡도, 의존성. 없으면 "없음")
````

### 그림으로 보기

구조를 바꾼 PR은 **구조를 바꿨을 때만** Mermaid 다이어그램을 넣는다.

| 넣는다 | 넣지 않는다 |
| --- | --- |
| 모듈·파일 사이의 의존 방향이 바뀜 | 문구·스타일만 바뀜 |
| 규칙·책임이 다른 곳으로 옮겨짐 | 함수 하나 안의 구현만 바뀜 |
| 호출·데이터 흐름이나 시간 순서가 바뀜 | 문서·테스트만 바뀜 |

- 형식: GitHub Mermaid (`flowchart`, `sequenceDiagram`, `gantt`)
- 전/후 한 쌍으로 그린다. 노드 이름은 실제 파일·함수 이름을 쓴다.

## 5. 작업 PR 머지 (승인 후)

squash 머지한다. **머지 메시지는 PR 전체의 의도를 한 커밋으로 정리**한 것이다.

```bash
gh pr merge 13 --squash \
  --subject "fix: 제목 (#13)" \
  --body-file - <<'EOF'
(변경의 이유와 핵심 내용 2~3줄)

Refs #12
EOF
```

base가 develop이라 `Closes #12`로는 이슈가 자동으로 닫히지 않는다. 머지 후 직접 닫는다.

```bash
gh issue close 12 --comment "#13 으로 develop에 반영했습니다."
```

### 작업 브랜치 삭제

PR 머지·이슈 닫힘을 확인한 뒤 브랜치를 지운다.

```bash
gh pr view 13 --json state --jq .state      # MERGED
gh issue view 12 --json state --jq .state   # CLOSED

git switch develop && git pull --ff-only
git push origin --delete fix/12-guard-msw-hard-reload
git branch -D fix/12-guard-msw-hard-reload
git fetch --prune
```

## 6. 릴리스: 통합 브랜치 → main

main은 **"지금 배포해도 되는 상태"**만 가리킨다. 모든 개발이 끝날 때까지 기다리지 않고, 마일스톤에 도달해 검증을 통과할 때마다 릴리스한다.

### 언제 릴리스하나

작업 PR을 머지하고 브랜치를 정리할 때마다 확인한다.

```
이번 마일스톤의 이슈가 모두 닫혔나?  (gh issue list --milestone vX.Y.Z --state open)
  아니오 → 다음 작업
  예 → 아래 릴리스 조건 검사
          실패 → 고칠 이슈를 만들어 같은 마일스톤에 넣는다
          통과 → 릴리스 PR → 승인 요청
```

### 릴리스 조건

1. 통합 브랜치의 최신 커밋에서 **CI가 통과**했다. 로컬에서도 typecheck, test, build를 실행한다.
2. 주요 흐름을 `verify-solution`으로 확인했다.
3. README가 이 릴리스의 실제 상태와 맞다.

### 릴리스 PR

```bash
gh pr create --base main --head develop \
  --title "release: vX.Y.Z 릴리스 설명" \
  --body-file - <<'EOF'
## 마일스톤
vX.Y.Z — (마일스톤 설명)

## 이번에 들어가는 작업
(닫힌 이슈 목록)

## 릴리스 조건
- CI: <sha> 통과
- 로컬: typecheck ✓ · test N개 통과 · build ✓
- E2E 확인 흐름: ...

## 알고 있는 한계
EOF
```

### 승인 후: 머지, 태그, Release

```bash
gh pr merge <번호> --merge --subject "release: vX.Y.Z (#<번호>)"
git switch main && git pull --ff-only
git tag -a vX.Y.Z -m "vX.Y.Z 릴리스 설명"
git push origin vX.Y.Z
gh release create vX.Y.Z --title "vX.Y.Z" --generate-notes
git switch develop
```

### 릴리스 후 버그

hotfix 브랜치를 만들지 않는다. 이슈 → 작업 브랜치 → 통합 브랜치에서 고치고, 릴리스 조건을 다시 검사해 패치 릴리스(`vX.Y.Z+1`)로 내보낸다.

## PR 현황 정리

```bash
gh pr list --state open --json number,title,isDraft,headRefName,baseRefName
gh issue list --state open --json number,title
```

## 처음 한 번: 저장소 준비

```bash
git init -b main
git add -A && git commit -m "chore: 초기 커밋"
gh repo create <이름> --private --source . --push
git switch -c develop && git push -u origin develop   # develop 운용 시
```

## 하지 말 것

- 확정 전에 이슈·브랜치·PR 만들기
- main·develop에 직접 커밋하거나 force push하기
- 사용자 승인 없이 머지하기
- 릴리스 조건을 검사하지 않고 main에 머지하기
- 머지·이슈 닫힘을 확인하기 전에 작업 브랜치 지우기
- 커밋·머지 메시지에 의도 없는 말만 쓰기 ("수정", "fix bug")
- 이슈와 다르게 작업하고 PR에서 그 사실을 빼기
