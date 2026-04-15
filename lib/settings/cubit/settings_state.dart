import 'package:equatable/equatable.dart';
import 'package:will_i_make_it/location/location.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded({required this.locationStatus});

  final LocationPermissionStatus locationStatus;

  @override
  List<Object?> get props => [locationStatus];
}
