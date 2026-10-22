# Easing 및 타이밍 레퍼런스

## 핵심 원칙

애니메이션은 자연스럽고 목적이 있어야 한다. 인터페이스가 반응적으로 느껴지되, 애니메이션 자체에 시선이 집중되지 않도록 하는 것이 목표다.

## Easing 함수

### 상황별 Easing 선택 기준

| Easing | 사용 상황 | 타이밍 |
|--------|----------|--------|
| `ease-out` | 화면에 요소가 들어올 때 | 200-300ms |
| `ease-in-out` | 화면 위에서 요소가 이동할 때 | 200-300ms |
| `ease-in` | 화면에서 요소가 나갈 때 | 150-200ms |
| `ease` | 호버 효과 | 150ms |
| `linear` | opacity 변화, 프로그레스 바 | 상황에 따라 다름 |

### 커스텀 Easing 변수

일관된 애니메이션을 위해 CSS 커스텀 속성으로 정의한다:

```css
:root {
  /* 권장 easing 곡선 */
  --ease-out-quint: cubic-bezier(.23, 1, .32, 1);
  --ease-in-out-cubic: cubic-bezier(.645, .045, .355, 1);
  --ease-out-cubic: cubic-bezier(.33, 1, .68, 1);
  --ease-in-cubic: cubic-bezier(.32, 0, .67, 0);

  /* Spring 느낌 */
  --ease-out-back: cubic-bezier(.34, 1.56, .64, 1);
}
```

### Cubic Bezier 설명

`cubic-bezier(x1, y1, x2, y2)`는 두 개의 제어점으로 곡선을 정의한다:
- `(x1, y1)` — 첫 번째 제어점 (애니메이션 시작 부분에 영향)
- `(x2, y2)` — 두 번째 제어점 (애니메이션 끝 부분에 영향)

값이 1을 초과하면 `ease-out-back`처럼 오버슈트 효과가 생긴다.

## 타이밍 가이드라인

### 적절한 지속 시간

- **일반 애니메이션**: 200-300ms (가장 적합한 범위)
- **호버 효과**: 150ms
- **모달 진입**: 200ms
- **모달 퇴장**: 150ms (진입보다 퇴장이 빨라야 한다)
- **페이지 전환**: 300-400ms
- **마이크로 인터랙션**: 100-150ms

### 원칙

1. **퇴장이 진입보다 빠르게**: 퇴장 애니메이션은 진입 시간의 약 75%
2. **요소가 작을수록 빠르게**: 요소 크기에 비례해 시간 조정
3. **사용자가 직접 조작할수록 즉각 반응**: 직접 조작은 즉시 느껴져야 함
4. **시스템이 시작하는 것은 더 느려도 됨**: 배경 전환은 여유가 있음

## Spring 애니메이션

Spring은 중단 가능한 애니메이션과 자연스러운 동작에 탁월하다.

### Spring 파라미터

| 파라미터 | 효과 |
|-----------|------|
| `mass` | 물체의 무게 (높을수록 느리고 관성이 큼) |
| `tension` (stiffness) | 스프링의 강도 (높을수록 빠르고 반응적) |
| `friction` (damping) | 저항력 (높을수록 진동이 줄어듦) |
| `velocity` | 초기 속도 |

### Framer Motion Spring 설정

```tsx
// 반응적인 spring (UI 요소)
const snappy = { type: "spring", stiffness: 400, damping: 30 }

// 부드러운 spring (큰 요소)
const gentle = { type: "spring", stiffness: 200, damping: 20 }

// 튀는 spring (재미있는 인터랙션)
const bouncy = { type: "spring", stiffness: 300, damping: 10 }
```

### 시간 기반 Spring (Framer Motion)

```tsx
// 물리 대신 duration으로 제어
const durationSpring = {
  type: "spring",
  duration: 0.3,
  bounce: 0.2  // 0 = 튀지 않음, 1 = 최대로 튐
}
```

## 애니메이션을 쓰지 말아야 할 때

- 인터랙션을 차단하는 로딩 상태
- 즉각적인 주의가 필요한 오류 메시지
- 접근성: `prefers-reduced-motion` 준수
- 애니메이션이 경험에 아무 가치도 더하지 않을 때
- 사용자가 반복적으로 수행하는 빈번한 동작
