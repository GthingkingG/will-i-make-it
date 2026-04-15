import 'package:will_i_make_it/shuttle/models/shuttle_stop.dart';

// Simplified 2026 spring-semester HUFS Seoul campus shuttle stops.
// v1.0 will replace this with a Supabase-backed scraper.

const ShuttleStop hufsMainGate = ShuttleStop(
  id: 'main-gate',
  name: '정문',
  latitude: 37.5973,
  longitude: 127.0589,
);

const ShuttleStop hufsDorms = ShuttleStop(
  id: 'dorms',
  name: '기숙사',
  latitude: 37.5985,
  longitude: 127.0601,
);

const List<ShuttleStop> allStops = [hufsMainGate, hufsDorms];

/// Weekday departures: 8:00 AM to roughly 6:00 PM, every 20 minutes.
List<DateTime> weekdayDepartures(DateTime dayReference) {
  final first = DateTime(
    dayReference.year,
    dayReference.month,
    dayReference.day,
    8,
  );
  return List.generate(31, (i) => first.add(Duration(minutes: i * 20)));
}
