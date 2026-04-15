import 'package:will_i_make_it/shared/shared.dart';
import 'package:will_i_make_it/shuttle/models/shuttle_schedule.dart';
import 'package:will_i_make_it/shuttle/models/shuttle_stop.dart';
import 'package:will_i_make_it/shuttle/repository/seed_data.dart';
import 'package:will_i_make_it/shuttle/repository/shuttle_repository.dart';

class HardcodedShuttleRepository implements ShuttleRepository {
  const HardcodedShuttleRepository();

  @override
  Future<ShuttleSchedule?> findNextDeparture({
    required double latitude,
    required double longitude,
    required DateTime now,
  }) async {
    final nearest = _nearestStop(latitude, longitude);
    final departures = weekdayDepartures(now);
    DateTime? next;
    for (final d in departures) {
      if (d.isAfter(now)) {
        next = d;
        break;
      }
    }
    if (next == null) return null;
    return ShuttleSchedule(
      stop: nearest,
      nextDeparture: next,
      routeName: '서울캠 내부순환',
    );
  }

  ShuttleStop _nearestStop(double lat, double lng) {
    var bestDistance = double.infinity;
    var best = allStops.first;
    for (final s in allStops) {
      final d = haversineMeters(lat, lng, s.latitude, s.longitude);
      if (d < bestDistance) {
        bestDistance = d;
        best = s;
      }
    }
    return best;
  }
}
