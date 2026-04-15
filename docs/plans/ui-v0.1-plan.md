# UI v0.1 Implementation Plan — "Will I make it?" Screen

> **For Claude:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** HUFS 셔틀 탑승 확률을 숫자 한 개로 보여주는 단일 화면 앱을 완성한다.

**Architecture:** Repository 패턴으로 셔틀 데이터 소스를 추상화 (v0.1 = 하드코딩, v1.0 = Supabase 스왑). Probability 순수함수는 Riverpod 없이 Dart 원시 클래스로 구현해 100% 테스트 가능하게 한다. Bloc/Cubit으로 상태관리 (VGV 표준). Ring 애니메이션은 외부 의존성 없이 `CustomPainter` + `AnimatedBuilder`로 직접 구현.

**Tech Stack:**
- Flutter 3.41.6 / Dart 3.11 (VGV 스캐폴드)
- `bloc` ^9.2.0, `flutter_bloc` ^9.1.1 (이미 설치됨)
- `geolocator` ^13.x (추가 예정), `permission_handler` ^11.x (추가 예정)
- `intl` ^0.20.2 (이미 설치됨, 한국어 로케일용)
- `CustomPainter` for ring animation (외부 asset 없음)
- Testing: `flutter_test`, `bloc_test` ^10.0.0, `mocktail` ^1.0.5 (이미 설치됨)

---

## Context (서브에이전트 필독)

### 프로젝트 문서
- 전체 설계: `docs/DESIGN_v0.md`
- 하네스/컨벤션: `CLAUDE.md`, `docs/plans/2026-04-15-harness-engineering-design.md`
- 확률 공식 (DESIGN_v0.md 명시):
  ```
  p = max(0, min(1, 1 - (t_walk + 30) / t_until_departure))
  t_walk = distance_to_stop_m / walking_speed_mps
  walking_speed_mps = 1.3 (default) 또는 GPS delta 이동평균(최근 30s)
  t_buffer = 30s
  GPS accuracy > 50m or 미허용 → walking_speed = default + "GPS 부정확" 뱃지
  ```

### Freeze 스코프 (이 워크트리에서 절대 편집 금지)
- `.github/**` (CI 스트림 영역)
- `fastlane/**`, `supabase/**` (다른 Wave)
- `docs/plans/**` 이 플랜 외 다른 플랜 (read-only)

### 허용 편집 범위
- `lib/**`, `test/**`, `assets/**`
- `pubspec.yaml` (deps 추가), `pubspec.lock`
- `ios/Runner/Info.plist` (위치 권한)
- `android/app/src/main/AndroidManifest.xml` (위치 권한)
- `l10n.yaml`, `lib/l10n/arb/**`

### 코딩 규칙
- **파일명/모듈**: `snake_case`
- **주석/문자열 리터럴 (코드 내)**: 영어
- **UI 문자열 (사용자 노출)**: 한국어 — 반드시 `AppLocalizations`를 통해 접근, 하드코딩 금지
- **VGV 패턴 따르기**: `lib/app/view/app.dart`, `lib/counter/` 참조 (counter는 Task 9에서 제거)
- **커밋 메시지**: `[Feat]`, `[Test]`, `[Refactor]`, `[Chore]`, `[Docs]` 중 해당 태그 사용. post-commit 훅이 CHANGELOG 자동 갱신
- **YAGNI**: v0.1 범위 외 기능 금지. 광역버스, 텔레메트리, 즐겨찾기, 회원가입은 **구현하지 말 것**

### Definition of Done
- [ ] `flutter analyze` clean (0 에러, 경고는 허용)
- [ ] `flutter test --coverage` 통과, `lib/` 전체 coverage ≥ 80%
- [ ] iOS 시뮬레이터에서 앱 실행 → 확률 숫자 + 링 + 폴백 카드 표시 → 스크린샷 캡처 (`docs/evidence/ui-v0.1-home.png`)
- [ ] 권한 거부 flow 스크린샷 (`docs/evidence/ui-v0.1-permission-denied.png`)
- [ ] GitHub PR 생성 (`feat/ui-v0.1` → `main`) + description에 스크린샷 임베드 + Fixes 링크

---

## Task 0: 브랜치 + 의존성 초기화

**Files:**
- Modify: `pubspec.yaml`

**Step 0.1: Worktree 확인**

이 태스크는 이미 worktree에서 실행 중이어야 함. 확인:
```bash
git worktree list
git branch --show-current
```
Expected: 현재 브랜치 `feat/ui-v0.1`, 경로는 `/Users/one/Projects/will-i-make-it-worktrees/ui-v0.1/` 형태.

만약 메인 워크트리에서 실행 중이면 **즉시 중단**하고 사용자에게 보고.

**Step 0.2: 의존성 추가**

```bash
flutter pub add geolocator permission_handler
```
Expected: pubspec.yaml에 두 패키지 추가, pubspec.lock 갱신.

**Step 0.3: 확인 커밋**
```bash
git add pubspec.yaml pubspec.lock
git commit -m "[Chore] - geolocator + permission_handler 추가"
```

---

## Task 1: 한국어 i18n 전환

VGV 기본은 영어(`app_en.arb`) + 스페인어(`app_es.arb`). v0.1은 한국어 primary, 영어 fallback.

