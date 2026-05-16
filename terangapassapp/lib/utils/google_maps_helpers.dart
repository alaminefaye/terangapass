import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
/// Helpers partagés pour [google_maps_flutter].
class GoogleMapsHelpers {
  GoogleMapsHelpers._();

  static LatLngBounds boundsFromPoints(Iterable<LatLng> points) {
    final list = points.toList();
    if (list.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(14.69, -17.45),
        northeast: const LatLng(14.72, -17.42),
      );
    }
    var minLat = list.first.latitude;
    var maxLat = minLat;
    var minLng = list.first.longitude;
    var maxLng = minLng;
    for (final p in list.skip(1)) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  static Future<void> animateTo(
    GoogleMapController? controller,
    LatLng target, {
    double zoom = 14,
  }) async {
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(target, zoom),
    );
  }

  static Future<void> fitBounds(
    GoogleMapController? controller,
    Iterable<LatLng> points, {
    double padding = 48,
  }) async {
    if (controller == null) return;
    final list = points.toList();
    if (list.isEmpty) return;
    if (list.length == 1) {
      await animateTo(controller, list.first, zoom: 15);
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        boundsFromPoints(list),
        padding,
      ),
    );
  }

  static Future<void> animateNavigation(
    GoogleMapController? controller,
    LatLng target, {
    double zoom = 17,
    double bearing = 0,
  }) async {
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: zoom,
          bearing: bearing,
          tilt: 0,
        ),
      ),
    );
  }

  static double markerHueForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('sos') || c.contains('urgence') || c.contains('help')) {
      return BitmapDescriptor.hueRed;
    }
    if (c.contains('pharm')) return BitmapDescriptor.hueAzure;
    if (c.contains('hôtel') || c.contains('hotel')) {
      return BitmapDescriptor.hueViolet;
    }
    if (c.contains('restaurant')) return BitmapDescriptor.hueOrange;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return BitmapDescriptor.hueGreen;
    }
    if (c.contains('hôpital') || c.contains('hopital')) {
      return BitmapDescriptor.hueRose;
    }
    return BitmapDescriptor.hueYellow;
  }

  static Color colorForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('sos') || c.contains('urgence') || c.contains('help')) {
      return const Color(0xFFD32F2F);
    }
    if (c.contains('pharm')) return Colors.blue;
    if (c.contains('hôtel') || c.contains('hotel')) return Colors.purple;
    if (c.contains('restaurant')) return Colors.orange;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return const Color(0xFF2E7D32);
    }
    return Colors.grey;
  }
}
