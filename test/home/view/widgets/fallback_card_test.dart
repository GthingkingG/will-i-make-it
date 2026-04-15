import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/home/view/widgets/fallback_card.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('ko')}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: child),
  );
}

void main() {
  group('FallbackCard', () {
    testWidgets('displays title, minutes and stop name in Korean',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FallbackCard(minutesUntilDeparture: 18, stopName: '정문'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('다음 셔틀'), findsOneWidget);
      expect(find.textContaining('18'), findsOneWidget);
      expect(find.text('정문'), findsOneWidget);
    });

    testWidgets('renders with 0 minutes without crashing', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FallbackCard(minutesUntilDeparture: 0, stopName: '기숙사'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('기숙사'), findsOneWidget);
    });

    testWidgets('English locale renders English copy', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const FallbackCard(minutesUntilDeparture: 5, stopName: 'Main Gate'),
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Next shuttle'), findsOneWidget);
    });
  });
}
