import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Carte in-app : stack **actuelle** du projet Teranga Pass.
///
/// - Moteur : [`flutter_map`](https://pub.dev/packages/flutter_map)
/// - Tuiles : [OpenStreetMap](https://www.openstreetmap.org/) (serveur public `tile.openstreetmap.org`)
///
/// Étape 4 du plan produit (`docs/TerangaPass_Plan_Etape_par_Etape.md` à la racine du dépôt) :
/// **faire mûrir cette stack** (perf, cohérence, accessibilité), sans migration Mapbox/Google
/// tant qu’un arbitrage séparé ne l’impose pas.
class MapConstants {
  MapConstants._();

  /// Modèle d’URL des tuiles raster OSM standard.
  static const String osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Identifiant pour la politique d’usage des tuiles OSM (cf. OSM Foundation).
  /// Aligné sur `applicationId` Android (`com.terangapass.app`).
  static const String tileUserAgentPackageName = 'com.terangapass.app';

  /// Tuile de secours (gris 1×1) si le réseau ou OSM ne répond pas (`TileLayer.errorImage`).
  static final ImageProvider tileLoadErrorImage = MemoryImage(
    Uint8List.fromList(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
      ),
    ),
  );
}