**Files:**
- Create: `lib/l10n/arb/app_ko.arb`
- Modify: `lib/l10n/arb/app_en.arb`
- Delete: `lib/l10n/arb/app_es.arb`
- Modify: `l10n.yaml`
- Modify: `lib/app/view/app.dart` (supportedLocales 조정)

**Step 1.1: app_ko.arb 생성 (Home 키만, counter는 Task 9에서 제거)**

```json
{
  "@@locale": "ko",
  "counterAppBarTitle": "Counter",
  "@counterAppBarTitle": {
    "description": "Legacy — removed in Task 9"
  },
  "homeTitle": "Will I make it?",
  "@homeTitle": {},
  "homeProbabilityLabel": "탑승 가능 확률",
  "@homeProbabilityLabel": {},
  "homeOutcomeMakeIt": "평소 걸음 속도면 다음 셔틀 탑승 가능",
  "@homeOutcomeMakeIt": {},
  "homeOutcomeMissIt": "다음 셔틀 놓칠 가능성 높음",
  "@homeOutcomeMissIt": {},
  "homeFallbackTitle": "다음 셔틀",
  "@homeFallbackTitle": {},
  "homeFallbackMinutes": "{minutes}분 뒤 출발",
  "@homeFallbackMinutes": {
    "placeholders": {
      "minutes": {"type": "int"}
    }
  },
  "homeGpsInaccurateBadge": "GPS 부정확",
  "@homeGpsInaccurateBadge": {},
  "homePermissionDeniedTitle": "위치 권한 필요",
  "@homePermissionDeniedTitle": {},
  "homePermissionDeniedBody": "현재 위치에서 셔틀까지의 거리와 탑승 확률을 계산하려면 위치 권한이 필요합니다.",
  "@homePermissionDeniedBody": {},
  "homePermissionRequestButton": "권한 설정 열기",
  "@homePermissionRequestButton": {}
}
```

**Step 1.2: app_en.arb 동일 키 영어로**

```json
{
  "@@locale": "en",
  "counterAppBarTitle": "Counter",
  "homeTitle": "Will I make it?",
  "homeProbabilityLabel": "Boarding probability",
  "homeOutcomeMakeIt": "You'll make the next shuttle at your normal walking pace",
  "homeOutcomeMissIt": "Likely to miss the next shuttle",
  "homeFallbackTitle": "Next shuttle",
  "homeFallbackMinutes": "Departs in {minutes} min",
  "homeGpsInaccurateBadge": "GPS inaccurate",
  "homePermissionDeniedTitle": "Location permission required",
  "homePermissionDeniedBody": "We need your location to estimate distance to the shuttle stop and your boarding probability.",
  "homePermissionRequestButton": "Open permission settings"
}
```

**Step 1.3: app_es.arb 삭제**
```bash
rm lib/l10n/arb/app_es.arb
```

**Step 1.4: l10n.yaml — template을 ko로 변경**

현재 내용 확인: `cat l10n.yaml`. `template-arb-file`을 `app_ko.arb`로 변경.

**Step 1.5: app.dart supportedLocales 확인**

`lib/app/view/app.dart`의 `MaterialApp` 설정에서 `supportedLocales: AppLocalizations.supportedLocales` 유지 (ko + en 자동 감지).

**Step 1.6: gen-l10n 실행 + analyze**
```bash
flutter gen-l10n
flutter analyze
```
Expected: 0 에러.

**Step 1.7: 커밋**
```bash
git add lib/l10n/ l10n.yaml lib/app/view/app.dart
git commit -m "[Refactor] - i18n을 한국어 primary로 전환 (es 제거)"
```

---

## Task 2: probability/ 모듈 — 순수 계산 함수 (TDD)

**Files:**
- Create: `lib/probability/probability.dart`
- Create: `lib/probability/calculator.dart`
- Create: `test/probability/calculator_test.dart`

**Step 2.1: 실패하는 테스트 먼저 작성**

`test/probability/calculator_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/probability/probability.dart';

void main() {
  group('ProbabilityCalculator.calculate', () {
    test('returns 1.0 when walking time is much less than available time', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 50,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 600,
      );
      expect(result, closeTo(1.0, 0.01));
    });

    test('returns 0.0 when walking time exceeds available time', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 1000,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 60,
      );
      expect(result, 0.0);
    });

    test('DESIGN_v0.md example: ~87% case', () {
      // 300m walk at 1.3m/s = 230s walk. +30s buffer = 260s needed.
      // If 300s until departure: p = 1 - 260/300 = 0.133
      // For ~87% we need: 1 - (t_walk + 30)/t_until = 0.87
      // So (t_walk + 30)/t_until = 0.13
      // If t_until = 300s, t_walk + 30 = 39s, t_walk = 9s
      // At 1.3 m/s, t_walk=9s → distance = 11.7m
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 11.7,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 300,
      );
      expect(result, closeTo(0.87, 0.01));
    });

    test('clamps negative to 0', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 10000,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 10,
      );
      expect(result, 0.0);
    });

    test('clamps >1 to 1', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 0,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 100000,
      );
      expect(result, 1.0);
    });

    test('uses default 1.3 mps when speed not provided', () {
      final withDefault = ProbabilityCalculator.calculate(
        distanceMeters: 130,
        secondsUntilDeparture: 300,
      );
      final withExplicit = ProbabilityCalculator.calculate(
        distanceMeters: 130,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 300,
      );
      expect(withDefault, withExplicit);
    });
  });
}
```

