import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/settings/cubit/settings_state.dart';

/// Observes app-level settings state (currently just location permission).
/// [refresh] is cheap and idempotent — safe to call on every app lifecycle
/// resume so the status re-syncs after the user changes it in OS settings.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required LocationService locationService})
    : _location = locationService,
      super(const SettingsLoading());

  final LocationService _location;

  // Callers await this to sequence UI updates.
  // ignore: prefer_void_public_cubit_methods
  Future<void> refresh() async {
    final status = await _location.checkPermission();
    if (isClosed) return;
    emit(SettingsLoaded(locationStatus: status));
  }

  /// Triggers the OS permission prompt if status allows it
  /// (denied but not permanent). Refreshes status afterwards.
  // Callers await this to sequence UI updates.
  // ignore: prefer_void_public_cubit_methods
  Future<void> requestPermission() async {
    await _location.ensurePermission();
    await refresh();
  }

  /// Opens OS-level app settings. Caller should call [refresh] on app resume.
  // Callers await this to sequence UI updates.
  // ignore: prefer_void_public_cubit_methods
  Future<bool> openSystemSettings() => _location.openSystemSettings();
}
