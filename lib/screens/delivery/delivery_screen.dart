import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_config.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/app_exception.dart';
import '../../services/location_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/map_view.dart';
import '../../widgets/simple_app_bar.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  final _mapController = MapController();
  final _detailCtrl = TextEditingController();
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _detailCtrl.text = ref.read(deliveryAddressProvider)?.detail ?? '';
  }

  @override
  void dispose() {
    _detailCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _setAddress(DeliveryAddress a) {
    ref.read(deliveryAddressProvider.notifier).state = a.copyWith(detail: _detailCtrl.text);
    try {
      _mapController.move(LatLng(a.lat, a.lng), 16);
    } catch (_) {}
  }

  Future<void> _findLocation() async {
    final t = ref.read(stringsProvider);
    setState(() => _locating = true);
    try {
      final p = await LocationService.current();
      final text = await LocationService.reverse(p.latitude, p.longitude);
      _setAddress(DeliveryAddress(address: text, lat: p.latitude, lng: p.longitude));
    } catch (e) {
      if (mounted) showMessage(context, errorText(e, t));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _openDetail() async {
    final result = await context.push<DeliveryAddress>(
      '/address-detail',
      extra: ref.read(deliveryAddressProvider),
    );
    if (result != null) _setAddress(result);
  }

  void _goToPayment() {
    final t = ref.read(stringsProvider);
    final a = ref.read(deliveryAddressProvider);
    if (a == null) {
      showMessage(context, t('chooseAddress'));
      return;
    }
    ref.read(deliveryAddressProvider.notifier).state = a.copyWith(detail: _detailCtrl.text.trim());
    context.push('/payment');
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final address = ref.watch(deliveryAddressProvider);
    final summary = ref.watch(checkoutSummaryProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    final center = address == null
        ? const LatLng(AppConfig.defaultLat, AppConfig.defaultLng)
        : LatLng(address.lat, address.lng);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SimpleTopBar(title: t('delivery')),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(21, 8, 21, 16),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 278,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: center,
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              onTap: (_, _) => _openDetail(),
                            ),
                            children: [
                              const MapTiles(),
                              if (address != null) pinLayer(center),
                            ],
                          ),
                          Positioned(
                            left: 41,
                            right: 41,
                            bottom: 20,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: _locating ? null : _findLocation,
                                child: SizedBox(
                                  height: 42,
                                  child: Center(
                                    child: _locating
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brown),
                                          )
                                        : Text(t('findYourLocation'), style: AppText.s(20)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.textBrown),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _openDetail,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.textBrown, size: 26),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  address?.address ?? t('address'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.s(16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.textBrown, size: 24),
                            const SizedBox(width: 22),
                            Expanded(
                              child: TextField(
                                controller: _detailCtrl,
                                style: AppText.s(16),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: t('addDetail'),
                                  hintStyle: AppText.s(16, color: const Color(0xFF9A9A9A)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(38, 0, 38, 20),
              child: Column(
                children: [
                  if (summary.discount > 0)
                    _Row(label: t('discountRow'), value: '- ${money(summary.discount)}', size: 18),
                  _Row(label: t('deliveryFee'), value: money(summary.deliveryFee), size: 18),
                  const SizedBox(height: 10),
                  _Row(label: t('totalPrice'), value: money(summary.total), size: 20),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(21, 0, 21, 16 + bottom),
              child: PrimaryButton(label: t('goToPayment'), onTap: _goToPayment),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final double size;
  const _Row({required this.label, required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: AppText.s(size)),
          const Spacer(),
          Text(value, style: AppText.s(size + 2, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