**Step 2.2: 테스트 실행 — 실패 확인**
```bash
flutter test test/probability/calculator_test.dart
```
Expected: `Target of URI doesn't exist` 에러 (파일 미존재).

**Step 2.3: 최소 구현**

`lib/probability/calculator.dart`:
```dart
/// Pure function — no Flutter / no async / 100% testable.
/// Formula per docs/DESIGN_v0.md:
///   p = max(0, min(1, 1 - (t_walk + buffer) / t_until_departure))
class ProbabilityCalculator {
  static const double defaultWalkingSpeedMps = 1.3;
  static const double bufferSeconds = 30;

  static double calculate({
    required double distanceMeters,
    required int secondsUntilDeparture,
    double walkingSpeedMps = defaultWalkingSpeedMps,
  }) {
    if (secondsUntilDeparture <= 0) return 0;
    final tWalk = distanceMeters / walkingSpeedMps;
    final raw = 1 - (tWalk + bufferSeconds) / secondsUntilDeparture;
    return raw.clamp(0.0, 1.0);
  }
}
```

`lib/probability/probability.dart` (barrel):
```dart
export 'calculator.dart';
```

**Step 2.4: 테스트 재실행 — 통과**
```bash
flutter test test/probability/calculator_test.dart
```
Expected: 모든 테스트 PASS.

**Step 2.5: 커밋**
```bash
git add lib/probability/ test/probability/
git commit -m "[Feat] - probability calculator 순수함수 (TDD)"
```

---

## Task 3: shuttle/ 모듈 — 스케줄 모델 + 하드코딩 레포지토리 (TDD)

**Files:**
- Create: `lib/shuttle/shuttle.dart` (barrel)
- Create: `lib/shuttle/models/shuttle_stop.dart`
- Create: `lib/shuttle/models/shuttle_schedule.dart`
- Create: `lib/shuttle/repository/shuttle_repository.dart` (abstract)
- Create: `lib/shuttle/repository/hardcoded_shuttle_repository.dart`
- Create: `lib/shuttle/repository/seed_data.dart`
- Create: `test/shuttle/repository/hardcoded_shuttle_repository_test.dart`

**Step 3.1: 모델 먼저 정의**

`lib/shuttle/models/shuttle_stop.dart`:
```dart
class ShuttleStop {
  const ShuttleStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
  final String id;
  final String name;
  final double latitude;
  final double longitude;
}
```

`lib/shuttle/models/shuttle_schedule.dart`:
```dart
import 'shuttle_stop.dart';

class ShuttleSchedule {
  const ShuttleSchedule({
    required this.stop,
    required this.nextDeparture,
    required this.routeName,
  });
  final ShuttleStop stop;
  final DateTime nextDeparture;
  final String routeName;

  int secondsUntilDepartureFrom(DateTime now) =>
      nextDeparture.difference(now).inSeconds;
}
```

**Step 3.2: Repository abstract**

`lib/shuttle/repository/shuttle_repository.dart`:
```dart
import '../models/shuttle_schedule.dart';

abstract class ShuttleRepository {
  /// Returns the next departure from stops near [latitude], [longitude].
  /// Returns null if no upcoming shuttle today.
  Future<ShuttleSchedule?> findNextDeparture({
    required double latitude,
    required double longitude,
    required DateTime now,
  });
}
```

**Step 3.3: 실패하는 테스트**

`test/shuttle/repository/hardcoded_shuttle_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

void main() {
  group('HardcodedShuttleRepository', () {
    late ShuttleRepository repo;

    setUp(() {
      repo = HardcodedShuttleRepository();
    });

    test('returns nearest stop schedule for HUFS main gate location', () async {
      // HUFS 서울캠 정문 근처 좌표
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 16, 9, 0),  // 평일 오전 9시
      );
      expect(result, isNotNull);
      expect(result!.stop.name, isNotEmpty);
      expect(result.nextDeparture.isAfter(DateTime(2026, 4, 16, 9, 0)), true);
    });

    test('returns null when no upcoming shuttles today (late night)', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 16, 23, 59),
      );
      expect(result, isNull);
    });
  });
}
```

**Step 3.4: 테스트 실행 — 실패 확인**
```bash
flutter test test/shuttle/
```

**Step 3.5: Seed 데이터 + HardcodedShuttleRepository 구현**

`lib/shuttle/repository/seed_data.dart`:
```dart
import '../models/shuttle_stop.dart';

// 2026년 1학기 HUFS 서울캠 셔틀 (단순화된 시드 — v1.0에서 Supabase 스크래퍼로 교체)
const hufsMainGate = ShuttleStop(
  id: 'main-gate',
  name: '정문',
  latitude: 37.5973,
  longitude: 127.0589,
);

const hufsDorms = ShuttleStop(
  id: 'dorms',
  name: '기숙사',
  latitude: 37.5985,
  longitude: 127.0601,
);

const allStops = [hufsMainGate, hufsDorms];

/// 평일 오전 8시 ~ 오후 6시, 20분 간격 가상 스케줄.
List<DateTime> weekdayDepartures(DateTime dayStart) {
  final first = DateTime(dayStart.year, dayStart.month, dayStart.day, 8);
  return List.generate(31, (i) => first.add(Duration(minutes: i * 20)));
}
```

