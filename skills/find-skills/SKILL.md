---
name: find-skills
description: 사용자가 "X를 어떻게 하나요", "X 스킬 찾아줘", "X를 할 수 있는 스킬이 있나요" 같은 질문을 하거나 기능 확장에 관심을 보일 때 스킬을 탐색하고 설치하는 데 도움을 준다. 설치 가능한 스킬로 해결할 수 있는 기능을 찾고 있을 때 이 스킬을 사용한다.
---

# 스킬 탐색

이 스킬은 오픈 에이전트 스킬 생태계에서 스킬을 탐색하고 설치하는 데 도움을 준다.

## 이 스킬을 사용할 때

사용자가 아래와 같은 상황일 때 이 스킬을 사용한다:

- "X를 어떻게 하나요"라고 묻는데, X가 기존 스킬로 해결 가능한 일반적인 작업인 경우
- "X 스킬 찾아줘" 또는 "X 스킬이 있나요"라고 말할 때
- "X를 할 수 있어요?"라고 묻는데, X가 전문적인 기능인 경우
- 에이전트 기능 확장에 관심을 보일 때
- 도구, 템플릿, 워크플로우를 검색하고 싶을 때
- 특정 분야(디자인, 테스트, 배포 등)에서 도움이 필요하다고 언급할 때

## Skills CLI란?

Skills CLI(`npx skills`)는 오픈 에이전트 스킬 생태계를 위한 패키지 매니저다. 스킬은 전문 지식, 워크플로우, 도구를 통해 에이전트 기능을 확장하는 모듈식 패키지다.

**주요 명령어:**

- `npx skills find [query] [--owner <owner>]` - 키워드로 스킬 검색, GitHub 소유자로 범위 한정 가능
- `npx skills add <package>` - GitHub 등에서 스킬 설치
- `npx skills check` - 스킬 업데이트 확인
- `npx skills update` - 설치된 스킬 전체 업데이트

**스킬 둘러보기:** https://skills.sh/

## 사용자가 스킬을 찾도록 돕는 방법

### 1단계: 필요한 것 파악

사용자가 도움을 요청하면 아래를 확인한다:

1. 도메인 (예: React, 테스트, 디자인, 배포)
2. 구체적인 작업 (예: 테스트 작성, 애니메이션 만들기, PR 리뷰)
3. 스킬이 존재할 만큼 일반적인 작업인지 여부

### 2단계: 리더보드 먼저 확인

CLI 검색을 실행하기 전에 [skills.sh 리더보드](https://skills.sh/)에서 해당 도메인에 잘 알려진 스킬이 있는지 확인한다. 리더보드는 총 설치 수 기준으로 순위를 매겨 가장 인기 있고 검증된 스킬을 보여준다.

예를 들어, 웹 개발 분야 상위 스킬:
- `vercel-labs/agent-skills` — React, Next.js, 웹 디자인 (각 100K+ 설치)
- `anthropics/skills` — 프론트엔드 디자인, 문서 처리 (100K+ 설치)

### 3단계: 스킬 검색

리더보드에 필요한 스킬이 없으면 find 명령어를 실행한다:

```bash
npx skills find [query] [--owner <owner>]
```

예시:

- 사용자: "React 앱을 더 빠르게 만들고 싶어요" → `npx skills find react performance`
- 사용자: "PR 리뷰 도와줄 수 있어요?" → `npx skills find pr review`
- 사용자: "체인지로그 만들어야 해요" → `npx skills find changelog`

### 4단계: 추천 전 품질 검증

**검색 결과만 보고 스킬을 추천하지 않는다.** 항상 아래를 확인한다:

1. **설치 수** — 1K 이상인 스킬을 선호한다. 100 미만은 주의한다.
2. **출처 신뢰도** — 공식 출처(`vercel-labs`, `anthropics`, `microsoft`)가 알 수 없는 작성자보다 신뢰할 수 있다.
3. **GitHub 스타** — 소스 저장소를 확인한다. 스타가 100개 미만인 저장소의 스킬은 신중하게 판단한다.

### 5단계: 사용자에게 선택지 제시

관련 스킬을 찾으면 아래 정보와 함께 사용자에게 제시한다:

1. 스킬 이름과 기능 설명
2. 설치 수와 출처
3. 사용자가 실행할 설치 명령어
4. skills.sh에서 더 알아볼 수 있는 링크

응답 예시:

```
도움이 될 스킬을 찾았습니다! "react-best-practices" 스킬은
Vercel Engineering이 제공하는 React 및 Next.js 성능 최적화 가이드입니다.
(185K 설치)

설치하려면:
npx skills add vercel-labs/agent-skills@react-best-practices

더 알아보기: https://skills.sh/vercel-labs/agent-skills/react-best-practices
```

### 6단계: 설치 제안

사용자가 진행하길 원하면 스킬을 설치해 줄 수 있다:

```bash
npx skills add <owner/repo@skill> -g -y
```

`-g` 플래그는 전역(사용자 레벨) 설치, `-y`는 확인 프롬프트를 건너뛴다.

## 일반적인 스킬 카테고리

검색 시 아래 카테고리를 참고한다:

| 카테고리 | 검색어 예시 |
| --- | --- |
| 웹 개발 | react, nextjs, typescript, css, tailwind |
| 테스트 | testing, jest, playwright, e2e |
| DevOps | deploy, docker, kubernetes, ci-cd |
| 문서화 | docs, readme, changelog, api-docs |
| 코드 품질 | review, lint, refactor, best-practices |
| 디자인 | ui, ux, design-system, accessibility |
| 생산성 | workflow, automation, git |

## 효과적인 검색 팁

1. **구체적인 키워드 사용**: "react testing"이 단순한 "testing"보다 낫다
2. **유사어 시도**: "deploy"가 안 되면 "deployment" 또는 "ci-cd"를 시도한다
3. **인기 출처 확인**: 많은 스킬이 `vercel-labs/agent-skills` 또는 `ComposioHQ/awesome-claude-skills`에서 나온다

## 스킬을 찾지 못했을 때

관련 스킬이 없으면:

1. 기존 스킬이 없음을 알린다
2. 일반 기능으로 직접 작업을 도와주겠다고 제안한다
3. `npx skills init`으로 직접 스킬을 만들 수 있다고 안내한다

예시:

```
"xyz" 관련 스킬을 검색했지만 찾지 못했습니다.
이 작업은 제가 직접 도와드릴 수 있습니다! 진행할까요?

이 작업을 자주 한다면 직접 스킬을 만들어 보세요:
npx skills init my-xyz-skill
```
