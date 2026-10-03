import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';

class MapTiles extends StatelessWidget {
  const MapTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: AppConfig.tileUrl,
      subdomains: AppConfig.tileSubdomains,
      userAgentPackageName: AppConfig.packageName,
      retinaMode: RetinaMode.isHighDensity(context),
    );
  }
}

class PinMarker extends StatelessWidget {
  const PinMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.location_on, size: 46, color: Color(0xFFB5735A));
  }
}

MarkerLayer pinLayer(LatLng point) => MarkerLayer(
      markers: [
        Marker(
          point: point,
          width: 46,
          height: 46,
          alignment: Alignment.topCenter,
          child: const PinMarker(),
        ),
      ],
    );
