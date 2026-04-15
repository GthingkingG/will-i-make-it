import 'package:geolocator/geolocator.dart';
import 'package:will_i_make_it/location/models/location_snapshot.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Thin abstraction over the platform GPS service so call sites (HomeCubit)
/// can be unit-tested without a real device.
abstract class LocationService {
  /// Read-only status check. Does NOT prompt the user.
  /// Used by Settings page and other places that want to observe current
  /// state without triggering side effects.
  Future<LocationPermissionStatus> checkPermission();

  /// Checks status and, if [LocationPermission.denied], prompts the user.
  /// Used by the home flow on first launch.
  Future<LocationPermissionStatus> ensurePermission();

  Stream<LocationSnapshot> watchPosition();

  /// Opens the OS-level app permission settings. Used by the "권한 설정 열기"
  /// button when permission has been permanently denied.
  Future<bool> openSystemSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    return _classify(await Geolocator.checkPermission());
  }

  @override
  Future<LocationPermissionStatus> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return _classify(perm);
  }

  LocationPermissionStatus _classify(LocationPermission perm) {
    return switch (perm) {
      LocationPermission.deniedForever =>
        LocationPermissionStatus.deniedForever,
      LocationPermission.denied => LocationPermissionStatus.denied,
      _ => LocationPermissionStatus.granted,
    };
  }

  @override
  Stream<LocationSnapshot> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(distanceFilter: 5),
    ).map(
      (p) => LocationSnapshot(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracyMeters: p.accuracy,
        timestamp: p.timestamp,
      ),
    );
  }

  @override
  Future<bool> openSystemSettings() => Geolocator.openAppSettings();
}
