import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/home/cubit/home_state.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/probability/probability.dart';
import 'package:will_i_make_it/shared/shared.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required LocationService locationService,
    required ShuttleRepository shuttleRepository,
    DateTime Function()? clock,
  })  : _location = locationService,
        _shuttle = shuttleRepository,
        _clock = clock ?? DateTime.now,
        super(const HomeInitial());

  final LocationService _location;
  final ShuttleRepository _shuttle;
  final DateTime Function() _clock;
  StreamSubscription<LocationSnapshot>? _positionSub;

  /// Kicks off the permission flow and then the position stream.
  /// Safe to call multiple times; the earlier subscription is cancelled.
  Future<void> start() async {
    final status = await _location.ensurePermission();
    switch (status) {
      case LocationPermissionStatus.granted:
        await _startTracking();
      case LocationPermissionStatus.denied:
        emit(const HomePermissionDenied(permanent: false));
      case LocationPermissionStatus.deniedForever:
      case LocationPermissionStatus.serviceDisabled:
        emit(const HomePermissionDenied(permanent: true));
    }
  }

  /// Opens OS-level permission settings. Returns `true` if the settings page
  /// was opened. After returning the caller typically re-invokes [start].
  Future<bool> openSystemSettings() => _location.openSystemSettings();

  Future<void> _startTracking() async {
    await _positionSub?.cancel();
    _positionSub = _location.watchPosition().listen(_onPosition);
  }

  Future<void> _onPosition(LocationSnapshot snap) async {
    final now = _clock();
    final schedule = await _shuttle.findNextDeparture(
      latitude: snap.latitude,
      longitude: snap.longitude,
      now: now,
    );
    if (isClosed) return;
    if (schedule == null) {
      emit(const HomeNoShuttlesToday());
      return;
    }
    final distance = haversineMeters(
      snap.latitude,
      snap.longitude,
      schedule.stop.latitude,
      schedule.stop.longitude,
    );
    final probability = ProbabilityCalculator.calculate(
      distanceMeters: distance,
      secondsUntilDeparture: schedule.secondsUntilDepartureFrom(now),
    );
    emit(
      HomeTracking(
        probability: probability,
        schedule: schedule,
        isGpsAccurate: snap.isAccurateEnough,
        now: now,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _positionSub?.cancel();
    return super.close();
  }
}
