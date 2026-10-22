# Framer Motion 레퍼런스

Framer Motion은 React/Next.js 애플리케이션에 권장하는 애니메이션 라이브러리다.

## 설치

```bash
npm install framer-motion
# 또는
pnpm add framer-motion
```

## 기본 사용법

### Motion 컴포넌트

```tsx
import { motion } from "framer-motion"

// 모든 HTML 요소를 애니메이션 가능하게 변환
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.3, ease: "easeOut" }}
>
  Content
</motion.div>
```

### 주요 Props

| Prop | 설명 |
|------|------|
| `initial` | 시작 상태 (`false`로 비활성화 가능) |
| `animate` | 목표 상태 |
| `exit` | 퇴장 상태 (AnimatePresence 필요) |
| `transition` | 애니메이션 설정 |
| `whileHover` | 호버 중인 상태 |
| `whileTap` | 누르는 중인 상태 |
| `whileFocus` | 포커스 중인 상태 |
| `whileInView` | 뷰포트 안에 있는 상태 |

## AnimatePresence

퇴장 애니메이션에 필요하다. DOM에서 제거될 수 있는 요소를 감싼다.

```tsx
import { motion, AnimatePresence } from "framer-motion"

function Modal({ isOpen, onClose, children }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
        >
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  )
}
```

### AnimatePresence Props

```tsx
<AnimatePresence
  mode="wait"      // 'sync' | 'wait' | 'popLayout'
  initial={false}  // 마운트 시 초기 애니메이션 비활성화
  onExitComplete={() => {}}  // 모든 퇴장 완료 후 콜백
>
```

- `mode="sync"` (기본값): 진입과 퇴장이 동시에 발생
- `mode="wait"`: 퇴장이 완료된 후 진입 시작
- `mode="popLayout"`: 퇴장하는 요소를 레이아웃 흐름에서 제거

## Variants

Variants는 부모와 자식 간에 조율 가능한 애니메이션 상태를 정의한다.

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,  // 각 자식 사이의 지연
      delayChildren: 0.2,    // 자식 시작 전 초기 지연
    }
  }
}

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
}

function List({ items }) {
  return (
    <motion.ul
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {items.map(item => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.name}
        </motion.li>
      ))}
    </motion.ul>
  )
}
```

## 레이아웃 애니메이션

`layout` prop으로 레이아웃 변화를 자동으로 애니메이션한다.

```tsx
// 위치나 크기가 변할 때 자동으로 애니메이션
<motion.div layout>
  {isExpanded ? "확장된 콘텐츠" : "축소됨"}
</motion.div>

// 레이아웃 타입
<motion.div layout>  // 위치와 크기 모두 애니메이션
<motion.div layout="position">  // 위치만 애니메이션
<motion.div layout="size">  // 크기만 애니메이션
```

### 공유 레이아웃 애니메이션 (layoutId)

같은 `layoutId`를 가진 요소들이 서로 간에 애니메이션된다.

```tsx
function Tabs({ tabs, activeTab, setActiveTab }) {
  return (
    <div className="flex gap-2">
      {tabs.map(tab => (
        <button
          key={tab}
          onClick={() => setActiveTab(tab)}
          className="relative px-4 py-2"
        >
          {tab}
          {activeTab === tab && (
            <motion.div
              layoutId="tab-indicator"
              className="absolute inset-0 bg-blue-500 rounded -z-10"
              transition={{ type: "spring", stiffness: 400, damping: 30 }}
            />
          )}
        </button>
      ))}
    </div>
  )
}
```

### LayoutGroup

독립적인 애니메이션 간의 충돌을 방지하기 위해 레이아웃 애니메이션을 그룹화한다.

```tsx
import { LayoutGroup } from "framer-motion"

<LayoutGroup>
  <Tabs />  {/* 이 레이아웃 애니메이션과 */}
</LayoutGroup>
<LayoutGroup>
  <OtherTabs />  {/* 이것이 충돌하지 않음 */}
