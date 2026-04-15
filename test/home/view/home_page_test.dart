import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/home/home.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

class _MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ko'),
    home: child,
  );
}

void main() {
  late HomeCubit cubit;

  setUp(() {
    cubit = _MockHomeCubit();
  });

  testWidgets('renders loading indicator in HomeInitial', (tester) async {
    when(() => cubit.state).thenReturn(const HomeInitial());
    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders permission view when denied', (tester) async {
    when(() => cubit.state).thenReturn(
      const HomePermissionDenied(permanent: false),
    );
    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    expect(find.text('위치 권한 필요'), findsOneWidget);
    expect(find.byIcon(Icons.location_disabled), findsOneWidget);
    expect(find.text('권한 설정 열기'), findsOneWidget);
  });

  testWidgets('permission button calls start when not permanent', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const HomePermissionDenied(permanent: false),
    );
    when(cubit.start).thenAnswer((_) async {});

    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(cubit.start).called(1);
  });

  testWidgets('permission button opens settings when permanent', (
    tester,
  ) async {
    when(() => cubit.state).thenReturn(
      const HomePermissionDenied(permanent: true),
    );
    when(cubit.openSystemSettings).thenAnswer((_) async => true);

    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(cubit.openSystemSettings).called(1);
  });

  testWidgets('renders tracking view with probability + fallback', (
    tester,
  ) async {
    final now = DateTime(2026, 4, 16, 9);
    when(() => cubit.state).thenReturn(
      HomeTracking(
        probability: 0.87,
        schedule: ShuttleSchedule(
          stop: const ShuttleStop(
            id: 's',
            name: '정문',
            latitude: 37.5973,
            longitude: 127.0589,
          ),
          nextDeparture: now.add(const Duration(minutes: 6)),
          routeName: '서울캠 내부순환',
        ),
        isGpsAccurate: true,
        now: now,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('87%'), findsOneWidget);
    expect(find.text('탑승 가능 확률'), findsOneWidget);
    expect(find.text('평소 걸음 속도면 다음 셔틀 탑승 가능'), findsOneWidget);
    expect(find.text('다음 셔틀'), findsOneWidget);
    expect(find.text('정문'), findsOneWidget);
  });

  testWidgets('renders miss-it copy when probability < 0.5', (tester) async {
    final now = DateTime(2026, 4, 16, 9);
    when(() => cubit.state).thenReturn(
      HomeTracking(
        probability: 0.2,
        schedule: ShuttleSchedule(
          stop: const ShuttleStop(
            id: 's',
            name: '정문',
            latitude: 37.5973,
            longitude: 127.0589,
          ),
          nextDeparture: now.add(const Duration(minutes: 1)),
          routeName: '서울캠 내부순환',
        ),
        isGpsAccurate: true,
        now: now,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('다음 셔틀 놓칠 가능성 높음'), findsOneWidget);
  });

  testWidgets('renders GPS badge when isGpsAccurate is false', (tester) async {
    final now = DateTime(2026, 4, 16, 9);
    when(() => cubit.state).thenReturn(
      HomeTracking(
        probability: 0.7,
        schedule: ShuttleSchedule(
          stop: const ShuttleStop(
            id: 's',
            name: '정문',
            latitude: 37.5973,
            longitude: 127.0589,
          ),
          nextDeparture: now.add(const Duration(minutes: 10)),
          routeName: '서울캠 내부순환',
        ),
        isGpsAccurate: false,
        now: now,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('GPS 부정확'), findsOneWidget);
  });

  testWidgets('renders "no shuttles today" state', (tester) async {
    when(() => cubit.state).thenReturn(const HomeNoShuttlesToday());
    await tester.pumpWidget(
      _wrap(
        BlocProvider<HomeCubit>.value(value: cubit, child: const HomeView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('오늘 남은 셔틀 없음'), findsOneWidget);
  });
}
