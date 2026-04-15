import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/shared/shared.dart';

void main() {
  group('haversineMeters', () {
    test('returns 0 for identical points', () {
      expect(haversineMeters(37.5973, 127.0589, 37.5973, 127.0589), 0);
    });

    test('Seoul to Busan ≈ 325 km', () {
      // Seoul City Hall → Busan City Hall
      final meters = haversineMeters(37.5665, 126.9780, 35.1796, 129.0756);
      expect(meters, closeTo(325000, 10000));
    });

    test('small distance within 100m for close HUFS stops', () {
      // HUFS main gate ↔ dorms (seed data)
      final meters = haversineMeters(37.5973, 127.0589, 37.5985, 127.0601);
      expect(meters, greaterThan(100));
      expect(meters, lessThan(250));
    });

    test('symmetric', () {
      final a = haversineMeters(37.5, 127, 35.2, 129);
      final b = haversineMeters(35.2, 129, 37.5, 127);
      expect(a, closeTo(b, 0.001));
    });
  });
}
