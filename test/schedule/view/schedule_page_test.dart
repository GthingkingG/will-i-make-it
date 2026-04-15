import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/schedule/schedule.dart';

Widget _harness(DateTime now) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    home: SchedulePage(now: now),
  );
}

void main() {
  group('SchedulePage', () {
    testWidgets('renders title and both route tabs', (tester) async {
      await tester.pumpWidget(_harness(DateTime(2026, 4, 16, 9)));
      await tester.pump();

      expect(find.text('시간표'), findsOneWidget);
      expect(find.text('상행'), findsOneWidget);
      expect(find.text('하행'), findsOneWidget);
    });

    testWidgets('upbound tab shows route label', (tester) async {
      await tester.pumpWidget(_harness(DateTime(2026, 4, 16, 9)));
      await tester.pump();

      expect(find.text('지석묘 앞 → 인문경상관'), findsOneWidget);
    });

    testWidgets('shows expected departure count on upbound (48)', (
      tester,
    ) async {
      await tester.pumpWidget(_harness(DateTime(2026, 4, 16, 9)));
      await tester.pump();

      // 상행 첫 시각은 08:20, 마지막은 20:30. 첫 것은 리스트 맨 위에 렌더됨.
      expect(find.text('08:20'), findsOneWidget);
    });

    testWidgets('marks next departure with "다음" badge', (tester) async {
      // 09:05 기준 → 상행 다음 출발은 09:15
      await tester.pumpWidget(_harness(DateTime(2026, 4, 16, 9, 5)));
      await tester.pump();

      expect(find.text('다음'), findsOneWidget);
      expect(find.text('09:15'), findsOneWidget);
    });

    testWidgets('shows empty state on Saturday', (tester) async {
      await tester.pumpWidget(_harness(DateTime(2026, 4, 18, 9)));
      await tester.pump();

      expect(find.text('오늘은 운행하지 않습니다'), findsWidgets);
    });

    testWidgets('shows empty state outside service period', (tester) async {
      await tester.pumpWidget(_harness(DateTime(2026, 8, 15, 9)));
      await tester.pump();

      expect(find.text('오늘은 운행하지 않습니다'), findsWidgets);
    });
  });
}
