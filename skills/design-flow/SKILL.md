---
name: design-flow
description: Astro v6 + Tailwind v4 포트폴리오+블로그(yuncastlee)에 최적화된 end-to-end 디자인 워크플로우. 2026 트렌드 개념을 Claude 디자인 스킬(design-taste-frontend, frontend-design, animate)에서 수집·선별하고, 디자인 브리프를 작성한 뒤 Figma MCP로 구현하고 코드로 옮긴다. "디자인해줘", "새 UI 만들어줘", "섹션 디자인", "Figma로 먼저 보여줘", "디자인 다시 해줘", "컴포넌트 디자인" 요청에 사용한다.
---

# design-flow

**프로젝트:** Astro v6 + Tailwind v4 · `/프로젝트/portfolio-blog` · yuncastlee  
**흐름:** 아키타입 그라운딩 → DNA 발산·수렴 → 브리프 → Figma MCP 구현 → 코드 구현

---

## 사전 조건: Figma MCP 설정

처음 한 번만 실행하면 된다. 이미 설정됐으면 건너뛴다.

```bash
# 방법 A — 권장 (플러그인 방식)
claude plugin install figma@claude-plugins-official
# 설치 후 /plugin → Installed → figma → Enter → 브라우저에서 Allow access

# 방법 B — 수동 MCP 등록
claude mcp add --transport http --scope user figma https://mcp.figma.com/mcp
```

**요금제 안내:**

Figma MCP는 모든 플랜에서 무료로 연결 가능하다.

| 도구 유형 | 월 한도 |
|----------|--------|
| `generate_figma_design`, `use_figma` (write) | **한도 없음** (rate limit 제외) |
| `get_screenshot`, `get_design_context` 등 read 계열 | Starter 무료 플랜 기준 월 ~20회 |

→ 이 스킬은 write 도구(`generate_figma_design`)만 사용하므로 **무료 플랜으로 충분하다.**  
→ read 도구(`get_screenshot` 등)는 사용하지 않는다.

---

## Phase 0: 상태 점검

스킬을 불러오면 먼저 확인한다.

1. 작업 대상이 무엇인지 파악한다 (어떤 페이지/섹션/컴포넌트).
2. `_workspace/design-flow/` 존재 여부로 실행 유형 판단:
   - 디렉터리 없음 → Phase 1부터 전체 실행
   - 있고 일부 수정 요청 → 해당 Phase만 재실행
   - 있고 새 작업 → 기존 디렉터리를 타임스탬프 붙여 이동 후 새로 실행
3. 사용자가 Figma URL을 제공했으면 메모해둔다.
4. 작업 계획을 한 줄로 사용자에게 보고하고 확인받는다.

---

## Phase 1: 아키타입 그라운딩 & DNA 발산

목적: 통계 평균에서 벗어난 의도적 디자인 방향을 3개 후보로 발산한다.

### 1-A. 레퍼런스 읽기

다음 파일을 모두 읽는다:

1. `references/design-dna.md` — DNA 파이프라인, 12 아키타입, 8 Aesthetic Family, AI Tells
2. `references/trend-concepts.md` — 2026 트렌드와 Astro 호환성 평가
3. `references/impeccable-style.md` — 4가지 제품 모드, slop 규칙, okLCH

### 1-B. 아키타입 도출

브리프(목적·대상·성격 3단어)에서 아키타입을 도출한다. 사용자에게 묻지 않는다.

> 도출된 아키타입: **[이름]** — [한 줄 근거]  
> 호환 패밀리: [1순위], [2순위]

### 1-C. DNA 발산 — 3개 후보

후보마다 **다른 레퍼런스 쌍**을 그라운딩에 사용한다. 색조 패밀리도 겹치지 않아야 한다.

```
후보 A:
  그라운딩: [레퍼런스1의 속성] + [레퍼런스2의 속성]
  패밀리: [Aesthetic Family명]
  4축:
    Type voice:   [구체적 포지션]
    Color:        [시드 색조, 채도, 배경]
    Composition:  [그리드, 반경, 테두리]
    Motion:       [타이밍, 이징, 허용 움직임]
  시그니처 무브: [단 하나의 고유한 결정]

후보 B: (동일 형식)
후보 C: (동일 형식)
```

### 1-D. DNA 비판

선택 전에 3개 후보를 기준 기반으로 비판한다:
- **독특함**: 훈련 데이터 클러스터와 얼마나 다른가?
- **레지스터 적합성**: 포트폴리오 목적·대상에 맞는가?
- **Tell 스캔**: `references/design-dna.md`의 AI Tells 체크리스트 통과하는가?
- **Astro 구현 가능성**: Islands 없이 CSS-first로 구현 가능한가?