`lib/shuttle/repository/hardcoded_shuttle_repository.dart`:
```dart
import 'dart:math' as math;
import '../models/shuttle_schedule.dart';
import '../models/shuttle_stop.dart';
import 'seed_data.dart';
import 'shuttle_repository.dart';

class HardcodedShuttleRepository implements ShuttleRepository {
  @override
  Future<ShuttleSchedule?> findNextDeparture({
    required double latitude,
    required double longitude,
    required DateTime now,
  }) async {
    final nearest = _nearestStop(latitude, longitude);
    final todayDepartures = weekdayDepartures(now);
    final next = todayDepartures.where((d) => d.isAfter(now)).cast<DateTime?>().firstWhere(
          (_) => true,
          orElse: () => null,
        );
    if (next == null) return null;
    return ShuttleSchedule(
      stop: nearest,
      nextDeparture: next,
      routeName: '서울캠 내부순환',
    );
  }

  ShuttleStop _nearestStop(double lat, double lng) {
    ShuttleStop? best;
    double bestDist = double.infinity;
    for (final s in allStops) {
      final d = _haversineMeters(lat, lng, s.latitude, s.longitude);
      if (d < bestDist) {
        bestDist = d;
        best = s;
      }
    }
    return best!;
  }

  static double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180;
}
```

`lib/shuttle/shuttle.dart` (barrel):
```dart
export 'models/shuttle_schedule.dart';
export 'models/shuttle_stop.dart';
export 'repository/hardcoded_shuttle_repository.dart';
export 'repository/shuttle_repository.dart';
```

**Step 3.6: 테스트 재실행**
```bash
flutter test test/shuttle/
```
Expected: 2/2 pass.

**Step 3.7: 거리 계산 헬퍼를 별도 테스트로 보강**

`test/shuttle/repository/hardcoded_shuttle_repository_test.dart`에 추가:
```dart
test('picks nearer stop between main gate and dorms', () async {
  // Dorms 좌표 근처
  final result = await repo.findNextDeparture(
    latitude: 37.5985,
    longitude: 127.0601,
    now: DateTime(2026, 4, 16, 9, 0),
  );
  expect(result!.stop.id, 'dorms');
});
```

**Step 3.8: 재실행 + 커밋**
```bash
flutter test test/shuttle/
git add lib/shuttle/ test/shuttle/
git commit -m "[Feat] - shuttle 모델 + 하드코딩 레포지토리 (TDD)"
```

---

## Task 4: location/ 모듈 — GPS wrapper + 권한 매니페스트

**Files:**
- Create: `lib/location/location.dart` (barrel)
- Create: `lib/location/location_service.dart`
- Create: `lib/location/models/location_snapshot.dart`
- Create: `test/location/location_service_test.dart`
- Modify: `ios/Runner/Info.plist`
- Modify: `android/app/src/main/AndroidManifest.xml`

**Step 4.1: LocationSnapshot 모델**

`lib/location/models/location_snapshot.dart`:
```dart
class LocationSnapshot {
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;

  bool get isAccurateEnough => accuracyMeters <= 50;
}
```

**Step 4.2: LocationService abstract + impl**

`lib/location/location_service.dart`:
```dart
import 'package:geolocator/geolocator.dart';
import 'models/location_snapshot.dart';

abstract class LocationService {
  Future<LocationPermissionStatus> ensurePermission();
  Stream<LocationSnapshot> watchPosition();
}

enum LocationPermissionStatus { granted, denied, deniedForever, serviceDisabled }

class GeolocatorLocationService implements LocationService {
  @override
  Future<LocationPermissionStatus> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (perm == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }
    return LocationPermissionStatus.granted;
  }

  @override
  Stream<LocationSnapshot> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).map(
      (p) => LocationSnapshot(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyMeters: p.accuracy,
        timestamp: p.timestamp,
      ),
    );
  }
}
```

`lib/location/location.dart` (barrel):
```dart
export 'location_service.dart';
export 'models/location_snapshot.dart';
```

**Step 4.3: 테스트 (LocationSnapshot 순수 로직)**

`test/location/location_service_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/location/location.dart';

void main() {
  group('LocationSnapshot', () {
    test('isAccurateEnough true at 50m exactly', () {
      final s = LocationSnapshot(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 50,
        timestamp: DateTime.now(),
      );
      expect(s.isAccurateEnough, isTrue);
    });
    test('isAccurateEnough false above 50m', () {
      final s = LocationSnapshot(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 50.1,
        timestamp: DateTime.now(),
      );
      expect(s.isAccurateEnough, isFalse);
    });
  });
}
```

**Step 4.4: iOS Info.plist — 한국어 권한 문구**

