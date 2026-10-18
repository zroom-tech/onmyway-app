import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// 기본 지도 위치 = 서울시청 (traffic-signal OD-001 [가정])
const defaultCenter = LatLng(37.5663, 126.9779);

/// OpenStreetMap 지도 (D-064). 공개 타일 서버는 개발용 — 출시 전 자체 타일 서버로 바꿔야 한다.
/// 저작자 표시는 ODbL 요구사항이라 지우지 않는다.
class OsmMap extends StatelessWidget {
  const OsmMap({super.key, required this.controller, this.layers = const [], this.onTap, this.center = defaultCenter, this.onMove, this.onReady});

  final MapController controller;
  final List<Widget> layers;
  final void Function(LatLng)? onTap;
  final LatLng center;
  final void Function(MapCamera)? onMove;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 17,
        maxZoom: 19,
        onTap: onTap == null ? null : (_, latLng) => onTap!(latLng),
        onMapReady: onReady,
        onPositionChanged: onMove == null ? null : (camera, _) => onMove!(camera),
      ),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.onmyway.onmyway', maxZoom: 19),
        ...layers,
        const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
      ],
    );
  }
}
