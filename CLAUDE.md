# will-i-make-it — Claude Code 프로젝트 컨텍스트

## 프로젝트 개요

HUFS 학생용 셔틀 의사결정 앱. 시간표가 아니라 "지금 셔틀 잡을 수 있나"를 확률 한 숫자로 답한다. 48시간 MVP 포트폴리오 프로젝트 (메타-목표: AI 에이전트팀 주도 풀스택 배포 경험).

설계 문서: [`docs/DESIGN_v0.md`](./docs/DESIGN_v0.md)
하네스 설계: [`docs/plans/2026-04-15-harness-engineering-design.md`](./docs/plans/2026-04-15-harness-engineering-design.md)

## 기술 스택

- **Mobile**: Flutter 3.41.6 (Dart 3.11) — Very Good Ventures 스캐폴드
- **State**: bloc / cubit (VGV 표준)
- **Backend**: Supabase (Postgres + pg_cron + Edge Functions) — v0.1 후반
- **API proxy**: Vercel Edge Functions (경기도 버스정보시스템 API 키 보호) — v1.0
- **CI/CD**: GitHub Actions + Fastlane match
- **Analytics**: Sentry (v1.0+)

## 코드 컨벤션

### Flutter / Dart
- Linter: `very_good_analysis` (`analysis_options.yaml` 상속). 경고 0 유지
- Format: `dart format` — 커밋 전 자동 차단 (pre-commit 훅)
- Flavors: `main_development.dart` / `main_staging.dart` / `main_production.dart`
- 파일명: `snake_case.dart`
- 클래스/위젯: `PascalCase`
- 변수/함수: `camelCase`
- i18n: `lib/l10n/arb/app_ko.arb` + `app_en.arb`. 한국어가 primary

### 폴더 구조
```
lib/
├── app/           # App root + theme + router
├── bootstrap.dart # Entry point (모든 flavor 공통)
├── counter/       # ← v0.1에서 제거 예정 (샘플)
├── home/          # ← v0.1에서 신규: "Will I make it?" 화면
├── shuttle/       # ← v0.1: 셔틀 스케줄 모델 + repository
├── probability/   # ← v0.1: 확률 계산 순수함수 + 테스트
├── location/      # ← v0.1: GPS wrapper
└── l10n/          # 생성된 i18n
```

### 커밋 메시지
글로벌 CLAUDE.md 컨벤션 준수:
```
[태그] - 제목 (무엇을 왜)

본문 (선택)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
태그: `[Feat]` `[Fix]` `[Refactor]` `[Style]` `[Docs]` `[Test]` `[Chore]` `[CI]`
`post-commit` 훅이 태그 감지 시 `CHANGELOG.md` 자동 기록.

## 하네스 / 에이전트 워크플로우

**현재 단계**: v0.1 개발 — Wave 1 (UI + CI 병렬)

**실행 패턴**: Plan-first → Subagent Execute
- `docs/plans/{stream}-v0.1-plan.md`가 서브에이전트 지시서
- 각 스트림은 전용 worktree (`~/Projects/will-i-make-it-worktrees/{stream}/`)에서 실행
- 완료 시 PR 생성 → codex 리뷰 → 사용자 머지

**Freeze 스코프**: 워크트리별로 `gstack:freeze` 적용. UI는 `lib/`, `test/`, `pubspec.yaml`, `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`만 허용. CI는 `.github/workflows/`만. 자세한 건 하네스 설계 문서 참조.

## 현재 진행 중인 작업

### v0.1 마일스톤
- [x] Flutter 툴체인 (CocoaPods, cmdline-tools, JBR)
- [x] VGV 스캐폴드 + iOS sim 빌드 검증
- [x] 하네스 엔지니어링 설계 문서
- [ ] `.claude/hooks/` + 프로젝트 CLAUDE.md (Phase 0)
- [ ] UI + CI 플랜 작성 (Phase 1)
- [ ] Wave 1 병렬 실행 (Phase 2)
- [ ] PR 리뷰 게이트 + 머지 (Phase 3)

### 외부 블로커
- Apple Developer 신원 확인 대기 (1-3일) → iOS ship 지연
- Google Play Console 미가입 → Android ship 지연
- Supabase 프로젝트 미생성 → Backend 스트림 대기 중

## 주의사항

- **Fastlane `match` 레포**는 `will-i-make-it-certs` (sibling 레포). `MATCH_PASSWORD`로 암호화. 직접 열지 말 것
- **VGV flavors**: `flutter run --flavor development -t lib/main_development.dart` — flavor + target 항상 명시
- **pubspec.yaml 우선권**: UI 워크트리가 dependency 수정 우선. CI 워크트리는 UI PR 머지 후 rebase해서 dev_dependencies 추가
- **iOS 위치 권한**: `ios/Runner/Info.plist`에 `NSLocationWhenInUseUsageDescription` 필수 (한국어 문구)
- **Android 위치 권한**: `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` 매니페스트 선언

## 최근 변경 이력

자동 갱신됨 (post-commit 훅). `CHANGELOG.md` 상단 참조.
