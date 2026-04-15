import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/home/home.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

class _MockLocationService extends Mock implements LocationService {}

class _MockShuttleRepository extends Mock implements ShuttleRepository {}

const _testStop = ShuttleStop(
  id: 'test',
  name: '정문',
  latitude: 37.5973,
  longitude: 127.0589,
);

ShuttleSchedule _scheduleAt(
  DateTime now, {
  Duration offset = const Duration(minutes: 5),
}) {
  return ShuttleSchedule(
    stop: _testStop,
    nextDeparture: now.add(offset),
    routeName: '테스트 노선',
  );
}

void main() {
  late _MockLocationService location;
  late _MockShuttleRepository shuttle;
  final fixedNow = DateTime(2026, 4, 16, 9);

  setUp(() {
    location = _MockLocationService();
    shuttle = _MockShuttleRepository();
  });

  HomeCubit buildCubit() => HomeCubit(
        locationService: location,
        shuttleRepository: shuttle,
        clock: () => fixedNow,
      );

  group('HomeCubit.start', () {
    blocTest<HomeCubit, HomeState>(
      'emits HomePermissionDenied(permanent: false) when denied',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.denied,
        );
        return buildCubit();
      },
      act: (c) => c.start(),
      expect: () => [const HomePermissionDenied(permanent: false)],
    );

    blocTest<HomeCubit, HomeState>(
      'emits HomePermissionDenied(permanent: true) when deniedForever',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.deniedForever,
        );
        return buildCubit();
      },
      act: (c) => c.start(),
      expect: () => [const HomePermissionDenied(permanent: true)],
    );

    blocTest<HomeCubit, HomeState>(
      'emits HomePermissionDenied(permanent: true) when service disabled',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.serviceDisabled,
        );
        return buildCubit();
      },
      act: (c) => c.start(),
      expect: () => [const HomePermissionDenied(permanent: true)],
    );

    blocTest<HomeCubit, HomeState>(
      'emits HomeTracking on first position after permission grant',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(location.watchPosition).thenAnswer(
          (_) => Stream.value(
            LocationSnapshot(
              latitude: 37.5973,
              longitude: 127.0589,
              accuracyMeters: 10,
              timestamp: fixedNow,
            ),
          ),
        );
        when(
          () => shuttle.findNextDeparture(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) async => _scheduleAt(fixedNow));
        return buildCubit();
      },
      act: (c) => c.start(),
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        final state = cubit.state;
        expect(state, isA<HomeTracking>());
        final tracking = state as HomeTracking;
        expect(tracking.probability, greaterThan(0.5));
        expect(tracking.isGpsAccurate, isTrue);
        expect(tracking.schedule.stop.name, '정문');
      },
    );

    blocTest<HomeCubit, HomeState>(
      'emits HomeNoShuttlesToday when repository returns null',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(location.watchPosition).thenAnswer(
          (_) => Stream.value(
            LocationSnapshot(
              latitude: 37.5973,
              longitude: 127.0589,
              accuracyMeters: 10,
              timestamp: fixedNow,
            ),
          ),
        );
        when(
          () => shuttle.findNextDeparture(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) async => null);
        return buildCubit();
      },
      act: (c) => c.start(),
      wait: const Duration(milliseconds: 50),
      expect: () => [const HomeNoShuttlesToday()],
    );

    blocTest<HomeCubit, HomeState>(
      'marks GPS inaccurate when accuracy > 50m',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(location.watchPosition).thenAnswer(
          (_) => Stream.value(
            LocationSnapshot(
              latitude: 37.5973,
              longitude: 127.0589,
              accuracyMeters: 100,
              timestamp: fixedNow,
            ),
          ),
        );
        when(
          () => shuttle.findNextDeparture(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            now: any(named: 'now'),
          ),
        ).thenAnswer((_) async => _scheduleAt(fixedNow));
        return buildCubit();
      },
      act: (c) => c.start(),
      wait: const Duration(milliseconds: 50),
      verify: (cubit) {
        final state = cubit.state as HomeTracking;
        expect(state.isGpsAccurate, isFalse);
      },
    );
  });

  group('HomeCubit.openSystemSettings', () {
    test('delegates to LocationService', () async {
      when(location.openSystemSettings).thenAnswer((_) async => true);
      final cubit = buildCubit();
      final opened = await cubit.openSystemSettings();
      expect(opened, isTrue);
      verify(location.openSystemSettings).called(1);
      await cubit.close();
    });
  });

  group('HomeState', () {
    test('HomeInitial equality', () {
      expect(const HomeInitial(), const HomeInitial());
    });
    test('HomePermissionDenied equality by permanent flag', () {
      expect(
        const HomePermissionDenied(permanent: false),
        const HomePermissionDenied(permanent: false),
      );
      expect(
        const HomePermissionDenied(permanent: false),
        isNot(const HomePermissionDenied(permanent: true)),
      );
    });
    test('HomeNoShuttlesToday equality', () {
      expect(const HomeNoShuttlesToday(), const HomeNoShuttlesToday());
    });
  });
}
