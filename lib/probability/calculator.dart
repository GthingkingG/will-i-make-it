/// Pure function — no Flutter / no async / 100% testable.
///
/// Formula per docs/DESIGN_v0.md:
///   p = max(0, min(1, 1 - (t_walk + buffer) / t_until_departure))
///   t_walk = distance_meters / walking_speed_mps
class ProbabilityCalculator {
  /// Default walking speed in meters per second (leisurely adult pace).
  static const double defaultWalkingSpeedMps = 1.3;

  /// Safety buffer in seconds before the shuttle actually leaves
  /// (stop proximity, boarding time, clock skew).
  static const double bufferSeconds = 30;

  /// Returns boarding probability in `[0.0, 1.0]`.
  ///
  /// - [distanceMeters] — great-circle distance from user to stop.
  /// - [secondsUntilDeparture] — integer seconds from now to next departure.
  ///   If `<= 0`, returns `0`.
  /// - [walkingSpeedMps] — defaults to [defaultWalkingSpeedMps]; pass a
  ///   measured value (GPS delta moving-average) when available.
  static double calculate({
    required double distanceMeters,
    required int secondsUntilDeparture,
    double walkingSpeedMps = defaultWalkingSpeedMps,
  }) {
    if (secondsUntilDeparture <= 0) return 0;
    if (walkingSpeedMps <= 0) return 0;
    final tWalk = distanceMeters / walkingSpeedMps;
    final raw = 1 - (tWalk + bufferSeconds) / secondsUntilDeparture;
    return raw.clamp(0.0, 1.0);
  }
}
