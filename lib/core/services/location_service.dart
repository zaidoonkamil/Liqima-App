import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../network/local/cache_helper.dart';
import '../network/remote/dio_helper.dart';
import '../widgets/constant.dart';

class LocationService {
  const LocationService._();

  static final ValueNotifier<String> locationLabel = ValueNotifier<String>(
    _cachedLocationLabel(),
  );

  static bool _isStarting = false;

  static void loadCachedLocation() {
    locationLabel.value = _cachedLocationLabel();
  }

  static Future<void> startLocationUpdates() async {
    if (_isStarting || token.isEmpty) return;
    _isStarting = true;

    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) return;

      final currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await _saveAndSyncPosition(currentPosition);
    } catch (_) {
      // Location should not block login/navigation.
    } finally {
      _isStarting = false;
    }
  }

  static Future<void> stopLocationUpdates() async {
    _isStarting = false;
  }

  static Future<bool> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<void> _saveAndSyncPosition(Position position) async {
    final label = await _resolveLocationLabel(position);

    await CacheHelper.saveData(key: 'latitude', value: position.latitude.toString());
    await CacheHelper.saveData(key: 'longitude', value: position.longitude.toString());
    await CacheHelper.saveData(key: 'location', value: label);
    locationLabel.value = label;

    if (token.isEmpty) return;
    try {
      await DioHelper.patchData(
        url: '/users/me/location',
        token: token,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location': label,
        },
      );
    } catch (_) {
      // Keep local location even if network sync fails.
    }
  }

  static Future<String> _resolveLocationLabel(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        final parts = [
          place.locality,
          place.subLocality,
          place.street,
        ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();
        final label = parts.join('، ');
        if (label.trim().isNotEmpty) return label;
      }
    } catch (_) {}

    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  }

  static String _cachedLocationLabel() {
    final cached = CacheHelper.sharedPreferences?.getString('location');
    if (cached != null && cached.trim().isNotEmpty) return cached;
    return 'تحديد الموقع';
  }
}
