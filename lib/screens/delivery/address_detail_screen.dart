import 'dart:async';
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

class AddressDetailScreen extends ConsumerStatefulWidget {
  final DeliveryAddress? initial;
  const AddressDetailScreen({super.key, this.initial});

  @override
  ConsumerState<AddressDetailScreen> createState() => _AddressDetailScreenState();
}

class _AddressDetailScreenState extends ConsumerState<AddressDetailScreen> {
  final _controller = MapController();
  late LatLng _center;
  String _address = '';
  bool _resolving = false;
  Timer? _debounce;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _center = i == null ? const LatLng(AppConfig.defaultLat, AppConfig.defaultLng) : LatLng(i.lat, i.lng);
    _address = i?.address ?? '';
    if (i == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _myLocation(silent: true));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _scheduleResolve() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _resolve);
  }

  Future<void> _resolve() async {
    final id = ++_requestId;
    setState(() => _resolving = true);
    final text = await LocationService.reverse(_center.latitude, _center.longitude);
    if (!mounted || id != _requestId) return;
    setState(() {
      _address = text;
      _resolving = false;
    });
  }

  Future<void> _myLocation({bool silent = false}) async {
    final t = ref.read(stringsProvider);
    try {
      final p = await LocationService.current();
      _center = LatLng(p.latitude, p.longitude);
      _controller.move(_center, 17);
      _resolve();
    } catch (e) {
      if (!silent && mounted) showMessage(context, errorText(e, t));
      if (silent) _resolve();
    }
  }

  void _confirm() {
    if (_address.isEmpty || _resolving) return;
    context.pop(DeliveryAddress(
      address: _address,
      lat: _center.latitude,
      lng: _center.longitude,
      detail: widget.initial?.detail ?? '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(stringsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(t('addressDetail'), style: AppText.s(22, weight: FontWeight.w500)),
                  Positioned(
                    left: 14,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    child: IconButton(
                      onPressed: _confirm,
                      icon: const Icon(Icons.check, size: 28, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _controller,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 16,
                      onPositionChanged: (camera, hasGesture) {
                        _center = camera.center;
                        if (hasGesture) _scheduleResolve();
                      },
                    ),
                    children: [
                      const MapTiles(),
                      SimpleAttributionWidget(
                        source: Text('OpenStreetMap contributors, CARTO', style: AppText.s(10)),
                        backgroundColor: Colors.white70,
                        alignment: Alignment.topRight,
                      ),
                    ],
                  ),
                  const IgnorePointer(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 46),
                        child: PinMarker(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 150 + bottom,
                    child: FloatingActionButton.small(
                      heroTag: 'myloc',
                      backgroundColor: Colors.white,
                      onPressed: () => _myLocation(),
                      child: const Icon(Icons.my_location, color: AppColors.brown),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20 + bottom,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: AppColors.textBrown),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _resolving
                                ? Text(t('loading'), style: AppText.s(15, color: AppColors.textGrey))
                                : Text(
                                    _address.isEmpty ? t('address') : _address,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.s(15),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
