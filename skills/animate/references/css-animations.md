# CSS 애니메이션 레퍼런스

## Transform

Transform은 레이아웃에 영향을 주지 않고 요소의 위치·크기·회전을 변경한다. GPU 가속이 적용되어 성능이 좋다.

### Transform 함수

```css
/* 이동 (Translation) */
transform: translateX(10px);
transform: translateY(-20px);
transform: translate(10px, -20px);  /* X, Y */
transform: translate3d(10px, 20px, 30px);  /* X, Y, Z */

/* 크기 (Scale) */
transform: scale(1.1);  /* 균등 확대 */
transform: scaleX(0.5);
transform: scaleY(1.5);
transform: scale(0.5, 1.5);  /* X, Y */

/* 회전 (Rotation) */
transform: rotate(45deg);
transform: rotateX(45deg);  /* 3D — X축 기준 */
transform: rotateY(45deg);  /* 3D — Y축 기준 */
transform: rotateZ(45deg);  /* rotate()와 동일 */

/* 여러 transform 조합 */
transform: translateY(-10px) scale(1.05) rotate(5deg);
```

### Transform Origin

transform이 기준으로 삼는 점을 지정한다:

```css
transform-origin: center;  /* 기본값 */
transform-origin: top left;
transform-origin: 50% 100%;  /* 가운데 하단 */
transform-origin: 0 0;  /* 좌상단 모서리 */
```

### 3D Transform

```css
/* 부모에 3D 공간 활성화 */
.parent {
  perspective: 1000px;  /* 시점 거리 */
  perspective-origin: center;
}

/* 자식 요소에 3D transform 적용 */
.child {
  transform: rotateY(45deg);
  transform-style: preserve-3d;  /* 중첩 요소의 3D 유지 */
  backface-visibility: hidden;  /* 뒷면 숨기기 */
}
```

## Transition

Transition은 속성 변화를 시간에 걸쳐 애니메이션한다.

### 문법

```css
/* 개별 속성 */
transition-property: transform, opacity;
transition-duration: 200ms;
transition-timing-function: ease-out;
transition-delay: 0ms;

/* 단축형 */
transition: transform 200ms ease-out, opacity 150ms ease-out 50ms;
/*          속성      시간    타이밍   속성    시간    타이밍  지연 */
```

### 자주 쓰는 Transition 패턴

```css
/* 호버 시 카드 들어올리기 */
.card {
  transition: transform 200ms ease-out, box-shadow 200ms ease-out;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}

/* 버튼 누름 효과 */
.button {
  transition: transform 100ms ease-out;
}
.button:active {
  transform: scale(0.97);
}

/* 페이드 인/아웃 */
.element {
  opacity: 0;
  transition: opacity 200ms ease-out;
}
.element.visible {
  opacity: 1;
}
```

### 성능에 안전한 속성

GPU 가속이 적용되며 레이아웃 재계산을 일으키지 않는다:
- `transform`
- `opacity`

다음 속성은 애니메이션을 피한다 (레이아웃/페인트 유발):
- `width`, `height`
- `top`, `left`, `right`, `bottom`
- `margin`, `padding`
- `border-width`

## Keyframe 애니메이션

복잡한 다단계 애니메이션에 사용한다.

### 기본 문법

```css
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.element {
  animation: fadeIn 300ms ease-out forwards;
}
```

### Animation 속성

```css
animation-name: fadeIn;
animation-duration: 300ms;
animation-timing-function: ease-out;
animation-delay: 0ms;
animation-iteration-count: 1;  /* 또는 'infinite' */
animation-direction: normal;  /* 또는 'reverse', 'alternate' */
animation-fill-mode: forwards;  /* 'none', 'forwards', 'backwards', 'both' */
animation-play-state: running;  /* 또는 'paused' */

/* 단축형 */
animation: fadeIn 300ms ease-out 0ms 1 normal forwards;
```

### Fill Mode 설명

- `none`: 애니메이션 전후에 스타일 적용 없음
- `forwards`: 애니메이션 종료 후 마지막 keyframe 스타일 유지
- `backwards`: 지연 시간 동안 첫 번째 keyframe 스타일 적용
- `both`: forwards와 backwards 모두 적용

## Clip-Path 애니메이션

Clip-path는 요소를 마스킹하는 영역을 만들고, 이를 애니메이션할 수 있다.

### 자주 쓰는 도형

```css
/* 원 */
clip-path: circle(50% at center);
clip-path: circle(0% at center);  /* 숨김 */

/* 타원 */
clip-path: ellipse(50% 30% at center);

/* 사각형 (inset) */
clip-path: inset(0);  /* 전체 표시 */
clip-path: inset(50%);  /* 숨김 (중앙으로 축소) */
clip-path: inset(0 50% 0 0);  /* 오른쪽 절반 숨김 */
/* inset(상 우 하 좌) */

/* 다각형 */
clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%);  /* 사각형 */
clip-path: polygon(50% 0, 100% 100%, 0 100%);  /* 삼각형 */
```

### Clip-Path 애니메이션 예시 (이미지 비교 슬라이더)

```css
.before-image {
  clip-path: inset(0 50% 0 0);  /* 왼쪽 절반 표시 */
  transition: clip-path 0ms;  /* 즉시 업데이트 */
}

/* JavaScript가 슬라이더 위치에 따라 clip-path를 업데이트 */
```

### Clip-Path를 활용한 탭 인디케이터

```tsx
// 활성 탭 배경이 clip-path로 슬라이드
<div className="relative">
  {tabs.map((tab, index) => (
    <button
      key={tab}
      onClick={() => setActive(index)}
      className="relative z-10 px-4 py-2"
    >
      {tab}
    </button>
  ))}
  <div
    className="absolute inset-0 bg-blue-500 rounded transition-all duration-200"
    style={{
      clipPath: `inset(0 ${100 - (activeIndex + 1) * (100 / tabs.length)}% 0 ${activeIndex * (100 / tabs.length)}% round 8px)`
    }}
  />
</div>
```
