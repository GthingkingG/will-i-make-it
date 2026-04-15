import 'package:equatable/equatable.dart';
import 'package:will_i_make_it/shuttle/models/shuttle_stop.dart';

class ShuttleSchedule extends Equatable {
  const ShuttleSchedule({
    required this.stop,
    required this.nextDeparture,
    required this.routeName,
  });

  final ShuttleStop stop;
  final DateTime nextDeparture;
  final String routeName;

  /// Whole seconds from [now] until [nextDeparture]. Negative if already past.
  int secondsUntilDepartureFrom(DateTime now) =>
      nextDeparture.difference(now).inSeconds;

  @override
  List<Object?> get props => [stop, nextDeparture, routeName];
}