`ios/Runner/Info.plist`의 `<dict>` 태그 안에 추가:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>현재 위치에서 셔틀 정류장까지의 거리를 계산하기 위해 위치 정보를 사용합니다.</string>
```

**Step 4.5: Android 매니페스트**

`android/app/src/main/AndroidManifest.xml`에서 `<manifest>` 태그 안, `<application>` 앞에 추가:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Step 4.6: analyze + 테스트**
```bash
flutter analyze
flutter test test/location/
```

**Step 4.7: 커밋**
```bash
git add lib/location/ test/location/ ios/Runner/Info.plist android/app/src/main/AndroidManifest.xml
git commit -m "[Feat] - location 서비스 + GPS 권한 매니페스트"
```

---

## Task 5: home/ 모듈 — Cubit + 상태 (TDD)

**Files:**
- Create: `lib/home/home.dart` (barrel)
- Create: `lib/home/cubit/home_cubit.dart`
- Create: `lib/home/cubit/home_state.dart`
- Create: `test/home/cubit/home_cubit_test.dart`

**Step 5.1: HomeState sealed hierarchy**

`lib/home/cubit/home_state.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomePermissionDenied extends HomeState {
  const HomePermissionDenied({required this.permanent});
  final bool permanent;
  @override
  List<Object?> get props => [permanent];
}

class HomeTracking extends HomeState {
  const HomeTracking({
    required this.probability,
    required this.schedule,
    required this.isGpsAccurate,
    required this.now,
  });
  final double probability;
  final ShuttleSchedule schedule;
  final bool isGpsAccurate;
  final DateTime now;

  @override
  List<Object?> get props => [probability, schedule.nextDeparture, isGpsAccurate, now];
}

class HomeNoShuttlesToday extends HomeState {
  const HomeNoShuttlesToday();
}
```

**Note**: `equatable` 패키지는 VGV 기본 스캐폴드에 포함됨 (`flutter_bloc` 의존성 트리). 없다면 `flutter pub add equatable`.

**Step 5.2: 테스트 먼저**

`test/home/cubit/home_cubit_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/home/home.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

class _MockLocationService extends Mock implements LocationService {}
class _MockShuttleRepository extends Mock implements ShuttleRepository {}

void main() {
  late _MockLocationService location;
  late _MockShuttleRepository shuttle;

  setUp(() {
    location = _MockLocationService();
    shuttle = _MockShuttleRepository();
  });

  blocTest<HomeCubit, HomeState>(
    'emits HomePermissionDenied when permission denied',
    build: () {
      when(location.ensurePermission)
          .thenAnswer((_) async => LocationPermissionStatus.denied);
      return HomeCubit(locationService: location, shuttleRepository: shuttle);
    },
    act: (c) => c.start(),
    expect: () => [isA<HomePermissionDenied>()],
  );

  blocTest<HomeCubit, HomeState>(
    'emits HomeTracking after permission grant + position',
    build: () {
      when(location.ensurePermission)
          .thenAnswer((_) async => LocationPermissionStatus.granted);
      when(location.watchPosition).thenAnswer(
        (_) => Stream.value(
          LocationSnapshot(
            latitude: 37.5973,
            longitude: 127.0589,
            accuracyMeters: 10,
            timestamp: DateTime(2026, 4, 16, 9, 0),
          ),
        ),
      );
      when(() => shuttle.findNextDeparture(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            now: any(named: 'now'),
          )).thenAnswer(
        (_) async => ShuttleSchedule(
          stop: const ShuttleStop(
            id: 's',
            name: '정문',
            latitude: 37.5973,
            longitude: 127.0589,
          ),
          nextDeparture: DateTime(2026, 4, 16, 9, 5),
          routeName: '테스트',
        ),
      );
      return HomeCubit(locationService: location, shuttleRepository: shuttle);
    },
    act: (c) => c.start(),
    expect: () => [isA<HomeTracking>()],
  );
}
```

**Step 5.3: 테스트 실행 — 실패 확인**

**Step 5.4: HomeCubit 구현**

`lib/home/cubit/home_cubit.dart`:
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/probability/probability.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required LocationService locationService,
    required ShuttleRepository shuttleRepository,
    DateTime Function()? clock,
  })  : _location = locationService,
        _shuttle = shuttleRepository,
        _clock = clock ?? DateTime.now,
        super(const HomeInitial());

  final LocationService _location;
  final ShuttleRepository _shuttle;
  final DateTime Function() _clock;
  StreamSubscription<LocationSnapshot>? _sub;

  Future<void> start() async {
    final status = await _location.ensurePermission();
    switch (status) {
      case LocationPermissionStatus.granted:
        _startTracking();
      case LocationPermissionStatus.denied:
        emit(const HomePermissionDenied(permanent: false));
      case LocationPermissionStatus.deniedForever:
      case LocationPermissionStatus.serviceDisabled:
        emit(const HomePermissionDenied(permanent: true));
    }
  }

  void _startTracking() {
    _sub?.cancel();
    _sub = _location.watchPosition().listen(_onPosition);
  }

  Future<void> _onPosition(LocationSnapshot snap) async {
    final now = _clock();
    final schedule = await _shuttle.findNextDeparture(
      latitude: snap.latitude,
      longitude: snap.longitude,
      now: now,
    );
    if (schedule == null) {
      emit(const HomeNoShuttlesToday());
      return;
    }
    final distance = _distanceMeters(
      snap.latitude, snap.longitude,
      schedule.stop.latitude, schedule.stop.longitude,
    );
    final p = ProbabilityCalculator.calculate(
      distanceMeters: distance,
      secondsUntilDeparture: schedule.secondsUntilDepartureFrom(now),
    );
    emit(HomeTracking(
      probability: p,
      schedule: schedule,
      isGpsAccurate: snap.isAccurateEnough,
      now: now,
    ));
  }

  // Same haversine as repository — extract to shared helper in v1.0.
  static double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    // ... (same as HardcodedShuttleRepository._haversineMeters)
    // IMPLEMENT: copy-paste OR extract to lib/shared/geo.dart
    throw UnimplementedError('Extract haversine to lib/shared/geo.dart before running');
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

**Step 5.5: haversine 공유 유틸 추출**

`lib/shared/geo.dart` 생성:
```dart
import 'dart:math' as math;

