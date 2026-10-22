# 성능 & 접근성 레퍼런스

## 성능

### 목표: 60 FPS

애니메이션은 초당 60프레임(프레임당 16.67ms)으로 부드럽게 동작해야 한다.

### GPU 가속 속성

하드웨어 가속이 적용되어 레이아웃 재계산을 일으키지 않는 속성:

| 속성 | 비고 |
|------|------|
| `transform` | translate, scale, rotate |
| `opacity` | 페이드 효과 |

### 애니메이션을 피해야 할 속성

레이아웃 재계산을 유발하여 비용이 크다:

- `width`, `height`
- `top`, `left`, `right`, `bottom`
- `margin`, `padding`
- `border-width`
- `font-size`

**대안**: width/height 대신 `transform: scale()`, top/left 대신 `transform: translate()`를 사용한다.

### will-change

브라우저에게 요소가 애니메이션될 것임을 미리 알려준다:

```css
.will-animate {
  will-change: transform, opacity;
}
```

**주의**: 아껴서 사용한다. 실제로 애니메이션되는 요소에만 적용하고, 가능하면 애니메이션 완료 후 제거한다. 남용하면 오히려 성능이 저하된다.

### GPU 강제 활성화

GPU 레이어를 강제로 생성한다 (아껴서 사용):

```css
.force-gpu {
  transform: translateZ(0);
  /* 또는 */
  backface-visibility: hidden;
}
```

### 성능 모니터링

1. **Chrome DevTools**: Performance 탭 → 애니메이션 중 녹화
2. **Rendering 탭**: "FPS meter"와 "Paint flashing" 활성화
3. **Layers 패널**: 레이어 합성 확인

### 자주 발생하는 성능 문제

| 문제 | 해결책 |
|------|--------|
| 끊기는 스크롤 | `top/left` 대신 `transform` 사용 |
| 느린 애니메이션 | 애니메이션되는 요소 수 줄이기 |
| 메모리 급증 | 애니메이션 중 새 객체 생성 피하기 |
| 레이아웃 스래싱 | DOM 읽기/쓰기 일괄 처리 |

## 접근성

### prefers-reduced-motion

사용자는 시스템 설정에서 줄어든 동작을 선호한다고 표시할 수 있다. 이 설정을 항상 존중한다.

#### CSS 구현

```css
/* 기본: 전체 애니메이션 */
.element {
  transition: transform 300ms ease-out;
}

/* 동작 감소를 선호하는 사용자에게는 줄이거나 제거 */
@media (prefers-reduced-motion: reduce) {
  .element {
    transition: none;
    /* 또는 최소한의 transition */
    transition: opacity 200ms ease-out;
  }
}
```

#### React / Framer Motion 구현

```tsx
import { useReducedMotion } from "framer-motion"

function AnimatedComponent() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <motion.div
      initial={{ opacity: 0, y: shouldReduceMotion ? 0 : 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: shouldReduceMotion ? 0 : 0.3 }}
    />
  )
}
```

#### MotionConfig로 전역 설정

```tsx
import { MotionConfig, useReducedMotion } from "framer-motion"

function App() {
  const shouldReduceMotion = useReducedMotion()

  return (
    <MotionConfig reducedMotion={shouldReduceMotion ? "always" : "never"}>
      {/* 내부의 모든 motion 컴포넌트가 이 설정을 따름 */}
      <YourApp />
    </MotionConfig>
  )
}
```

### MotionConfig 옵션

| 값 | 효과 |
|----|------|
| `"never"` | 일반 애니메이션 (기본값) |
| `"always"` | 모든 애니메이션 건너뜀 |
| `"user"` | 시스템의 `prefers-reduced-motion` 설정 따름 |

### 접근성 있는 애니메이션 가이드라인

1. **대체 수단 제공**: 애니메이션 없이도 콘텐츠에 접근할 수 있어야 함
2. **깜박임 금지**: 초당 3회 이상 깜박이는 콘텐츠 금지
3. **인터랙션 차단 금지**: 애니메이션이 사용자 조작을 막아선 안 됨
4. **짧게 유지**: 긴 애니메이션은 불편함을 준다
5. **목적 있는 동작**: 가치를 더할 때만 애니메이션한다
6. **일시정지 컨트롤**: 지속적인 애니메이션에는 정지/일시정지 기능 제공

### 애니메이션 중 포커스 관리

```tsx
// 애니메이션된 요소와 함께 포커스가 적절히 이동해야 함
function Modal({ isOpen }) {
  const modalRef = useRef(null)

  useEffect(() => {
    if (isOpen) {
      // 진입 애니메이션 완료 후 포커스 이동
      const timer = setTimeout(() => {
        modalRef.current?.focus()
      }, 300)
      return () => clearTimeout(timer)
    }
  }, [isOpen])

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          ref={modalRef}
          tabIndex={-1}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          모달 콘텐츠
        </motion.div>
      )}
    </AnimatePresence>
  )
}
```

### 동작 감소 테스트 방법

1. **macOS**: 시스템 환경설정 → 손쉬운 사용 → 디스플레이 → 동작 줄이기
2. **Windows**: 설정 → 접근성 → 디스플레이 → 애니메이션 표시
3. **iOS**: 설정 → 손쉬운 사용 → 동작 → 동작 줄이기
4. **Chrome DevTools**: Rendering 탭 → CSS 미디어 기능 에뮬레이션 → `prefers-reduced-motion`
