import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class AddressDetailScreen extends ConsumerStatefulWidget {
  final DeliveryAddress? initial;
  const AddressDetailScreen({super.key, this.initial});

  @override
  ConsumerState<AddressDetailScreen> createState() =>
      _AddressDetailScreenState();
}

class _AddressDetailScreenState extends ConsumerState<AddressDetailScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(-6.2088, 106.8456);
  String _address = 'Move the map to set your location';
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _center = LatLng(widget.initial!.lat, widget.initial!.lng);
      _address = widget.initial!.address;
    }
  }

  Future<void> _resolveAddress(LatLng position) async {
    setState(() => _resolving = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final address = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Unknown location';
      if (mounted) setState(() => _address = address);
    } catch (_) {
      if (mounted) setState(() => _address = 'Unknown location');
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  void _confirm() {
    ref.read(deliveryAddressProvider.notifier).state = DeliveryAddress(
      address: _address,
      lat: _center.latitude,
      lng: _center.longitude,
      detail: widget.initial?.detail ?? '',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Address Detail',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _confirm,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 16),
            onMapCreated: (c) => _mapController = c,
            onCameraMove: (position) => _center = position.target,
            onCameraIdle: () => _resolveAddress(_center),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_resolving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.place_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_address)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