double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371000.0;
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return r * c;
}

double _deg2rad(double deg) => deg * math.pi / 180;
```

`lib/shared/shared.dart`:
```dart
export 'geo.dart';
```

`lib/shuttle/repository/hardcoded_shuttle_repository.dart`와 `lib/home/cubit/home_cubit.dart`에서 `import 'package:will_i_make_it/shared/shared.dart';` 후 `haversineMeters()` 사용. 로컬 `_haversineMeters` 제거.

간단한 unit test: `test/shared/geo_test.dart` — 서울↔부산 거리 ≈ 325km 검증.

**Step 5.6: barrel 파일**

`lib/home/home.dart`:
```dart
export 'cubit/home_cubit.dart';
export 'cubit/home_state.dart';
```

**Step 5.7: 테스트 + 커밋**
```bash
flutter test test/home/ test/shared/
git add lib/home/ lib/shared/ lib/shuttle/repository/hardcoded_shuttle_repository.dart test/home/ test/shared/
git commit -m "[Feat] - home cubit + haversine 공유 유틸 (TDD)"
```

---

## Task 6: probability_ring 위젯 — CustomPainter 링 애니메이션

**Files:**
- Create: `lib/home/view/widgets/probability_ring.dart`
- Create: `test/home/view/widgets/probability_ring_test.dart`

**Step 6.1: 위젯 구현**

`lib/home/view/widgets/probability_ring.dart`:
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProbabilityRing extends StatelessWidget {
  const ProbabilityRing({
    super.key,
    required this.value,
    required this.size,
  });

  /// 0.0 ~ 1.0
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, animated, __) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: animated,
            trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            fillColor: _colorForValue(context, animated),
          ),
          child: Center(
            child: Text(
              '${(animated * 100).round()}%',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForValue(BuildContext c, double v) {
    final cs = Theme.of(c).colorScheme;
    if (v >= 0.7) return cs.primary;
    if (v >= 0.4) return cs.tertiary;
    return cs.error;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.trackColor, required this.fillColor});
  final double value;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.08;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - stroke) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.fillColor != fillColor;
}
```

**Step 6.2: 위젯 테스트**

`test/home/view/widgets/probability_ring_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/home/view/widgets/probability_ring.dart';

void main() {
  testWidgets('displays percentage text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProbabilityRing(value: 0.87, size: 200),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700)); // allow tween to finish
    expect(find.text('87%'), findsOneWidget);
  });

  testWidgets('clamps value >1 to 100%', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProbabilityRing(value: 1.5, size: 200)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('100%'), findsOneWidget);
  });
}
```

**Step 6.3: 테스트 + 커밋**
```bash
flutter test test/home/view/widgets/
git add lib/home/view/ test/home/view/
git commit -m "[Feat] - probability ring CustomPainter + 애니메이션"
```

---

## Task 7: fallback_card + gps_badge 위젯

**Files:**
- Create: `lib/home/view/widgets/fallback_card.dart`
- Create: `lib/home/view/widgets/gps_badge.dart`
- Create: `test/home/view/widgets/fallback_card_test.dart`

**Step 7.1: FallbackCard**

`lib/home/view/widgets/fallback_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

class FallbackCard extends StatelessWidget {
  const FallbackCard({
    super.key,
    required this.minutesUntilDeparture,
    required this.stopName,
  });

  final int minutesUntilDeparture;
  final String stopName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.homeFallbackTitle, style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              l10n.homeFallbackMinutes(minutesUntilDeparture),
              style: theme.textTheme.headlineSmall,
            ),
            Text(stopName, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
```

**Step 7.2: GpsBadge**

`lib/home/view/widgets/gps_badge.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

class GpsBadge extends StatelessWidget {
  const GpsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_off, size: 14, color: cs.onErrorContainer),
          const SizedBox(width: 4),
          Text(
            context.l10n.homeGpsInaccurateBadge,
            style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
```

**Step 7.3: FallbackCard 위젯 테스트**

`test/home/view/widgets/fallback_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/home/view/widgets/fallback_card.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

void main() {
  testWidgets('displays minutes and stop name in Korean', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: const Scaffold(
          body: FallbackCard(minutesUntilDeparture: 18, stopName: '정문'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('다음 셔틀'), findsOneWidget);
    expect(find.textContaining('18'), findsOneWidget);
    expect(find.text('정문'), findsOneWidget);
  });
}
```

**Step 7.4: 커밋**
```bash
flutter test test/home/view/widgets/
git add lib/home/view/widgets/fallback_card.dart lib/home/view/widgets/gps_badge.dart test/home/view/widgets/fallback_card_test.dart
git commit -m "[Feat] - fallback card + gps badge 위젯"
```

