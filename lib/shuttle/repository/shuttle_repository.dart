import 'package:will_i_make_it/shuttle/models/shuttle_schedule.dart';

/// Abstract contract for shuttle schedule lookups.
///
/// v0.1 implementation is hard-coded. v1.0 will swap in a Supabase-backed
/// concrete without touching call sites.
// ignore: one_member_abstracts
abstract class ShuttleRepository {
  /// Returns the next departure from the stop nearest to
  /// ([latitude], [longitude]) after [now]. Returns `null` if no upcoming
  /// shuttle remains today.
  Future<ShuttleSchedule?> findNextDeparture({
    required double latitude,
    required double longitude,
    required DateTime now,
  });
}
