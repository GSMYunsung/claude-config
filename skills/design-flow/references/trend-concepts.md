# 2026 디자인 트렌드 개념 & Astro 호환성

포트폴리오+블로그 (Astro v6 + Tailwind v4) 맥락에서 평가한 트렌드 목록.

---

## 1. Kinetic Typography (키네틱 타이포그래피)

**내용:** 타이포그래피가 정적이지 않다. Variable font를 이용해 스크롤·호버·페이지 로드에 반응해 weight, width, optical size가 변한다. 글자 자체가 페이지의 첫인상을 만든다.

**Astro 호환성:** ✅ 높음
- CSS Scroll-driven Animations + `font-variation-settings`로 JS 없이 구현 가능
- Variable font 하나로 모든 weight 커버 (성능 이점)
- Tailwind v4 `@theme`에 font-weight 토큰 등록

**참조 스킬:** `frontend-design` (타이포그래피 원칙), `animate` (scroll-driven 패턴)

**구현 예시:**
```css
@keyframes weight-in {
  from { font-variation-settings: 'wght' 300; }
  to   { font-variation-settings: 'wght' 700; }
}
.hero-title {
  animation: weight-in linear;
  animation-timeline: scroll(root);
  animation-range: 0% 30%;
}
@media (prefers-reduced-motion: reduce) {
  .hero-title { animation: none; font-variation-settings: 'wght' 700; }
}
```

**채택 판단:** 개발자 포트폴리오에서 기술력을 은근히 드러내는 방법. 과도하게 쓰면 산만해짐 — 히어로 헤드라인 1~2곳에만 사용.

---

## 2. Scroll-driven Animations (CSS 네이티브)

**내용:** 2026 주요 브라우저 지원 완성. `animation-timeline: scroll()` / `view()` 를 이용해 스크롤 위치에 따라 요소가 나타나고 변한다. JS 없이 부드러운 진입 효과.

**Astro 호환성:** ✅ 매우 높음
- 완전히 CSS only → Astro 기본값(zero-JS)과 완벽 호환
- Framer Motion 의존성 불필요 (번들 크기 절약)
- Fallback: `@supports` + 단순 opacity 처리

**참조 스킬:** `animate` (scroll-driven 패턴 섹션)

**구현 패턴:**
```css
@keyframes fade-up {
  from { opacity: 0; transform: translateY(24px); }
  to   { opacity: 1; transform: translateY(0); }
}
.section-card {
  animation: fade-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 40%;
}
```

**채택 판단:** 거의 모든 섹션 진입에 적용 가능. 과도하면 모든 것이 '튀어나오는' 느낌이 됨 — 진입 시 한 번, 핵심 정보에만 사용.

---

## 3. Broken Grid / Editorial Layout

**내용:** 규칙적인 12컬럼 그리드를 벗어나, 요소들이 의도적으로 겹치거나 비대칭 배치된다. 신문·잡지 편집 디자인에서 온 감각. 시각적 긴장감과 개성을 만든다.

**Astro 호환성:** ✅ 높음
- CSS Grid `grid-template-areas` + 음수 `margin` + `z-index` 조합
- Tailwind v4 임의값(`grid-cols-[...]`, `col-start-[...]`)으로 표현 가능
- 정적 Astro 컴포넌트로 충분 (JS 불필요)

**참조 스킬:** `design-taste-frontend` (DESIGN_VARIANCE: 8+ 일 때), `frontend-design` (Structure is information)

**주의:** 모바일에서 레이아웃이 무너지기 쉬움 — 반드시 mobile-first fallback 설계 필요.

**채택 판단:** 프로젝트 쇼케이스 섹션에 적합. 전체 페이지에 적용하면 피로감. 1~2개 섹션에만 포인트로 사용.

---

## 4. Micro-interactions & Restraint

**내용:** 화려한 애니메이션보다 정밀하게 설계된 소형 인터랙션이 트렌드. 버튼 클릭, 링크 호버, 카드 진입 등에서 감촉적 피드백을 준다. 과도한 모션은 오히려 AI 생성물처럼 보임.

**Astro 호환성:** ✅ 매우 높음
- `animate` 스킬의 CSS only 패턴으로 전부 구현 가능
- transform + opacity만 애니메이션 (GPU 가속, CLS 없음)

**참조 스킬:** `animate` (easing 치트시트, hover lift, button press)

**핵심 규칙 (animate 스킬에서):**
- Enter: `ease-out` 200–300ms
- Exit: `ease-in` 150–200ms  
- Hover: `ease` 150ms
- transform + opacity만 사용 (layout 속성 절대 애니메이션 금지)

**채택 판단:** 모든 인터랙티브 요소에 기본 적용. 디자인의 완성도를 결정하는 요소.

---

## 5. Typography-first Hero

**내용:** 이미지나 그라디언트가 아닌 타이포그래피 자체가 히어로를 구성. 큰 디스플레이 서체, 의도적인 여백, 서체 크기 대비가 첫 인상을 만든다. `design-taste-frontend`의 Anti-Default와 직결.

**Astro 호환성:** ✅ 매우 높음
- 순수 HTML + CSS
- 웹폰트 최적화: `font-display: swap`, `preload` 링크 태그

**참조 스킬:** `design-taste-frontend` (Section 0.D Anti-Default), `frontend-design` (Typography carries personality)

**포트폴리오에서 좋은 이유:** 개발자가 디자인 감각이 있음을 암묵적으로 증명. 이미지 없이도 강한 첫 인상.

**채택 판단:** yuncastlee 포트폴리오의 홈 히어로에 강력 추천.

---

## 트렌드 우선순위 요약

| 순위 | 개념 | 적용 범위 | 구현 난이도 |
|------|------|----------|------------|
| 1 | Micro-interactions | 전체 인터랙티브 요소 | 낮음 |
| 2 | Scroll-driven Animations | 섹션 진입 | 낮음 |
| 3 | Typography-first Hero | 홈 히어로 | 낮음 |
| 4 | Kinetic Typography | 히어로 헤드라인 1–2곳 | 중간 |
| 5 | Broken Grid | 프로젝트 쇼케이스 | 중간 |

---

## 피해야 할 AI 기본값

`design-taste-frontend` Section 0.D 기준:
- AI-purple gradient backgrounds
- Centered hero over dark mesh
- 3개 equal feature cards (`grid-cols-3`)
- Generic glassmorphism on everything
- Infinite-loop micro-animations everywhere
- Inter + slate-900 기본 조합
