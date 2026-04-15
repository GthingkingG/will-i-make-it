import 'package:equatable/equatable.dart';

/// Threshold above which GPS accuracy is considered unreliable and the UI
/// should surface a "GPS inaccurate" badge (per DESIGN_v0.md).
const double gpsAccuracyThresholdMeters = 50;

class LocationSnapshot extends Equatable {
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

  bool get isAccurateEnough => accuracyMeters <= gpsAccuracyThresholdMeters;

  @override
  List<Object?> get props => [latitude, longitude, accuracyMeters, timestamp];
}
