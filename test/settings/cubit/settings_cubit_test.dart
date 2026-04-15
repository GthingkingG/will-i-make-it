import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/settings/settings.dart';

class _MockLocationService extends Mock implements LocationService {}

void main() {
  late _MockLocationService location;

  setUp(() {
    location = _MockLocationService();
  });

  SettingsCubit build() => SettingsCubit(locationService: location);

  group('SettingsCubit.refresh', () {
    blocTest<SettingsCubit, SettingsState>(
      'emits SettingsLoaded(granted) when permission is granted',
      build: () {
        when(location.checkPermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        return build();
      },
      act: (c) => c.refresh(),
      expect: () => [
        const SettingsLoaded(
          locationStatus: LocationPermissionStatus.granted,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits SettingsLoaded(denied) when permission denied',
      build: () {
        when(location.checkPermission).thenAnswer(
          (_) async => LocationPermissionStatus.denied,
        );
        return build();
      },
      act: (c) => c.refresh(),
      expect: () => [
        const SettingsLoaded(
          locationStatus: LocationPermissionStatus.denied,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits serviceDisabled when OS service is off',
      build: () {
        when(location.checkPermission).thenAnswer(
          (_) async => LocationPermissionStatus.serviceDisabled,
        );
        return build();
      },
      act: (c) => c.refresh(),
      expect: () => [
        const SettingsLoaded(
          locationStatus: LocationPermissionStatus.serviceDisabled,
        ),
      ],
    );
  });

  group('SettingsCubit.requestPermission', () {
    blocTest<SettingsCubit, SettingsState>(
      'calls ensurePermission then re-emits refreshed status',
      build: () {
        when(location.ensurePermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        when(location.checkPermission).thenAnswer(
          (_) async => LocationPermissionStatus.granted,
        );
        return build();
      },
      act: (c) => c.requestPermission(),
      expect: () => [
        const SettingsLoaded(
          locationStatus: LocationPermissionStatus.granted,
        ),
      ],
      verify: (_) {
        verify(location.ensurePermission).called(1);
        verify(location.checkPermission).called(1);
      },
    );
  });

  group('SettingsCubit.openSystemSettings', () {
    test('delegates to LocationService', () async {
      when(location.openSystemSettings).thenAnswer((_) async => true);
      final cubit = build();
      final result = await cubit.openSystemSettings();
      expect(result, isTrue);
      verify(location.openSystemSettings).called(1);
    });
  });
}
