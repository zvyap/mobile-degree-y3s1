import 'package:geolocator/geolocator.dart';

class RiderPosition {
  const RiderPosition({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

/// Indirection over the device location plugin so the renting controller and
/// tests can run without platform channels.
abstract interface class RiderLocationSource {
  Future<RiderPosition> getCurrentPosition();
}

class GeolocatorRiderLocationSource implements RiderLocationSource {
  const GeolocatorRiderLocationSource();

  @override
  Future<RiderPosition> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedException();
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );
    return RiderPosition(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
