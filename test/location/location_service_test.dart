import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/location/location.dart';

void main() {
  group('LocationSnapshot', () {
    test('isAccurateEnough true at exactly 50m', () {
      final snap = LocationSnapshot(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 50,
        timestamp: DateTime.now(),
      );
      expect(snap.isAccurateEnough, isTrue);
    });

    test('isAccurateEnough true below 50m', () {
      final snap = LocationSnapshot(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 12.3,
        timestamp: DateTime.now(),
      );
      expect(snap.isAccurateEnough, isTrue);
    });

    test('isAccurateEnough false above 50m', () {
      final snap = LocationSnapshot(
        latitude: 0,
        longitude: 0,
        accuracyMeters: 50.1,
        timestamp: DateTime.now(),
      );
      expect(snap.isAccurateEnough, isFalse);
    });

    test('equatable: equal when all fields match', () {
      final ts = DateTime(2026, 4, 16, 9);
      final a = LocationSnapshot(
        latitude: 37.5,
        longitude: 127,
        accuracyMeters: 10,
        timestamp: ts,
      );
      final b = LocationSnapshot(
        latitude: 37.5,
        longitude: 127,
        accuracyMeters: 10,
        timestamp: ts,
      );
      expect(a, b);
    });
  });

  group('LocationPermissionStatus', () {
    test('enum values', () {
      expect(LocationPermissionStatus.values, hasLength(4));
    });
  });
}
