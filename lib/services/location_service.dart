import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

class LocationService {
  Future<String> getCurrentCity() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location Disabled";
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permission Denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Permission Denied";
      }

      // Get current position with a timeout to prevent hanging
      Position position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 5),
            ),
          ).catchError((e) async {
            // Fallback to last known position if current position fails or times out
            return await Geolocator.getLastKnownPosition() ??
                Position(
                  longitude: 72.8777,
                  latitude: 19.0760,
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  heading: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0,
                );
          });

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? "Mumbai";
      }

      return "Mumbai";
    } catch (e) {
      return "Mumbai"; // Default fallback
    }
  }

  Future<void> requestAllPermissions() async {
    // 1. Request notification permission
    await Permission.notification.request();

    // 2. Handle Location Permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // If permanently denied, we must open app settings
      await openAppSettings();
      return;
    }

    // 3. Handle Location Service (GPS Switch) - Seamlessly
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      loc.Location location = loc.Location();
      bool serviceEnabled = await location.serviceEnabled();

      if (!serviceEnabled) {
        // This triggers the SYSTEM POPUP with the "OK" button to turn on GPS
        serviceEnabled = await location.requestService();
      }

      // Fallback: if user still refuses to turn on GPS via popup, open settings as a last resort
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
      }
    }
  }
}
