---
name: senior-frontend
description: React, Next.js, TypeScript, Tailwind CSS를 사용하는 현대적이고 성능 좋은 웹 애플리케이션 개발을 위한 시니어 프론트엔드 스킬. 컴포넌트 스캐폴딩, 성능 최적화, 번들 분석, UI 모범 사례를 포함한다. 프론트엔드 기능 개발, 성능 최적화, UI/UX 구현, 상태 관리, 코드 리뷰 시 사용한다.
---

# Senior Frontend

현대적인 도구와 모범 사례를 갖춘 시니어 프론트엔드 완전 도구 모음.

## 빠른 시작

### 주요 기능

이 스킬은 자동화 스크립트를 통해 세 가지 핵심 기능을 제공한다:

```bash
# 스크립트 1: 컴포넌트 생성기
python scripts/component_generator.py [options]

# 스크립트 2: 번들 분석기
python scripts/bundle_analyzer.py [options]

# 스크립트 3: 프론트엔드 스캐폴더
python scripts/frontend_scaffolder.py [options]
```

## 핵심 기능

### 1. 컴포넌트 생성기

컴포넌트 생성 작업을 위한 자동화 도구.

**특징:**
- 자동 스캐폴딩
- 모범 사례 내장
- 설정 가능한 템플릿
- 품질 검사

**사용법:**
```bash
python scripts/component_generator.py <project-path> [options]
```

### 2. 번들 분석기

종합적인 분석 및 최적화 도구.

**특징:**
- 심층 분석
- 성능 지표
- 개선 권장사항
- 자동 수정

**사용법:**
```bash
python scripts/bundle_analyzer.py <target-path> [--verbose]
```

### 3. 프론트엔드 스캐폴더

특수 작업을 위한 고급 도구.

**특징:**
- 전문가 수준 자동화
- 커스텀 설정
- 통합 준비 완료
- 프로덕션 수준 출력

**사용법:**
```bash
python scripts/frontend_scaffolder.py [arguments] [options]
```

## 참조 문서

### React 패턴

`references/react_patterns.md`의 종합 가이드:

- 상세 패턴 및 사례
- 코드 예제
- 모범 사례
- 피해야 할 안티패턴
- 실제 사용 시나리오

### Next.js 최적화 가이드

`references/nextjs_optimization_guide.md`의 전체 워크플로우 문서:

- 단계별 프로세스
- 최적화 전략
- 도구 통합
- 성능 튜닝
- 트러블슈팅 가이드

### 프론트엔드 모범 사례

`references/frontend_best_practices.md`의 기술 참조 가이드:

- 기술 스택 상세
- 설정 예제
- 통합 패턴
- 보안 고려사항
- 확장성 가이드라인

## 기술 스택

**언어:** TypeScript, JavaScript, Python, Go, Swift, Kotlin
**프론트엔드:** React, Next.js, React Native, Flutter
**백엔드:** Node.js, Express, GraphQL, REST APIs
**데이터베이스:** PostgreSQL, Prisma, NeonDB, Supabase
**DevOps:** Docker, Kubernetes, Terraform, GitHub Actions, CircleCI
**클라우드:** AWS, GCP, Azure

## 개발 워크플로우

### 1. 설정 및 구성

```bash
# 의존성 설치
npm install
# 또는
pip install -r requirements.txt

# 환경 설정
cp .env.example .env
```

### 2. 품질 검사 실행

```bash
# 분석기 스크립트 사용
python scripts/bundle_analyzer.py .

# 권장사항 확인
# 수정 적용
```

### 3. 모범 사례 적용

아래 문서의 패턴과 사례를 따른다:
- `references/react_patterns.md`
- `references/nextjs_optimization_guide.md`
- `references/frontend_best_practices.md`

## 모범 사례 요약

### 코드 품질
- 확립된 패턴 따르기
- 포괄적인 테스트 작성
- 결정 사항 문서화
- 정기적인 리뷰

### 성능
- 최적화 전에 측정
- 적절한 캐싱 사용
- 핵심 경로 최적화
- 프로덕션 모니터링

### 보안
- 모든 입력값 검증
- 파라미터화된 쿼리 사용
- 올바른 인증 구현
- 의존성 최신 유지

### 유지보수성
- 명확한 코드 작성
- 일관된 네이밍 사용
- 유용한 주석 추가
- 단순하게 유지

## 주요 명령어

```bash
# 개발
npm run dev
npm run build
npm run test
npm run lint

# 분석
python scripts/bundle_analyzer.py .
python scripts/frontend_scaffolder.py --analyze

# 배포
docker build -t app:latest .
docker-compose up -d
kubectl apply -f k8s/
```

## 트러블슈팅

### 자주 발생하는 문제

`references/frontend_best_practices.md`의 종합 트러블슈팅 섹션을 참고한다.

### 도움말

- 참조 문서 확인
- 스크립트 출력 메시지 확인
- 기술 스택 문서 참고
- 에러 로그 확인

## 리소스

- 패턴 참조: `references/react_patterns.md`
- 워크플로우 가이드: `references/nextjs_optimization_guide.md`
- 기술 가이드: `references/frontend_best_practices.md`
- 도구 스크립트: `scripts/` 디렉터리
