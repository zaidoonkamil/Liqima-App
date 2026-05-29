import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/network/local/cache_helper.dart';
import '../../../core/styles/themes.dart';
import '../data/user_profile_api_data.dart';

class UserAddressPickerResult {
  const UserAddressPickerResult({
    required this.type,
    required this.title,
    required this.addressText,
    required this.details,
    required this.latitude,
    required this.longitude,
    this.addressId,
  });

  final int? addressId;
  final String type;
  final String title;
  final String addressText;
  final String details;
  final double latitude;
  final double longitude;
}

class UserAddressPickerPage extends StatefulWidget {
  const UserAddressPickerPage({super.key, this.address});

  final UserAddressData? address;

  @override
  State<UserAddressPickerPage> createState() => _UserAddressPickerPageState();
}

class _UserAddressPickerPageState extends State<UserAddressPickerPage> {
  static const _baghdad = LatLng(33.3152, 44.3661);

  late LatLng selectedLocation = _initialLocation();
  late String selectedType = widget.address?.type ?? 'home';
  late final TextEditingController detailsController = TextEditingController(
    text: widget.address?.details ?? '',
  );
  late String addressText =
      widget.address?.addressText ?? _coordinateText(selectedLocation);
  bool resolvingAddress = false;
  GoogleMapController? mapController;

  LatLng _initialLocation() {
    final address = widget.address;
    if (address?.latitude != null && address?.longitude != null) {
      return LatLng(address!.latitude!, address.longitude!);
    }

    final cachedLatitude = double.tryParse(
      CacheHelper.getData(key: 'latitude')?.toString() ?? '',
    );
    final cachedLongitude = double.tryParse(
      CacheHelper.getData(key: 'longitude')?.toString() ?? '',
    );
    if (cachedLatitude != null && cachedLongitude != null) {
      return LatLng(cachedLatitude, cachedLongitude);
    }

    return _baghdad;
  }

  Future<void> _resolveAddress() async {
    if (!mounted) return;
    setState(() => resolvingAddress = true);
    try {
      final places = await placemarkFromCoordinates(
        selectedLocation.latitude,
        selectedLocation.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        final parts =
            [place.locality, place.subLocality, place.street]
                .where((part) => part != null && part.trim().isNotEmpty)
                .cast<String>();
        final label = parts.join('، ');
        if (label.isNotEmpty) addressText = label;
      }
    } catch (_) {
      addressText = _coordinateText(selectedLocation);
    } finally {
      if (mounted) setState(() => resolvingAddress = false);
    }
  }

  Future<void> _goToMyLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final target = LatLng(position.latitude, position.longitude);
    selectedLocation = target;
    await mapController?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)),
    );
    await _resolveAddress();
  }

  void _confirm() {
    final title = _typeLabel(selectedType);
    final safeAddressText =
        addressText.trim().isEmpty
            ? _coordinateText(selectedLocation)
            : addressText.trim();
    navigateBack(
      context,
      UserAddressPickerResult(
        addressId: widget.address?.id,
        type: selectedType,
        title: title,
        addressText: safeAddressText,
        details: detailsController.text.trim(),
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      ),
    );
  }

  @override
  void dispose() {
    mapController?.dispose();
    detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: selectedLocation,
                zoom: 16,
              ),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMove: (position) => selectedLocation = position.target,
              onCameraIdle: _resolveAddress,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32),
                child: Icon(
                  Icons.location_pin,
                  color: secondaryColor,
                  size: 42,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    _CircleMapButton(
                      icon: Iconsax.arrow_right_3,
                      onTap: () => navigateBack(context),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _floatingDecoration(16),
                        child: const Row(
                          children: [
                            Icon(
                              Iconsax.location,
                              color: primaryColor,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'حدد عنوانك',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF151B18),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              bottom: 218,
              child: _CircleMapButton(
                icon: Iconsax.gps,
                onTap: _goToMyLocation,
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 22,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _floatingDecoration(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypeSelector(
                        selectedType: selectedType,
                        onChanged: (value) {
                          setState(() => selectedType = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            resolvingAddress ? Iconsax.timer : Iconsax.gps,
                            color: primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              addressText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF151B18),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: detailsController,
                        minLines: 1,
                        maxLines: 2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: InputDecoration(
                          hintText: 'تفاصيل إضافية: رقم البيت، الطابق...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9CA3A0),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAF8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E8E5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E8E5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _confirm,
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Text(
                            'حفظ العنوان',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selectedType, required this.onChanged});

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const types = ['home', 'work', 'other'];
    return Row(
      children:
          types.map((type) {
            final active = selectedType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onChanged(type),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          active
                              ? primaryColor.withValues(alpha: .10)
                              : const Color(0xFFF8FAF8),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: active ? primaryColor : const Color(0xFFE5E8E5),
                      ),
                    ),
                    child: Text(
                      _typeLabel(type),
                      style: TextStyle(
                        color: active ? primaryColor : const Color(0xFF565F5A),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _CircleMapButton extends StatelessWidget {
  const _CircleMapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: _floatingDecoration(21),
        child: Icon(icon, color: const Color(0xFF151B18), size: 18),
      ),
    );
  }
}

BoxDecoration _floatingDecoration(double radius) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .14),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

String _typeLabel(String type) {
  return switch (type) {
    'work' => 'العمل',
    'other' => 'آخر',
    _ => 'المنزل',
  };
}

String _coordinateText(LatLng value) {
  return '${value.latitude.toStringAsFixed(5)}, ${value.longitude.toStringAsFixed(5)}';
}