</LayoutGroup>
```

## 제스처

### 드래그

```tsx
<motion.div
  drag              // 양축 모두 활성화
  drag="x"          // 가로 방향만
  drag="y"          // 세로 방향만
  dragConstraints={{ left: 0, right: 300, top: 0, bottom: 200 }}
  dragElastic={0.2}     // 제약 범위 밖 탄성 (0-1)
  dragMomentum={true}   // 놓은 후 관성 유지
  dragTransition={{ bounceStiffness: 600, bounceDamping: 20 }}
  onDragStart={(event, info) => {}}
  onDrag={(event, info) => {}}
  onDragEnd={(event, info) => {}}
>
  드래그하세요
</motion.div>
```

### 드래그 Info 객체

```tsx
onDrag={(event, info) => {
  info.point    // { x, y } 현재 위치
  info.delta    // { x, y } 이전 프레임 대비 변화량
  info.offset   // { x, y } 드래그 시작점으로부터의 이동량
  info.velocity // { x, y } 현재 속도
}}
```

## Motion Values & Hooks

### useMotionValue

리렌더링 없이 업데이트되는 값을 만든다.

```tsx
import { motion, useMotionValue, useTransform } from "framer-motion"

function Component() {
  const x = useMotionValue(0)

  // x 위치를 opacity로 변환
  const opacity = useTransform(x, [-100, 0, 100], [0, 1, 0])

  // x를 회전으로 변환
  const rotate = useTransform(x, [-100, 100], [-10, 10])

  return (
    <motion.div
      drag="x"
      style={{ x, opacity, rotate }}
    />
  )
}
```

### useSpring

Spring 애니메이션이 적용된 motion value를 만든다.

```tsx
import { useSpring, useMotionValue } from "framer-motion"

function Component() {
  const x = useMotionValue(0)
  const springX = useSpring(x, { stiffness: 300, damping: 30 })

  return (
    <motion.div
      onMouseMove={(e) => x.set(e.clientX)}
      style={{ x: springX }}
    />
  )
}
```

### useScroll

스크롤 진행도를 추적한다.

```tsx
import { useScroll, useTransform, motion } from "framer-motion"

function ProgressBar() {
  const { scrollYProgress } = useScroll()

  return (
    <motion.div
      className="fixed top-0 left-0 right-0 h-1 bg-blue-500 origin-left"
      style={{ scaleX: scrollYProgress }}
    />
  )
}

// 특정 컨테이너 내 스크롤
const { scrollYProgress } = useScroll({
  target: containerRef,
  offset: ["start end", "end start"]  // 추적 시작/종료 시점
})
```

### useInView

요소가 뷰포트에 진입하는 것을 감지한다.

```tsx
import { useInView } from "framer-motion"

function Component() {
  const ref = useRef(null)
  const isInView = useInView(ref, {
    once: true,      // 한 번만 트리거
    margin: "-100px" // 뷰포트 진입 100px 전에 트리거
  })

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 50 }}
      animate={isInView ? { opacity: 1, y: 0 } : {}}
    />
  )
}
```

## Transition 옵션

```tsx
const transition = {
  // 타이밍
  duration: 0.3,
  delay: 0.1,

  // Easing
  ease: "easeOut",  // 또는 배열: [0.23, 1, 0.32, 1]

  // Spring 물리
  type: "spring",
  stiffness: 400,
  damping: 30,
  mass: 1,

  // 또는 duration 기반 spring
  type: "spring",
  duration: 0.3,
  bounce: 0.2,

  // 속성별 개별 transition
  opacity: { duration: 0.2 },
  x: { type: "spring", stiffness: 300 },

  // 반복
  repeat: Infinity,
  repeatType: "reverse",  // "loop" | "reverse" | "mirror"
  repeatDelay: 0.5,
}
```

## 다단계 애니메이션 (Keyframes)

```tsx
<motion.div
  animate={{
    x: [0, 100, 0],           // 오른쪽으로 이동 후 복귀
    opacity: [0, 1, 1, 0],    // 페이드 인 → 유지 → 페이드 아웃
    scale: [1, 1.2, 1],       // 커졌다가 축소
  }}
  transition={{
    duration: 2,
    times: [0, 0.5, 1],       // 각 keyframe 발생 시점 (0-1)
    ease: "easeInOut",
  }}
/>
```
