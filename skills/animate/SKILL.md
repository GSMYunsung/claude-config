---
name: animate
description: Next.js/React 애플리케이션을 위한 애니메이션 패턴 및 모범 사례. 애니메이션, 트랜지션, 호버 효과, 페이지 전환, 모달, React 컴포넌트의 모션 구현 시 사용.
---

# Next.js 애니메이션

## 개요

Next.js와 React 애플리케이션에서 부드럽고 성능 좋은 접근성 높은 애니메이션을 구현하는 방법을 안내하는 스킬이다. CSS 애니메이션, Framer Motion, 이징 원칙, 접근성을 다룬다.

## 빠른 참고

### 이징 치트시트

| 애니메이션 유형 | 이징 | 지속시간 |
|----------------|--------|----------|
| 요소 등장 | `ease-out` | 200-300ms |
| 화면 위 요소 이동 | `ease-in-out` | 200-300ms |
| 요소 퇴장 | `ease-in` | 150-200ms |
| 호버 효과 | `ease` | 150ms |
| 투명도만 변경 | `linear` | 상황에 따라 다름 |

### CSS 커스텀 속성 (권장)

```css
:root {
  --ease-out-quint: cubic-bezier(.23, 1, .32, 1);
  --ease-in-out-cubic: cubic-bezier(.645, .045, .355, 1);
  --ease-out-cubic: cubic-bezier(.33, 1, .68, 1);
}
```

## 자주 쓰는 애니메이션 패턴

### 1. 호버 띄우기 효과

```css
.card {
  transition: transform 200ms var(--ease-out-quint),
              box-shadow 200ms var(--ease-out-quint);
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}
```

### 2. 버튼 누르기

```css
.button {
  transition: transform 100ms ease-out;
}
.button:active {
  transform: scale(0.97);
}
```

### 3. 마운트 시 페이드인 (Framer Motion)

```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3, ease: [.23, 1, .32, 1] }}
>
  Content
</motion.div>
```

### 4. 퇴장 애니메이션이 있는 모달

```tsx
<AnimatePresence>
  {isOpen && (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  )}
</AnimatePresence>
```

### 5. 탭 인디케이터 (공유 레이아웃)

```tsx
{tabs.map(tab => (
  <button key={tab} onClick={() => setActive(tab)} className="relative px-4 py-2">
    {tab}
    {active === tab && (
      <motion.div
        layoutId="tab-indicator"
        className="absolute inset-0 bg-blue-500 rounded -z-10"
        transition={{ type: "spring", stiffness: 400, damping: 30 }}
      />
    )}
  </button>
))}
```

### 6. 스태거 리스트 애니메이션

```tsx
const container = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
}

const item = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
}

<motion.ul variants={container} initial="hidden" animate="visible">
  {items.map(i => <motion.li key={i} variants={item}>{i}</motion.li>)}
</motion.ul>
```

## 황금 규칙

1. **퇴장이 등장보다 빠르게**: 퇴장 애니메이션은 등장의 약 75% 길이로
2. **transform과 opacity만 애니메이트**: GPU 가속 대상이기 때문
3. **200-300ms가 최적**: 대부분의 애니메이션은 이 범위 안에
4. **prefers-reduced-motion 항상 준수**: 참고 자료의 접근성 섹션 참고
5. **중단 가능한 애니메이션엔 spring 사용**: 사용자가 도중에 중단할 때 더 나은 UX

## 예시

코스에서 제공하는 완성된 예시들이 `examples/` 디렉터리에 있다:

| 예시 | 설명 | 핵심 기법 |
|---------|-------------|----------------|
| `card-hover.tsx` | 호버 시 설명 슬라이드업 | CSS transitions, transform, opacity |
| `toast-stacking.tsx` | 토스트 알림 애니메이션 | CSS custom properties, data-* triggers |
| `text-reveal.tsx` | 글자 스태거 등장 | @keyframes, animation-delay, calc() |
| `shared-layout.tsx` | 요소 위치·크기 모프 | Framer Motion layoutId |
| `animate-height.tsx` | 높이 부드럽게 변경 | useMeasure, animate height |
| `multi-step-flow.tsx` | 방향성 있는 단계 마법사 | AnimatePresence, custom variants |
| `feedback-popover.tsx` | 버튼→팝오버 확장 | Nested layoutId, form states |
| `app-store-card.tsx` | iOS 스타일 카드 확장 | Multiple layoutId elements |

예시를 사용하려면: `Read examples/<이름>.tsx`

## 참고 자료

상세 문서는 아래 파일 참고:

- `references/easing-and-timing.md` - 이징 함수, 타이밍 가이드라인, spring 설정
- `references/css-animations.md` - Transforms, transitions, keyframes, clip-path
- `references/framer-motion.md` - Motion 컴포넌트, AnimatePresence, variants, 레이아웃 애니메이션, hooks
- `references/performance-accessibility.md` - 60fps 최적화, prefers-reduced-motion, 접근성

## 상황별 선택 가이드

| 상황 | 권장 방식 |
|----------|---------------------|
| 단순 호버 효과 | CSS transitions |
| 등장·퇴장 애니메이션 | Framer Motion + AnimatePresence |
| 레이아웃 변경 | Framer Motion `layout` prop |
| 공유 요소 트랜지션 | Framer Motion `layoutId` |
| 스크롤 연동 애니메이션 | Framer Motion `useScroll` |
| 복잡한 오케스트레이션 | Framer Motion variants |
| 드래그 인터랙션 | Framer Motion drag gestures |
| 성능 최우선 | CSS only + transforms |

## 의존성

Framer Motion 예시를 사용하려면:
```bash
pnpm add framer-motion react-use-measure usehooks-ts
```
