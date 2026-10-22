---
name: design-flow
description: Astro v6 + Tailwind v4 포트폴리오+블로그(yuncastlee)에 최적화된 end-to-end 디자인 워크플로우. 2026 트렌드 개념을 Claude 디자인 스킬(design-taste-frontend, frontend-design, animate)에서 수집·선별하고, 디자인 브리프를 작성한 뒤 Figma MCP로 구현하고 코드로 옮긴다. "디자인해줘", "새 UI 만들어줘", "섹션 디자인", "Figma로 먼저 보여줘", "디자인 다시 해줘", "컴포넌트 디자인" 요청에 사용한다.
---

# design-flow

**프로젝트:** Astro v6 + Tailwind v4 · `/프로젝트/portfolio-blog` · yuncastlee  
**흐름:** 트렌드 선별 → 브리프 → Figma MCP 구현 → 코드 구현

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

## Phase 1: 트렌드 수집 & 컨텍스트 선별

목적: 이 포트폴리오에 실제로 적합한 2026 디자인 개념 3~5개를 고른다.

### 1-A. 트렌드 소스

`references/trend-concepts.md`를 읽어 사전 정리된 트렌드와 Astro 호환성 평가를 불러온다.

각 Claude 디자인 스킬에서 참조할 핵심 개념:

| 스킬 | 참조할 개념 |
|------|------------|
| `design-taste-frontend` | Section 0 BRIEF INFERENCE → 다이얼(VARIANCE/MOTION/DENSITY) 설정법 |
| `frontend-design` | 토큰 시스템(color/type/layout/signature) 브레인스토밍 방식, 자기 비판 원칙 |
| `animate` | easing 치트시트, scroll-driven 패턴, GPU 가속 규칙 |

### 1-B. 선별 기준

다음 조건을 모두 충족하는 개념만 선택한다:
- **Astro Islands 호환**: 불필요한 client-side hydration 없이 구현 가능
- **Tailwind v4 CSS-first 구현 가능**: CSS variables + `@theme` 블록으로 표현 가능
- **Core Web Vitals 안전**: CLS, LCP에 영향 없음
- **포트폴리오 캐릭터**: 개발자 포트폴리오+블로그 (recruiter + fellow developer 대상)

### 1-C. 선별 결과 보고

```
| # | 개념명 | 출처 스킬 | Astro 구현 방법 | 채택 이유 |
```

사용자 승인 후 Phase 2 진행.

---

## Phase 2: 디자인 브리프 작성

목적: 선별된 개념을 구체적인 토큰 시스템과 레이아웃 방향으로 정의한다.

### 2-A. 디자인 읽기 선언 (design-taste-frontend Section 0.B 형식)

> "Reading this as: [페이지 종류] for [대상], with a [분위기] language, leaning toward [방향]."

### 2-B. 다이얼 설정

포트폴리오(Developer) 기본값: `VARIANCE: 6 / MOTION: 5 / DENSITY: 4`  
조정이 필요하면 이유를 한 줄로 남긴다.

**Anti-default 체크** (`design-taste-frontend` Section 0.D):
- AI 보라색 그라디언트 → 교체
- Inter + slate-900 기본 조합 → 교체
- 3개 equal feature cards → 교체
- Centered hero over dark mesh → 교체

### 2-C. 토큰 시스템 정의

```
## 컬러 (4–6개)
--color-bg:      #...  배경
--color-surface: #...  카드/패널
--color-text:    #...  본문
--color-accent:  #...  강조
--color-muted:   #...  보조 텍스트

## 타이포그래피
Display: [서체] — [사용처 + 선택 이유]
Body:    [서체] — [사용처 + 선택 이유]
Mono:    [서체] — [코드 블록/라벨]

## 레이아웃
최대 너비: [px] / 그리드: [컬럼 × 간격]
ASCII 와이어프레임 (핵심 섹션 1–2개)

## 시그니처 요소
[이 디자인을 기억하게 만드는 단 하나의 요소 + 이유]
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
