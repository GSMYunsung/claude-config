# Claude Code용 Animate 스킬

Next.js/React 애플리케이션을 위한 애니메이션 패턴 및 모범 사례. Emil Kowalski의 "Animations on the Web" 코스 기반.

## 설치

```bash
npx skills add https://github.com/delphi-ai/animate-skill --skill animate
```

## 포함 내용

- **SKILL.md** - 이징, 타이밍, 자주 쓰는 패턴 빠른 참고
- **examples/** - 완성된 예시 8개 (호버 효과, 토스트, 모달 등)
- **references/** - CSS 애니메이션, Framer Motion, 성능, 접근성 상세 문서

## 사용법

설치 후, 애니메이션·트랜지션·호버 효과·모달·React 컴포넌트 모션 구현을 요청하면 스킬이 자동으로 활성화된다.

`/animate` 로 직접 호출할 수도 있다.

## 포함된 예시

| 예시 | 설명 |
|---------|-------------|
| `card-hover.tsx` | 호버 시 설명 슬라이드업 |
| `toast-stacking.tsx` | 토스트 알림 애니메이션 |
| `text-reveal.tsx` | 글자 스태거 등장 |
| `shared-layout.tsx` | Framer Motion layoutId 모프 |
| `animate-height.tsx` | 높이 부드럽게 변경 |
| `multi-step-flow.tsx` | 방향성 있는 단계 마법사 |
| `feedback-popover.tsx` | 버튼→팝오버 확장 |
| `app-store-card.tsx` | iOS 스타일 카드 확장 |

## 의존성

Framer Motion 예시를 사용하려면:
```bash
pnpm add framer-motion react-use-measure usehooks-ts
```
