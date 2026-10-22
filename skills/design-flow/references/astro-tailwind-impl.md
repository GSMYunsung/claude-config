# Astro v6 + Tailwind v4 구현 패턴

Phase 5에서 사용. Figma 브리프를 코드로 옮길 때 따르는 패턴.

---

## 1. Tailwind v4 토큰 설정

Tailwind v4는 `tailwind.config.js` 대신 CSS `@theme` 블록으로 설정한다.

```css
/* src/styles/tokens.css */
@import "tailwindcss";

@theme {
  /* 컬러 */
  --color-bg:      #0f0f0f;
  --color-surface: #1a1a1a;
  --color-text:    #e8e8e8;
  --color-accent:  #a0f0c0;
  --color-muted:   #6b7280;

  /* 타이포그래피 */
  --font-display: 'Fragment Mono', ui-monospace, monospace;
  --font-body:    'Inter', system-ui, sans-serif;

  /* 간격 스케일 (8px 배수) */
  --spacing-section: 6rem;   /* 96px 섹션 상하 여백 */
  --spacing-container: 1.5rem; /* 좌우 패딩 */

  /* 최대 너비 */
  --max-w-content: 72rem;  /* 1152px */
  --max-w-prose:   42rem;  /* 672px 블로그 본문 */
}
```

Astro에서 전역 적용:
```astro
<!-- src/layouts/Layout.astro -->
---
import '../styles/tokens.css';
---
```

---

## 2. 컴포넌트 구조

```
src/
├── styles/
│   ├── tokens.css       # @theme 정의
│   └── prose.css        # 블로그 본문 스타일
├── layouts/
│   └── Layout.astro     # HTML shell + 전역 스타일
├── components/
│   ├── Header.astro
│   ├── Footer.astro
│   ├── Hero.astro
│   ├── ProjectCard.astro
│   └── islands/         # client:* 가 필요한 컴포넌트만
│       └── ThemeToggle.tsx
└── pages/
    ├── index.astro
    └── blog/
        └── [slug].astro
```

---

## 3. 애니메이션 패턴

### 원칙: CSS 먼저, JS는 필요할 때만

| 상황 | 방법 | Astro directive |
|------|------|----------------|
| hover, focus transition | CSS `transition` | 없음 (`.astro` 파일) |
| 스크롤 진입 fade | CSS Scroll-driven | 없음 |
| 변수 폰트 scroll 반응 | CSS Scroll-driven | 없음 |
| 모달, AnimatePresence | Framer Motion | `client:load` |
| 공유 요소 전환(layoutId) | Framer Motion | `client:load` |
| 페이지 전환 | View Transitions API | Astro 내장 |

### CSS Scroll-driven 진입 효과

```css
/* src/styles/tokens.css에 추가 */
@keyframes fade-up {
  from { opacity: 0; transform: translateY(1.5rem); }
  to   { opacity: 1; transform: translateY(0); }
}

.animate-on-scroll {
  animation: fade-up linear both;
  animation-timeline: view();
  animation-range: entry 0% entry 35%;
}

@media (prefers-reduced-motion: reduce) {
  .animate-on-scroll { animation: none; }
}
```

### 변수 폰트 키네틱 타이포그래피

```css
@keyframes weight-in {
  from { font-variation-settings: 'wght' 300, 'opsz' 8; }
  to   { font-variation-settings: 'wght' 800, 'opsz' 40; }
}

.hero-title {
  animation: weight-in linear;
  animation-timeline: scroll(root);
  animation-range: 0% 25%;
}

@media (prefers-reduced-motion: reduce) {
  .hero-title {
    animation: none;
    font-variation-settings: 'wght' 700, 'opsz' 40;
  }
}
```

### 호버 micro-interaction (animate 스킬 참조)

```css
.project-card {
  transition: transform 200ms cubic-bezier(.23, 1, .32, 1),
              box-shadow 200ms cubic-bezier(.23, 1, .32, 1);
}
.project-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.3);
}
```

---

## 4. Astro Island 패턴

인터랙티브 컴포넌트만 Island로 분리한다:

```astro
---
// src/pages/index.astro
import ThemeToggle from '../components/islands/ThemeToggle.tsx';
---

<!-- 정적 컴포넌트: directive 없음 -->
<Hero />
<ProjectGrid />

<!-- Island: 클라이언트에서 hydrate -->
<ThemeToggle client:load />
```

```tsx
// src/components/islands/ThemeToggle.tsx
import { useState } from 'react';

export default function ThemeToggle() {
  const [dark, setDark] = useState(true);
  return (
    <button
      onClick={() => setDark(!dark)}
      style={{ transition: 'transform 100ms ease-out' }}
      onMouseDown={(e) => (e.currentTarget.style.transform = 'scale(0.95)')}
      onMouseUp={(e) => (e.currentTarget.style.transform = 'scale(1)')}
    >
      {dark ? '☀️' : '🌙'}
    </button>
  );
}
```

---

## 5. Astro View Transitions (페이지 전환)

```astro
<!-- src/layouts/Layout.astro -->
---
import { ViewTransitions } from 'astro:transitions';
---
<head>
  <ViewTransitions />
</head>
```

컴포넌트에 이름 부여로 공유 요소 전환:
```astro
<img
  src={project.thumbnail}
  alt={project.title}
  transition:name={`project-img-${project.slug}`}
/>
```

---

## 6. 웹폰트 최적화

```astro
<!-- src/layouts/Layout.astro <head> -->
<link
  rel="preload"
  href="/fonts/InterVariable.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>
```

```css
/* src/styles/tokens.css */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/InterVariable.woff2') format('woff2');
  font-weight: 100 900;
  font-style: normal;
  font-display: swap;
}
```

---

## 7. 블로그 prose 스타일

```css
/* src/styles/prose.css */
.prose {
  max-width: var(--max-w-prose);
  color: var(--color-text);
  line-height: 1.75;
}
.prose h2 {
  font-family: var(--font-display);
  font-size: 1.5rem;
  margin-top: 2.5rem;
  margin-bottom: 1rem;
}
.prose code {
  font-family: var(--font-display);
  font-size: 0.875em;
  background: var(--color-surface);
  padding: 0.15em 0.4em;
  border-radius: 0.25rem;
}
.prose pre {
  background: var(--color-surface);
  padding: 1.25rem;
  border-radius: 0.5rem;
  overflow-x: auto;
}
```

---

## 8. 완료 기준 체크

```bash
# 빌드 확인
pnpm build

# 타입 체크 (TypeScript Island가 있을 때)
pnpm tsc --noEmit

# Lighthouse (로컬 미리보기)
pnpm preview
# → Chrome DevTools → Lighthouse → Performance ≥ 90
```
