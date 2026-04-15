import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:will_i_make_it/home/view/widgets/gps_badge.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

void main() {
  testWidgets('GpsBadge renders Korean label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('ko'),
        home: Scaffold(
          body: Align(
            child: GpsBadge(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('GPS 부정확'), findsOneWidget);
    expect(find.byIcon(Icons.gps_off), findsOneWidget);
  });
}
