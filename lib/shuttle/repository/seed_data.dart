import 'package:will_i_make_it/shuttle/models/shuttle_stop.dart';

// HUFS 글로벌캠(용인) 교내 셔틀.
// 2026학년도 1학기 운행 (2026.4.1 ~ 6.22, 평일만).
// v1.0에서 Supabase 스크래퍼로 대체 예정.

const ShuttleStop jiseokmyoStop = ShuttleStop(
  id: 'jiseokmyo',
  name: '지석묘 앞',
  latitude: 37.335815,
  longitude: 127.254057,
);

const ShuttleStop inmunGyeongsangStop = ShuttleStop(
  id: 'inmun-gyeongsang',
  name: '인문경상관 앞',
  latitude: 37.339286,
  longitude: 127.273324,
);

const List<ShuttleStop> allStops = [jiseokmyoStop, inmunGyeongsangStop];

const String routeUpbound = '지석묘 → 인문경상관 (상행)';
const String routeDownbound = '인문경상관 → 지석묘 (하행)';

/// 상행 (지석묘 앞 → 인문경상관) 출발시각. 15:15 미운영.
const List<(int, int)> _upboundTimes = [
  (8, 20),
  (8, 30),
  (8, 40),
  (8, 50),
  (9, 0),
  (9, 15),
  (9, 30),
  (9, 40),
  (9, 50),
  (10, 0),
  (10, 15),
  (10, 30),
  (10, 40),
  (10, 50),
  (11, 0),
  (11, 15),
  (11, 30),
  (11, 35),
  (11, 40),
  (11, 50),
  (12, 10),
  (12, 50),
  (13, 0),
  (13, 15),
  (13, 30),
  (13, 40),
  (13, 50),
  (14, 0),
  (14, 15),
  (14, 30),
  (14, 40),
  (14, 50),
  (15, 0),
  (15, 30),
  (15, 40),
  (15, 50),
  (16, 0),
  (16, 20),
  (16, 40),
  (17, 0),
  (17, 20),
  (17, 40),
  (18, 0),
  (18, 30),
  (19, 0),
  (19, 30),
  (20, 0),
  (20, 30),
];

/// 하행 (인문경상관 → 지석묘 앞) 출발시각. 15:25 미운영.
const List<(int, int)> _downboundTimes = [
  (8, 30),
  (8, 40),
  (8, 50),
  (9, 0),
  (9, 10),
  (9, 25),
  (9, 40),
  (9, 50),
  (10, 0),
  (10, 10),
  (10, 25),
  (10, 40),
  (10, 50),
  (11, 0),
  (11, 10),
  (11, 25),
  (11, 40),
  (11, 45),
  (11, 50),
  (12, 0),
  (12, 20),
  (13, 0),
  (13, 10),
  (13, 25),
  (13, 40),
  (13, 50),
  (14, 0),
  (14, 10),
  (14, 25),
  (14, 40),
  (14, 50),
  (15, 0),
  (15, 10),
  (15, 40),
  (15, 50),
  (16, 0),
  (16, 10),
  (16, 30),
  (16, 50),
  (17, 10),
  (17, 30),
  (17, 50),
  (18, 10),
  (18, 40),
  (19, 10),
  (19, 40),
  (20, 10),
  (20, 40),
];

/// Returns all weekday departures for [stopId] on the same calendar day
/// as [dayReference]. Order preserved (chronological).
List<DateTime> departuresForStop(String stopId, DateTime dayReference) {
  final times = switch (stopId) {
    'jiseokmyo' => _upboundTimes,
    'inmun-gyeongsang' => _downboundTimes,
    _ => const <(int, int)>[],
  };
  return times
      .map(
        (t) => DateTime(
          dayReference.year,
          dayReference.month,
          dayReference.day,
          t.$1,
          t.$2,
        ),
      )
      .toList();
}

/// Route name for departures originating at [stopId].
String routeNameForStop(String stopId) => switch (stopId) {
  'jiseokmyo' => routeUpbound,
  'inmun-gyeongsang' => routeDownbound,
  _ => '',
};
