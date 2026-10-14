import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum DeviceLocationFailure { denied, deniedForever, disabled, unavailable }

abstract interface class DeviceLocationService {
  Future<LatLng> currentPosition();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  const GeolocatorDeviceLocationService();

  @override
  Future<LatLng> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw DeviceLocationFailure.disabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw DeviceLocationFailure.deniedForever;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw DeviceLocationFailure.denied;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }
}
