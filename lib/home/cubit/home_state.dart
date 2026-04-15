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

  /// `true` when the user has permanently denied location access
  /// (iOS "Don't ask again", Android "deniedForever") or location services
  /// are disabled at the OS level. UI should offer an "open settings" path.
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

  /// Boarding probability in `[0.0, 1.0]`.
  final double probability;
  final ShuttleSchedule schedule;
  final bool isGpsAccurate;
  final DateTime now;

  @override
  List<Object?> get props => [probability, schedule, isGpsAccurate, now];
}

class HomeNoShuttlesToday extends HomeState {
  const HomeNoShuttlesToday();
}