### 1-E. 발산 결과 보고

```
| 후보 | 그라운딩 | 패밀리 | 강점 | 위험 |
```

사용자 승인(또는 합성 지시) 후 Phase 2 진행.

---

## Phase 2: 디자인 브리프 작성

목적: 선별된 개념을 구체적인 토큰 시스템과 레이아웃 방향으로 정의한다.

### 2-A. 제품 모드 선언 (impeccable.style)

`references/impeccable-style.md`의 4가지 모드 중 이 페이지에 해당하는 것을 선언한다.

> 모드: **[Persuade / Read / Experience]** — [이유 한 줄]

- 홈, 프로젝트 소개 → **Persuade** (전환 흐름 우선, 하나의 CTA)
- 블로그 포스트 → **Read** (가독성 우선, 긴 줄 금지)
- About, 포트폴리오 메인 → **Experience** (몰입 우선, 시그니처 요소)

### 2-B. 디자인 읽기 선언 (design-taste-frontend Section 0.B 형식)

> "Reading this as: [페이지 종류] for [대상], with a [분위기] language, leaning toward [방향]."

### 2-C. 다이얼 설정

포트폴리오(Developer) 기본값: `VARIANCE: 6 / MOTION: 5 / DENSITY: 4`  
조정이 필요하면 이유를 한 줄로 남긴다.

**Anti-slop 체크** (`impeccable.style` + `references/design-dna.md` AI Tells 통합):

즉시 제거 (impeccable.style):
- AI beige/크림 팔레트, AI 보라색 그라디언트
- 이탤릭 세리프 디스플레이 제목
- 그래디언트 텍스트 (보라→핑크 등)
- 3개 equal feature cards
- 영웅 메트릭 레이아웃 (큰 숫자 3개 나열)
- pulsing dot, bounce 이징, 자동 스크롤 마퀴
- 래디얼 그래디언트 후광 배경
- "Passionate developer" 같은 빈 마케팅 카피

추가 금지 (design-for-ai AI Tells 2026-07):
- Inter/Roboto 기본 폰트 미결정 상태
- `#6366F1` / `#8B5CF6` / `#A855F7` 인디고-바이올렛 강조색
- Space Grotesk 기본 폰트 ("노력한 척" 2026 금지)
- 모든 것을 카드로 처리
- Tailwind/shadcn 기본값 `--radius` / 간격 스케일 미수정
- 0.08–0.12 불투명도 그림자 3개 이상 균일 적용
- 모든 텍스트 가운데 정렬

### 2-D. DNA 확정 & 토큰 시스템 정의

Phase 1에서 선택된 후보를 기반으로 4개 축을 확정하고 토큰으로 변환한다.

**DNA 선언 (design-dna.md 형식)**
```
그라운딩: [레퍼런스A의 속성] + [레퍼런스B의 속성]
아키타입: [이름]
패밀리:   [Aesthetic Family명]

Type voice:   [디스플레이 폰트 / 바디 폰트 / 스케일 비율 / 리딩]
Color:        [시드 색조(oklch hue) / 채도 / 배경 방식 / 하모니 / 강조색 수]
Composition:  [그리드 / 밀도 / 반경 / 테두리·그림자 / 지배 요소]
Motion:       [타이밍 범위 / 이징 / 허용 움직임 / 시그니처 전환]

지배 축: [어떤 축이 이 디자인의 정체성을 담당하는가]
```

**토큰 시스템 (oklch 색공간)**
```
## 컬러 (4–6개)
--color-bg:      oklch(...)  배경
--color-surface: oklch(...)  카드/패널
--color-text:    oklch(...)  본문
--color-accent:  oklch(...)  강조
--color-muted:   oklch(...)  보조 텍스트

## 타이포그래피 (Type voice 축 구현)
Display: [서체] — [사용처 + 선택 이유]
Body:    [서체] — [사용처 + 선택 이유]
Mono:    [서체] — [코드 블록/라벨]

## 레이아웃 (Composition 축 구현)
최대 너비: [px] / 그리드: [컬럼 × 간격]
ASCII 와이어프레임 (핵심 섹션 1–2개)

## 시그니처 무브 (design-dna.md: 하나의 고유한 결정)
[템플릿이 절대 만들어내지 못할 단 하나의 결정 + 이유]

## 하나의 승자 (impeccable.style)
[이 페이지에서 시선의 1순위를 차지하는 단 하나의 요소]
```

### 2-D. 브리프 저장

`_workspace/design-flow/brief.md`에 저장.  
사용자 승인 후 Phase 3 진행.

---

## Phase 3: Figma MCP 구현

목적: 승인된 브리프를 Figma MCP 도구로 직접 구현한다.

