import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bharatnova/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final cityProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(locationServiceProvider);
  
  // Listen to service status changes and invalidate this provider when it changes
  final statusStream = Geolocator.getServiceStatusStream();
  final subscription = statusStream.listen((status) {
    ref.invalidateSelf();
  });
  
  ref.onDispose(() => subscription.cancel());

  return service.getCurrentCity();
});
