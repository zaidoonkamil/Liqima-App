import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/ navigation/navigation.dart';
import '../../../core/styles/themes.dart';

class AdminLocationResult {
  const AdminLocationResult({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class AdminLocationPickerPage extends StatefulWidget {
  const AdminLocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<AdminLocationPickerPage> createState() =>
      _AdminLocationPickerPageState();
}

class _AdminLocationPickerPageState extends State<AdminLocationPickerPage> {
  static const _baghdad = LatLng(33.3152, 44.3661);

  late LatLng selectedLocation =
      widget.initialLatitude != null && widget.initialLongitude != null
          ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
          : _baghdad;

  void _selectLocation(LatLng value) {
    setState(() => selectedLocation = value);
  }

  void _confirmLocation() {
    navigateBack(
      context,
      AdminLocationResult(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      ),
    );
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
              initialCameraPosition: CameraPosition(
                target: selectedLocation,
                zoom: 15,
              ),
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onTap: _selectLocation,
              markers: {
                Marker(
                  markerId: const MarkerId('restaurant_location'),
                  position: selectedLocation,
                  draggable: true,
                  onDragEnd: _selectLocation,
                ),
              },
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .12),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
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
                                'حدد موقع المطعم',
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
              right: 14,
              bottom: 22,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .14),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.gps,
                            color: primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${selectedLocation.latitude.toStringAsFixed(6)}, ${selectedLocation.longitude.toStringAsFixed(6)}',
                              textDirection: TextDirection.ltr,
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
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _confirmLocation,
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Text(
                            'اعتماد الموقع',
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
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF151B18), size: 18),
      ),
    );
  }
}