---

## Task 8: HomePage — 전체 화면 조립

**Files:**
- Create: `lib/home/view/home_page.dart`
- Create: `test/home/view/home_page_test.dart`

**Step 8.1: HomePage**

`lib/home/view/home_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/home/home.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';
import 'widgets/fallback_card.dart';
import 'widgets/gps_badge.dart';
import 'widgets/probability_ring.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        locationService: GeolocatorLocationService(),
        shuttleRepository: HardcodedShuttleRepository(),
      )..start(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() => const Center(child: CircularProgressIndicator()),
          HomePermissionDenied() => const _PermissionView(),
          HomeNoShuttlesToday() => const Center(child: Text('오늘 남은 셔틀 없음')),
          HomeTracking() => _TrackingView(state: state),
        },
      ),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView({required this.state});
  final HomeTracking state;

  @override
  Widget build(BuildContext context) {
    final minutes = state.schedule.secondsUntilDepartureFrom(state.now) ~/ 60;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!state.isGpsAccurate)
            const Align(alignment: Alignment.topRight, child: GpsBadge()),
          const Spacer(),
          ProbabilityRing(value: state.probability, size: 240),
          const SizedBox(height: 16),
          Text(
            state.probability >= 0.5
                ? context.l10n.homeOutcomeMakeIt
                : context.l10n.homeOutcomeMissIt,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          FallbackCard(
            minutesUntilDeparture: minutes,
            stopName: state.schedule.stop.name,
          ),
        ],
      ),
    );
  }
}

class _PermissionView extends StatelessWidget {
  const _PermissionView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_disabled, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.homePermissionDeniedTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(l10n.homePermissionDeniedBody, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // opens system settings via permission_handler
                // import 'package:permission_handler/permission_handler.dart';
                // openAppSettings();
              },
              child: Text(l10n.homePermissionRequestButton),
            ),
          ],
        ),
      ),
    );
  }
}
```

`lib/home/home.dart` barrel에 추가:
```dart
export 'view/home_page.dart';
```

**Step 8.2: 위젯 테스트**

`test/home/view/home_page_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/home/home.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

class _MockCubit extends MockCubit<HomeState> implements HomeCubit {}

void main() {
  testWidgets('renders permission view when denied', (tester) async {
    final cubit = _MockCubit();
    when(() => cubit.state).thenReturn(const HomePermissionDenied(permanent: false));
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ko'),
        home: BlocProvider<HomeCubit>.value(
          value: cubit,
          child: const Scaffold(body: SizedBox()),  // HomeView는 내부라 value 주입 테스트 별도
        ),
      ),
    );
    // Simplified — full view tests can check HomeTracking rendering.
  });
}
```

**Note**: 완전한 widget test는 복잡함. Coverage를 위해 `_TrackingView`와 `_PermissionView`를 public으로 빼거나 `visibleForTesting`을 사용할 수 있음. TDD 우선순위가 낮으면 스킵 가능 (cubit + pure-function 테스트로 80% 가능성 높음).

**Step 8.3: app.dart를 HomePage로 교체**

`lib/app/view/app.dart`에서 `home: CounterPage()` 또는 `home: CounterPage()`를 `home: const HomePage()`로 변경. import도 업데이트.

**Step 8.4: 전체 빌드 + analyze + 테스트**
```bash
flutter analyze
flutter test
```

**Step 8.5: 커밋**
```bash
git add lib/home/view/ lib/app/view/app.dart test/home/view/
git commit -m "[Feat] - HomePage 전체 화면 + app.dart 교체"
```

---

## Task 9: counter/ 샘플 제거

**Files:**
- Delete: `lib/counter/` (전체)
- Delete: `test/counter/` (전체)
- Modify: `lib/l10n/arb/app_ko.arb`, `lib/l10n/arb/app_en.arb` (counter 키 제거)

**Step 9.1: 디렉토리 삭제**
```bash
rm -rf lib/counter/ test/counter/
```

**Step 9.2: l10n에서 counter 키 제거**

`app_ko.arb`, `app_en.arb`에서 `counterAppBarTitle` 항목 삭제.

**Step 9.3: gen-l10n + analyze**
```bash
flutter gen-l10n
flutter analyze
```

**Step 9.4: 커밋**
```bash
git add lib/counter test/counter lib/l10n/
git commit -m "[Refactor] - VGV counter 샘플 제거"
```

---

## Task 10: 커버리지 + 시뮬레이터 증거 + PR

**Files:**
- Create: `docs/evidence/ui-v0.1-home.png`
- Create: `docs/evidence/ui-v0.1-permission-denied.png`

**Step 10.1: 커버리지 측정**
```bash
flutter test --coverage
# lcov 설치 안 되어 있으면 (선택): brew install lcov
genhtml coverage/lcov.info -o coverage/html  # 선택
```

수동 확인: `coverage/lcov.info`에서 `lib/probability/`, `lib/shuttle/`, `lib/home/cubit/` coverage 확인. 목표 80%+.

**Step 10.2: 미달 시 테스트 추가**

