import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'app_exception.dart';

class LocationService {
  static Future<Position> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const AppException('locationOff');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      throw const AppException('locationDenied');
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  static Future<String> reverse(double lat, double lng) async {
    try {
      final list = await placemarkFromCoordinates(lat, lng);
      if (list.isEmpty) return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      final p = list.first;
      final parts = <String?>[
        p.street,
        p.subLocality,
        p.locality,
        p.subAdministrativeArea,
        p.postalCode,
      ].where((e) => e != null && e.trim().isNotEmpty).cast<String>().toList();
      final unique = <String>[];
      for (final s in parts) {
        if (!unique.contains(s)) unique.add(s);
      }
      return unique.isEmpty ? '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}' : unique.join(', ');
    } catch (_) {
      return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    }
  }
}
