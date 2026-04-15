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
  Future<LocationPermissionStatus> ensurePermission();
  Stream<LocationSnapshot> watchPosition();

  /// Opens the OS-level app permission settings. Used by the "권한 설정 열기"
  /// button when permission has been permanently denied.
  Future<bool> openSystemSettings();
}

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationPermissionStatus> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationPermissionStatus.serviceDisabled;
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      return LocationPermissionStatus.deniedForever;
    }
    if (perm == LocationPermission.denied) {
      return LocationPermissionStatus.denied;
    }
    return LocationPermissionStatus.granted;
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
