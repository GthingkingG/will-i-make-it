import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

void main() {
  group('HardcodedShuttleRepository', () {
    late ShuttleRepository repo;

    setUp(() {
      repo = const HardcodedShuttleRepository();
    });

    test('returns schedule for HUFS main gate at 9AM weekday', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 16, 9),
      );
      expect(result, isNotNull);
      expect(result!.stop.name, '정문');
      expect(result.nextDeparture.isAfter(DateTime(2026, 4, 16, 9)), isTrue);
      expect(result.routeName, isNotEmpty);
    });

    test('returns null on Saturday (no weekend service)', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 18, 9),
      );
      expect(result, isNull);
    });

    test('returns null on Sunday (no weekend service)', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 19, 9),
      );
      expect(result, isNull);
    });

    test('picks nearer stop (dorms) when closer to dorms', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5985,
        longitude: 127.0601,
        now: DateTime(2026, 4, 16, 9),
      );
      expect(result!.stop.id, 'dorms');
    });

    test('returns null late at night when no more shuttles today', () async {
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: DateTime(2026, 4, 16, 23, 59),
      );
      expect(result, isNull);
    });

    test('next departure is strictly after now', () async {
      final now = DateTime(2026, 4, 16, 8, 19, 59);
      final result = await repo.findNextDeparture(
        latitude: 37.5973,
        longitude: 127.0589,
        now: now,
      );
      expect(result!.nextDeparture.isAfter(now), isTrue);
    });
  });

  group('ShuttleSchedule.secondsUntilDepartureFrom', () {
    test('returns positive when departure is in the future', () {
      final now = DateTime(2026, 4, 16, 9);
      final schedule = ShuttleSchedule(
        stop: hufsMainGate,
        nextDeparture: now.add(const Duration(minutes: 5)),
        routeName: 'test',
      );
      expect(schedule.secondsUntilDepartureFrom(now), 300);
    });

    test('returns negative when departure has passed', () {
      final now = DateTime(2026, 4, 16, 9);
      final schedule = ShuttleSchedule(
        stop: hufsMainGate,
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
