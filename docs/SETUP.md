# Setup Log

설치/계정 세팅 진행 상황 추적용. 체크리스트 완료 시점 기록.

## Day 0 Status

### Accounts
- [x] Apple Developer Program 결제 완료 — **신원 확인 대기 중** (1-3일)
- [ ] Google Play Console 가입 ($25)
- [x] GitHub 리포 생성 (`will-i-make-it`, `will-i-make-it-certs`)

### Local toolchain
- [ ] Flutter SDK 설치 (`brew install --cask flutter`)
- [ ] `flutter doctor` 모든 체크 통과
- [ ] Xcode 설치 + `xcode-select --install` + CocoaPods
- [ ] Android Studio + Android SDK
- [ ] `dart pub global activate very_good_cli`

### Flutter project
- [ ] `very_good create flutter_app` 스캐폴딩 완료
- [ ] 로컬 실기기에서 빈 앱 실행 확인 (iOS)
- [ ] 로컬 실기기에서 빈 앱 실행 확인 (Android)

### CI/CD (GitHub Actions)
- [ ] `ci.yml` — lint + test on push
- [ ] `deploy.yml` — build on `v*` tag → TestFlight + Play Internal
- [ ] 초록 뱃지 첫 커밋

### Fastlane
- [ ] `fastlane init` in `ios/` and `android/`
- [ ] `fastlane match init` → `will-i-make-it-certs` 리포 연결
- [ ] `MATCH_PASSWORD` + App Store Connect API Key 생성
- [ ] GH Actions 시크릿 전체 등록 (7개, DESIGN_v0.md 참조)

### Backend
- [ ] Supabase 프로젝트 생성
- [ ] `shuttle_schedules` 테이블 생성
- [ ] Edge Function: HUFS 홈페이지 스크래퍼
- [ ] pg_cron: 매일 06:00 KST 스크래퍼 실행 설정
- [ ] 시드 데이터 삽입 (2026 1학기 HUFS 셔틀)

### v0.1 UI
- [ ] "Will I make it?" 단일 화면
- [ ] GPS 권한 요청 + 위치 획득
- [ ] 확률 계산 (`p = max(0, min(1, 1 - (t_walk + 30) / t_until_departure))`)
- [ ] 확률 링 애니메이션 (Rive or Lottie)
- [ ] 폴백 카드 ("다음 셔틀 N분 뒤")

### v0.1 Ship
- [ ] Android: Play Internal Track 업로드 → 링크 확보
- [ ] iOS: TestFlight 업로드 → External Review (1-3일)
- [ ] 30초 스크린 녹화 비디오
- [ ] README에 TestFlight + Play Internal 링크 추가
- [ ] LinkedIn 포스팅
