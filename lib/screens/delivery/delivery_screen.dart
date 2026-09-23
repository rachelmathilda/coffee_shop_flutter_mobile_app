import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  GoogleMapController? _mapController;
  final _detailCtrl = TextEditingController();
  bool _locating = false;

  static const _fallback = LatLng(-6.2088, 106.8456);

  @override
  void dispose() {
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _findLocation() async {
    setState(() => _locating = true);
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final address = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Unknown location';

      ref.read(deliveryAddressProvider.notifier).state = DeliveryAddress(
        address: address,
        lat: position.latitude,
        lng: position.longitude,
        detail: _detailCtrl.text,
      );

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          16,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _openAddressDetail() async {
    final current = ref.read(deliveryAddressProvider);
    await context.push('/address-detail', extra: current);
    final updated = ref.read(deliveryAddressProvider);
    if (updated != null) {
      _detailCtrl.text = updated.detail;
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(deliveryAddressProvider);
    final fee = ref.watch(deliveryFeeProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
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
          'Delivery',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: address != null
                        ? LatLng(address.lat, address.lng)
                        : _fallback,
                    zoom: 14,
                  ),
                  onMapCreated: (c) => _mapController = c,
                  markers: address != null
                      ? {
                          Marker(
                            markerId: const MarkerId('delivery'),
                            position: LatLng(address.lat, address.lng),
                          ),
                        }
                      : {},
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: ElevatedButton.icon(
                    onPressed: _locating ? null : _findLocation,
                    icon: _locating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, size: 18),
                    label: const Text('Find your location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _openAddressDetail,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDDD0C0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address?.address ?? 'Address',
                            style: TextStyle(
                              color: address == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _detailCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Add detail',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            onChanged: (v) {
                              final current = ref.read(deliveryAddressProvider);
                              if (current != null) {
                                ref
                                    .read(deliveryAddressProvider.notifier)
                                    .state = current.copyWith(
                                  detail: v,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: fee.when(
              data: (feeValue) {
                final total = cartTotal + feeValue;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text('\$ ${feeValue.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '\$ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: address == null
                          ? null
                          : () => context.push('/payment', extra: total),
                      child: const Text('Go To Payment'),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('couldn\'t load delivery fee: $err'),
            ),
          ),
        ],
      ),
    );
  }
}