### 3-A. 파일 준비

- 사용자가 Figma 파일 URL(또는 node ID)을 제공했으면 그 파일에 작업한다.
- URL 없으면 `create_new_file`로 새 Design 파일을 생성하고 URL을 사용자에게 알린다.

### 3-B. 브리프 → Figma 구현

`generate_figma_design` 도구로 구현한다. 이 도구는 rate limit 제외이므로 호출 횟수를 의식하지 않아도 된다.

**구현 순서:**

| 호출 | 작업 내용 |
|------|----------|
| 1 | Variables 생성 — 브리프 컬러/타이포 토큰 전체를 한 번에 등록 |
| 2 | Desktop 프레임(1440px) + Mobile 프레임(375px) + 레이아웃 그리드 |
| 3 | Hero 섹션 (Typography-first, 시그니처 요소 포함) |
| 4 | Nav + Footer |
| 5 | 본문 섹션 (작업 대상에 맞게 — Projects, About 등) |

### 3-C. 완료 보고

전체 구현이 끝나면 Figma 파일 URL을 사용자에게 전달한다.  
사용자가 Figma에서 직접 확인하고 피드백을 주면 `generate_figma_design`으로 수정한다.  
사용자 최종 승인 후 Phase 4 진행.

---

## Phase 4: 코드 구현

목적: Figma 디자인을 Astro v6 + Tailwind v4 코드로 구현한다.

`references/astro-tailwind-impl.md`를 읽어 구현 패턴을 확인한다.

### 4-A. Figma → 코드 추출

`get_design_context`로 컴포넌트 단위 React + Tailwind 표현을 추출한다.  
Astro 컴포넌트 `.astro`로 변환하되, Tailwind 클래스는 `@theme` 토큰 변수로 교체한다.

프로젝트에 기존 컴포넌트가 있으면 `get_code_connect_map`으로 Figma ↔ 코드 매핑을 확인해 중복 생성을 피한다.

### 4-B. 토큰 → CSS variables 매핑

```css
/* src/styles/tokens.css */
@theme {
  --color-bg:      [brief 값];
  --color-surface: [brief 값];
  --color-text:    [brief 값];
  --color-accent:  [brief 값];
  --color-muted:   [brief 값];
}
```

### 4-C. 애니메이션 전략 (animate 스킬 easing 참조)

| 상황 | 방법 |
|------|------|
| hover, focus 전환 | CSS only (`transition`, `transform`) |
| 스크롤 트리거 | CSS Scroll-driven Animations (네이티브) |
| 복잡한 layout 전환, 공유 요소 | Framer Motion → Astro Island (`.tsx`) |
| 모달, AnimatePresence | Framer Motion → Astro Island (`.tsx`) |

`prefers-reduced-motion` 미디어 쿼리를 모든 애니메이션에 포함한다.

### 4-D. 구현 순서

1. `src/styles/tokens.css` — 토큰 정의
2. `src/layouts/Layout.astro` — 공유 레이아웃
3. `src/components/` — 섹션별 컴포넌트 (`.astro`)
4. 인터랙티브 요소 — Astro Island (`.tsx`) 로 분리
5. `src/styles/prose.css` — 블로그 포스트 스타일

### 4-E. 완료 기준

- `pnpm build` 에러 없음
- Lighthouse Performance ≥ 90
- Desktop/Mobile 반응형 확인

---

## 오류 처리

| 상황 | 처리 방법 |
|------|----------|
| Figma MCP 미설정 | 사전 조건 섹션의 설치 명령 안내 후 재시도 |
| Figma MCP 인증 만료 | `/plugin` → figma → 재인증 요청 |
| `generate_figma_design` 오류 | `get_metadata`로 파일 구조 확인 후 올바른 node ID로 재시도 |
| 브리프 미승인 | Phase 2로 돌아가 해당 토큰만 재정의 |
| 빌드 에러 | 근본 원인 진단 후 수정. `--no-verify` 등 우회 없음 |

---

## 테스트 시나리오

**정상 흐름:**
> "홈페이지 히어로 섹션 새로 디자인해줘"  
→ Phase 0 → 트렌드 선별 보고 → 승인 → 브리프 작성 → 승인 → Figma 구현 → URL 전달 → 사용자 확인·승인 → Astro 코드

**후속 수정:**
> "아까 만든 디자인에서 컬러만 바꿔줘"  
→ `_workspace/design-flow/` 확인 → Phase 2 컬러 토큰만 수정 → Phase 3 Figma 부분 재작업 → Phase 4 tokens.css 업데이트

**오류 흐름:**
> Figma MCP 인증이 만료된 상태로 Phase 3 진입  
→ 재인증 요청 → 완료 후 Phase 3부터 재개
