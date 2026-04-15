import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

void main() {
  group('HardcodedShuttleRepository', () {
    late ShuttleRepository repo;

    // HUFS Global 캠 실제 정류장 좌표
    const jiseokmyoLat = 37.335815;
    const jiseokmyoLng = 127.254057;
    const inmunLat = 37.339286;
    const inmunLng = 127.273324;

    setUp(() {
      repo = const HardcodedShuttleRepository();
    });

    test('returns 상행 schedule near 지석묘 at 9AM weekday', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 16, 9),
      );
      expect(result, isNotNull);
      expect(result!.stop.id, 'jiseokmyo');
      expect(result.routeName, contains('상행'));
      // 09:00 excluded by strict `isAfter`, so next is 09:15.
      expect(result.nextDeparture, DateTime(2026, 4, 16, 9, 15));
    });

    test('returns 하행 schedule near 인문경상관 at 9AM weekday', () async {
      final result = await repo.findNextDeparture(
        latitude: inmunLat,
        longitude: inmunLng,
        now: DateTime(2026, 4, 16, 9),
      );
      expect(result, isNotNull);
      expect(result!.stop.id, 'inmun-gyeongsang');
      expect(result.routeName, contains('하행'));
      // 하행 9시 첫차는 09:00 passed → 09:10
      expect(result.nextDeparture, DateTime(2026, 4, 16, 9, 10));
    });

    test('상행 11:35 신설편 is included', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 16, 11, 31),
      );
      expect(result!.nextDeparture, DateTime(2026, 4, 16, 11, 35));
    });

    test('상행 15:15 미운영 is skipped', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 16, 15),
      );
      // 15:00 passed by `isAfter` strict check, 15:15 skipped, so 15:30
      expect(result!.nextDeparture, DateTime(2026, 4, 16, 15, 30));
    });

    test('하행 15:25 미운영 is skipped', () async {
      final result = await repo.findNextDeparture(
        latitude: inmunLat,
        longitude: inmunLng,
        now: DateTime(2026, 4, 16, 15, 11),
      );
      // 15:10 passed, 15:25 skipped, 15:40 is next
      expect(result!.nextDeparture, DateTime(2026, 4, 16, 15, 40));
    });

    test('returns null before service period (2026-03-31)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 3, 31, 9),
      );
      expect(result, isNull);
    });

    test('returns schedule on first service day (2026-04-01 Wed)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 1, 9),
      );
      expect(result, isNotNull);
    });

    test('returns schedule on last service day (2026-06-22 Mon)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 6, 22, 9),
      );
      expect(result, isNotNull);
    });

    test('returns null after service period (2026-06-23)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 6, 23, 9),
      );
      expect(result, isNull);
    });

    test('returns null during summer break (2026-08-15)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 8, 15, 9),
      );
      expect(result, isNull);
    });

    test('returns null on Saturday (no weekend service)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 18, 9),
      );
      expect(result, isNull);
    });

    test('returns null on Sunday (no weekend service)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 19, 9),
      );
      expect(result, isNull);
    });

    test('returns null after 막차 (상행 20:30)', () async {
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: DateTime(2026, 4, 16, 20, 31),
      );
      expect(result, isNull);
    });

    test('returns null after 막차 (하행 20:40)', () async {
      final result = await repo.findNextDeparture(
        latitude: inmunLat,
        longitude: inmunLng,
        now: DateTime(2026, 4, 16, 20, 41),
      );
      expect(result, isNull);
    });

    test('next departure is strictly after now', () async {
      final now = DateTime(2026, 4, 16, 8, 19, 59);
      final result = await repo.findNextDeparture(
        latitude: jiseokmyoLat,
        longitude: jiseokmyoLng,
        now: now,
      );
      expect(result!.nextDeparture.isAfter(now), isTrue);
      expect(result.nextDeparture, DateTime(2026, 4, 16, 8, 20));
    });
  });

  group('ShuttleSchedule.secondsUntilDepartureFrom', () {
    test('returns positive when departure is in the future', () {
      final now = DateTime(2026, 4, 16, 9);
      final schedule = ShuttleSchedule(
        stop: jiseokmyoStop,
        nextDeparture: now.add(const Duration(minutes: 5)),
        routeName: 'test',
      );
      expect(schedule.secondsUntilDepartureFrom(now), 300);
    });

    test('returns negative when departure has passed', () {
      final now = DateTime(2026, 4, 16, 9);
      final schedule = ShuttleSchedule(
        stop: jiseokmyoStop,
        nextDeparture: now.subtract(const Duration(seconds: 30)),
        routeName: 'test',
      );
      expect(schedule.secondsUntilDepartureFrom(now), -30);
    });
  });

  group('ShuttleStop equality', () {
    test('equal when fields match', () {
      const a = ShuttleStop(id: 'x', name: 'n', latitude: 1, longitude: 2);
      const b = ShuttleStop(id: 'x', name: 'n', latitude: 1, longitude: 2);
      expect(a, b);
    });
  });
}