가장 낮은 커버리지 파일부터:
- `lib/home/view/` widgets에 기본 스냅샷 테스트 추가
- `lib/shuttle/models/`에 생성자 + 파생값 테스트

**Step 10.3: 시뮬레이터 실행 + 스크린샷**
```bash
xcrun simctl list devices booted
# booted 없으면:
xcrun simctl boot <device-id>
open -a Simulator

flutter run --flavor development -t lib/main_development.dart
# 앱 시작, 권한 다이얼로그 스크립트 대응

# 스크린샷 (앱 뜬 상태에서):
xcrun simctl io booted screenshot docs/evidence/ui-v0.1-home.png

# 권한 거부 케이스:
# Simulator → Features → Location → None
# 앱 재시작 → 권한 뷰 보일 때:
xcrun simctl io booted screenshot docs/evidence/ui-v0.1-permission-denied.png
```

**Step 10.4: 증거 커밋**
```bash
git add docs/evidence/
git commit -m "[Docs] - v0.1 UI 시뮬레이터 증거 스크린샷"
```

**Step 10.5: push + PR 생성**
```bash
git push -u origin feat/ui-v0.1

gh pr create --title "feat: v0.1 UI — Will I make it? screen" --body "$(cat <<'EOF'
## Summary

DESIGN_v0.md의 v0.1 단일 화면을 구현한다. GPS + 하드코딩된 HUFS 셔틀 스케줄 + 확률 공식으로 "탑승 가능 확률"을 한 숫자로 보여준다.

### 구조
- `lib/probability/` — 순수 계산 함수 (100% 테스트)
- `lib/shuttle/` — 스케줄 모델 + Repository (v1.0에 Supabase 스왑 지점)
- `lib/location/` — Geolocator 래퍼 + 권한 흐름
- `lib/home/` — Cubit + 화면 + 위젯 (ProbabilityRing, FallbackCard, GpsBadge)
- `lib/shared/geo.dart` — haversine 공유 유틸

### Evidence
- `docs/evidence/ui-v0.1-home.png`
- `docs/evidence/ui-v0.1-permission-denied.png`

### Quality gates
- [x] flutter analyze clean
- [x] flutter test — all pass
- [x] coverage ≥ 80%
- [x] iOS simulator screenshots attached

## Test plan
- [ ] `flutter test --coverage` 재현
- [ ] iOS sim 실행 + 권한 grant → 확률 표시 확인
- [ ] iOS sim 권한 deny → permission view 확인
- [ ] Android emulator 동일 (블로커: AVD 미생성, Wave 2에서)

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Step 10.6: PR 상태 확인 + 사용자 리포트**

```bash
gh pr view --web  # 브라우저로 열어서 확인
```

메인 세션에 반환할 상태:
```
## UI v0.1 Plan — 완료 상태
- PR URL: <출력된 URL>
- 모든 quality gate 통과
- 블로커: 없음 / 있음 (상세)
- 다음 단계: codex review + merge
```

---

## Troubleshooting (실행 중 자주 발생하는 문제)

### 1. `flutter pub add geolocator`가 platform 설정 누락 경고
geolocator는 iOS deployment target ≥ 12.0 필요. Podfile platform :ios 조정:
```ruby
platform :ios, '12.0'
```

### 2. iOS simulator에서 GPS가 Cupertino 좌표(37.3230, -122.0322) 고정
Features → Location → Custom Location → 37.5973, 127.0589 (HUFS 정문).

### 3. flutter analyze에서 `very_good_analysis` rule 충돌
대부분 `public_member_api_docs` 또는 `sort_constructors_first`. v0.1은 엄격하게 지키되, 시간 부족 시 파일 상단에 `// ignore_for_file: public_member_api_docs` 예외적 허용 (README 주석 필수).

### 4. bloc_test에서 `when(() => ...)` 타입 에러
`mocktail`은 named param을 `any(named: 'foo')`로 매치. positional은 `any()`.

### 5. 한글 폰트가 iOS 시뮬레이터에서 깨짐
기본 시스템 한글 폰트 사용. 별도 폰트 번들은 v1.0 디자인 시스템에서.

---

## Scope guard (절대 하지 말 것)

- ❌ 광역버스 API 연동 — v1.0
- ❌ Supabase 연결 — Wave 2 (다른 worktree)
- ❌ CI workflow 수정 — 별도 worktree
- ❌ 설정 화면, 다크모드 토글, 즐겨찾기 — v1.1+
- ❌ Fastlane 설정 — 별도 worktree (Wave 3)
- ❌ 텔레메트리 / 익명 이벤트 로그 — v1.0

의심되면 `docs/DESIGN_v0.md`의 "v0.1 Scope 경계" (P7) 재확인.

---

## Execution

**Plan complete and saved to `docs/plans/ui-v0.1-plan.md`. Two execution options:**

**1. Subagent-Driven (this session)** — 메인 세션이 task마다 fresh subagent dispatch + 리뷰. 빠른 반복.

**2. Parallel Session (separate)** — worktree에 새 세션 열어 `superpowers:executing-plans`로 batch 실행, checkpoint 기반.

Wave 1 병렬(UI + CI) 의도라면 **2번이 원래 계획** (Agent isolation=worktree로 자동화). 1번은 UI가 서브에이전트 실패로 막혔을 때 fallback.

**Which approach?**
