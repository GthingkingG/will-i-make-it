// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/probability/probability.dart';

void main() {
  group('ProbabilityCalculator.calculate', () {
    test('returns high probability when walking time << available time', () {
      // distance=50m, speed=1.3 → t_walk≈38.5s; +30s buffer = 68.5s
      // p = 1 - 68.5/600 ≈ 0.886
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 50,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 600,
      );
      expect(result, closeTo(0.886, 0.005));
      expect(result, greaterThan(0.85));
    });

    test('returns 0.0 when walking time exceeds available time', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 1000,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 60,
      );
      expect(result, 0.0);
    });

    test('matches DESIGN_v0.md ~87% example', () {
      // t_walk=9s at 1.3m/s → 11.7m, t_until=300s
      // p = 1 - (9 + 30) / 300 = 0.87
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 11.7,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 300,
      );
      expect(result, closeTo(0.87, 0.01));
    });

    test('clamps negative result to 0', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 10000,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 10,
      );
      expect(result, 0.0);
    });

    test('approaches 1 as secondsUntilDeparture grows with tiny distance', () {
      final result = ProbabilityCalculator.calculate(
        distanceMeters: 0,
        walkingSpeedMps: 1.3,
        secondsUntilDeparture: 100000,
      );
      // With distance=0 and 30s buffer, raw = 1 - 30/100000 ≈ 0.9997
      expect(result, closeTo(1.0, 0.001));
      expect(result, lessThanOrEqualTo(1.0));
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

    test('returns 0 when secondsUntilDeparture <= 0', () {
      expect(
        ProbabilityCalculator.calculate(
          distanceMeters: 100,
          secondsUntilDeparture: 0,
        ),
        0.0,
      );
      expect(
        ProbabilityCalculator.calculate(
          distanceMeters: 100,
          secondsUntilDeparture: -5,
        ),
        0.0,
      );
    });

    test('returns 0 when walking speed is 0 (guard against div-by-zero)', () {
      expect(
        ProbabilityCalculator.calculate(
          distanceMeters: 100,
          walkingSpeedMps: 0,
          secondsUntilDeparture: 300,
        ),
        0.0,
      );
    });

    test('exposes sensible default constants', () {
      expect(ProbabilityCalculator.defaultWalkingSpeedMps, 1.3);
      expect(ProbabilityCalculator.bufferSeconds, 30);
    });
  });
}
