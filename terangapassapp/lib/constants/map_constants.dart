import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Carte in-app : **Google Maps** via [`google_maps_flutter`](https://pub.dev/packages/google_maps_flutter).
///
/// Itinéraires : Google Directions (principal), secours OSRM si indisponible.
class MapConstants {
  MapConstants._();

  /// Clé API (également dans AndroidManifest + iOS AppDelegate).
  static const String googleMapsApiKey =
      'AIzaSyCN1MyOGuAiD1EE7WSp74lSMHX2scGHn-A';

  /// Identifiant package (restrictions clé Google Cloud).
  static const String tileUserAgentPackageName = 'com.terangapass.app';

  /// Image 1×1 grise (secours si besoin hors Google Maps).
  static final ImageProvider tileLoadErrorImage = MemoryImage(
    Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      ),
    ),
  );
}
