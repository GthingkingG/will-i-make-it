import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/settings/settings.dart';

class _MockLocationService extends Mock implements LocationService {}

Widget _harness(SettingsCubit cubit) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    home: SettingsPage(cubit: cubit),
  );
}

void main() {
  late _MockLocationService location;

  setUp(() {
    location = _MockLocationService();
  });

  testWidgets('renders "허용됨" and no action button when granted', (
    tester,
  ) async {
    when(location.checkPermission).thenAnswer(
      (_) async => LocationPermissionStatus.granted,
    );
    final cubit = SettingsCubit(locationService: location);
    await cubit.refresh();

    await tester.pumpWidget(_harness(cubit));
    await tester.pump();

    expect(find.text('허용됨'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-request-permission')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('settings-open-os')), findsNothing);
  });

  testWidgets('renders "거부됨" and "권한 요청" button when denied', (tester) async {
    when(location.checkPermission).thenAnswer(
      (_) async => LocationPermissionStatus.denied,
    );
    final cubit = SettingsCubit(locationService: location);
    await cubit.refresh();

    await tester.pumpWidget(_harness(cubit));
    await tester.pump();

    expect(find.text('거부됨'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('settings-request-permission')),
      findsOneWidget,
    );
    expect(find.text('권한 요청'), findsOneWidget);
  });

  testWidgets(
    'renders "영구 거부됨" and "OS 설정 열기" when permanently denied',
    (tester) async {
      when(location.checkPermission).thenAnswer(
        (_) async => LocationPermissionStatus.deniedForever,
      );
      final cubit = SettingsCubit(locationService: location);
      await cubit.refresh();

      await tester.pumpWidget(_harness(cubit));
      await tester.pump();

      expect(find.text('영구 거부됨'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings-open-os')), findsOneWidget);
      expect(find.text('OS 설정 열기'), findsOneWidget);
    },
  );

  testWidgets(
    'renders "위치 서비스 꺼짐" and "OS 설정 열기" when service disabled',
    (tester) async {
      when(location.checkPermission).thenAnswer(
        (_) async => LocationPermissionStatus.serviceDisabled,
      );
      final cubit = SettingsCubit(locationService: location);
      await cubit.refresh();

      await tester.pumpWidget(_harness(cubit));
      await tester.pump();

      expect(find.text('위치 서비스 꺼짐'), findsOneWidget);
      expect(find.byKey(const ValueKey('settings-open-os')), findsOneWidget);
    },
  );

  testWidgets('requestPermission wired to the "권한 요청" button', (
    tester,
  ) async {
    // 첫 refresh는 denied(버튼 노출), request 후 refresh는 granted.
    var checkCalls = 0;
    when(location.checkPermission).thenAnswer((_) async {
      checkCalls++;
      return checkCalls == 1
          ? LocationPermissionStatus.denied
          : LocationPermissionStatus.granted;
    });
    when(location.ensurePermission).thenAnswer(
      (_) async => LocationPermissionStatus.granted,
    );
    final cubit = SettingsCubit(locationService: location);
    await cubit.refresh();

    await tester.pumpWidget(_harness(cubit));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-request-permission')));
    await tester.pumpAndSettle();

    verify(location.ensurePermission).called(1);
    expect(find.text('허용됨'), findsOneWidget);
  });
}
