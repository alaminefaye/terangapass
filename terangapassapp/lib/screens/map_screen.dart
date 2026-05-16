import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/google_maps_helpers.dart';
import '../services/google_directions_service.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../widgets/loading_placeholders.dart';
import '../widgets/map_legend_strip.dart';
import '../services/offline_pack_service.dart';
import '../widgets/offline_cache_snack.dart';
import 'place_detail_screen.dart';

enum _MapFilter { all, help, sites, hotels, restaurants, pharmacies, hospitals }

class MapScreen extends StatefulWidget {
  final String? initialQuery;
  final LatLng? initialLatLng;
  final String? focusedPlaceName;

  const MapScreen({
    super.key,
    this.initialQuery,
    this.initialLatLng,
    this.focusedPlaceName,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _fallbackLat = 14.6937; // Dakar centre fallback
  static const double _fallbackLng = -17.4441;
  _MapFilter _selectedFilter = _MapFilter.all;
  bool _isLocating = false;
  double? _currentLat;
  double? _currentLng;
  bool _isLoadingPoints = true;
  String? _pointsErrorMessage;
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _pointsOfInterest = [];
  List<Map<String, dynamic>> _nearbyListPoints = [];
  List<Map<String, dynamic>> _allPoints = [];

  // Lieu choisi depuis la liste « à proximité » (navigation in-app)
  LatLng? _selectedDestination;
  String? _selectedPlaceName;

  // Itinéraire vers le lieu ciblé
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  String? _routeDistance;
  String? _routeDuration;
  String? _routeError;

  // Navigation en temps réel
  bool _isNavigating = false;
  StreamSubscription<Position>? _navPositionSub;
  List<Map<String, dynamic>> _navSteps = [];
  int _currentStepIndex = 0;
  String? _navInstruction;
  String? _navRemainingDistance;
  String? _distanceBeforeManeuver;
  IconData _navIcon = Icons.straight_rounded;
  bool _approachNotified = false;
  bool _arrivalNotified = false;
  int _lastSpokenStepIndex = -1;
  final Set<int> _maneuverPreviewSpoken = {};

  // Synthèse vocale (instructions comme Google Maps)
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  // Notifications locales
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void dispose() {
    _navPositionSub?.cancel();
    _tts.stop();
    _searchController.dispose();
    super.dispose();
  }

  LatLng? get _destination => widget.initialLatLng ?? _selectedDestination;

  String? get _destinationName => widget.focusedPlaceName ?? _selectedPlaceName;

  bool get _hasDestination => _destination != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery?.trim() ?? '';
    if (initial.isNotEmpty) {
      _searchController.text = initial;
    }
    // Si on arrive depuis un lieu précis, on pré-positionne la carte dessus.
    if (widget.initialLatLng != null) {
      _currentLat = widget.initialLatLng!.latitude;
      _currentLng = widget.initialLatLng!.longitude;
    }
    _initNotifications();
    _initTts();
    _initLocationAndLoad().then((_) {
      // Calcul automatique de l'itinéraire si on a un lieu ciblé.
      if (_hasDestination && mounted) {
        _calculateRoute();
      }
    });
  }

  Future<void> _initLocationAndLoad() async {
    try {
      final pos = await LocationService().getCurrentPositionIfAllowed();
      if (mounted && pos != null) {
        setState(() {
          _currentLat = pos.latitude;
          _currentLng = pos.longitude;
        });
      }
    } catch (_) {
      // silent fallback to Dakar center
    } finally {
      if (mounted) {
        _loadPointsOfInterest();
      }
    }
  }

  /// Itinéraire Google Directions (km / durée réalistes), secours OSRM.
  Future<void> _calculateRoute() async {
    final dest = _destination;
    if (dest == null) return;

    final origin = LatLng(
      _currentLat ?? _fallbackLat,
      _currentLng ?? _fallbackLng,
    );

    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
    });

    try {
      final google = await GoogleDirectionsService.fetchDrivingRoute(
        origin: origin,
        destination: dest,
      );
      if (!mounted) return;
      _applyRouteResult(
        points: google.points,
        distanceM: google.distanceMeters,
        durationS: google.durationSeconds,
        navSteps: google.navSteps,
      );
    } on GoogleDirectionsException {
      await _calculateRouteWithOsrm(origin, dest);
    } catch (_) {
      await _calculateRouteWithOsrm(origin, dest);
    }
  }

  void _applyRouteResult({
    required List<LatLng> points,
    required double distanceM,
    required double durationS,
    required List<Map<String, dynamic>> navSteps,
  }) {
    setState(() {
      _routePoints = points;
      _routeDistance = GoogleDirectionsService.formatDistanceLabel(distanceM);
      _routeDuration = GoogleDirectionsService.formatDurationLabel(durationS);
      _navSteps = navSteps;
      _isLoadingRoute = false;
    });

    if (points.length > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        GoogleMapsHelpers.fitBounds(_mapController, points, padding: 80);
      });
    }
  }

  Future<void> _calculateRouteWithOsrm(LatLng origin, LatLng dest) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};${dest.longitude},${dest.latitude}'
        '?overview=full&geometries=geojson&steps=true',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;

      if (response.statusCode != 200) {
        setState(() {
          _routeError = 'Erreur serveur (${response.statusCode})';
          _isLoadingRoute = false;
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        setState(() {
          _routeError = 'Aucun itinéraire trouvé';
          _isLoadingRoute = false;
        });
        return;
      }

      final route = routes.first as Map<String, dynamic>;
      final distanceM = (route['distance'] as num?)?.toDouble() ?? 0;
      final durationS = (route['duration'] as num?)?.toDouble() ?? 0;
      final coords = (route['geometry']?['coordinates'] as List?) ?? [];

      final points = coords
          .whereType<List>()
          .map(
            (c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ),
          )
          .toList();

      final legs = (route['legs'] as List?) ?? [];
      final steps = legs.isNotEmpty
          ? ((legs.first as Map<String, dynamic>)['steps'] as List?) ?? []
          : [];
      final parsedSteps = steps.whereType<Map<String, dynamic>>().toList();

      _applyRouteResult(
        points: points,
        distanceM: distanceM,
        durationS: durationS,
        navSteps: parsedSteps,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _routeError =
            'Impossible de calculer l\'itinéraire. Vérifiez Directions API sur Google Cloud.';
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.48);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _ttsReady = true;
    } catch (_) {
      _ttsReady = false;
    }
  }

  Future<void> _speakNavInstruction(String text) async {
    if (!_ttsReady || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text.trim());
    } catch (_) {}
  }

  void _announceStep(int stepIndex) {
    if (stepIndex < 0 || stepIndex >= _navSteps.length) return;
    if (stepIndex == _lastSpokenStepIndex) return;
    _lastSpokenStepIndex = stepIndex;
    final text = _frenchInstruction(_navSteps[stepIndex]);
    _speakNavInstruction(text);
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    // Demande la permission sur Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _sendNavNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'nav_channel',
      'Navigation Teranga Pass',
      channelDescription: 'Notifications de navigation en temps réel',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails();
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  /// Convertit une étape (Google ou OSRM) en instruction en français.
  String _frenchInstruction(Map<String, dynamic> step) {
    final explicit = (step['instruction'] as String?)?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;

    final type = (step['maneuver']?['type'] ?? '').toString().toLowerCase();
    final modifier = (step['maneuver']?['modifier'] ?? '').toString().toLowerCase();
    final name = (step['name'] ?? '').toString().trim();

    final modifierFr = switch (modifier) {
      'uturn' => 'faire demi-tour',
      'sharp right' => 'tourner fortement à droite',
      'right' => 'tourner à droite',
      'slight right' => 'légèrement à droite',
      'straight' => 'tout droit',
      'slight left' => 'légèrement à gauche',
      'left' => 'tourner à gauche',
      'sharp left' => 'tourner fortement à gauche',
      _ => '',
    };

    return switch (type) {
      'depart' => 'Partez${name.isNotEmpty ? " sur $name" : ""}',
      'arrive' => 'Vous êtes arrivé à destination',
      'turn' => '${modifierFr.isNotEmpty ? modifierFr.substring(0, 1).toUpperCase() + modifierFr.substring(1) : "Continuez"}${name.isNotEmpty ? " sur $name" : ""}',
      'continue' || 'new name' => 'Continuez${name.isNotEmpty ? " sur $name" : " tout droit"}',
      'merge' => 'Rejoignez${name.isNotEmpty ? " $name" : " la route"}',
      'on ramp' => 'Prenez la bretelle${name.isNotEmpty ? " vers $name" : ""}',
      'off ramp' => 'Prenez la sortie${name.isNotEmpty ? " vers $name" : ""}',
      'fork' => modifier.contains('right')
          ? 'Restez à droite${name.isNotEmpty ? " sur $name" : ""}'
          : 'Restez à gauche${name.isNotEmpty ? " sur $name" : ""}',
      'roundabout' || 'rotary' => 'Prenez le rond-point',
      'exit roundabout' || 'exit rotary' => 'Sortez du rond-point',
      _ => name.isNotEmpty ? 'Continuez sur $name' : 'Continuez',
    };
  }

  IconData _iconForInstruction(Map<String, dynamic> step) {
    final modifier = (step['maneuver']?['modifier'] ?? '').toString().toLowerCase();
    final type = (step['maneuver']?['type'] ?? '').toString().toLowerCase();
    if (type == 'arrive') return Icons.flag_rounded;
    if (type == 'roundabout' || type == 'rotary') return Icons.roundabout_left_rounded;
    return switch (modifier) {
      'right' || 'sharp right' => Icons.turn_right_rounded,
      'slight right' => Icons.turn_slight_right_rounded,
      'left' || 'sharp left' => Icons.turn_left_rounded,
      'slight left' => Icons.turn_slight_left_rounded,
      'uturn' => Icons.u_turn_left_rounded,
      _ => Icons.straight_rounded,
    };
  }

  void _startInAppNavigation() {
    if (_routePoints.isEmpty || _isNavigating) return;
    _lastSpokenStepIndex = -1;
    _maneuverPreviewSpoken.clear();
    setState(() {
      _isNavigating = true;
      _currentStepIndex = 0;
      _approachNotified = false;
      _arrivalNotified = false;
      _navInstruction = _navSteps.isNotEmpty
          ? _frenchInstruction(_navSteps.first)
          : 'Suivez la route';
      _navIcon = _navSteps.isNotEmpty
          ? _iconForInstruction(_navSteps.first)
          : Icons.straight_rounded;
      _navRemainingDistance = _routeDistance;
    });

    if (_navSteps.isNotEmpty) {
      _announceStep(0);
    } else {
      _speakNavInstruction('Suivez la route vers votre destination');
    }

    _navPositionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 8,
      ),
    ).listen(_onNavPositionUpdate);

    // Centrer immédiatement sur la position actuelle
    if (_currentLat != null && _currentLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            GoogleMapsHelpers.animateNavigation(
              _mapController,
              LatLng(_currentLat!, _currentLng!),
            );
          } catch (_) {}
        }
      });
    }
  }

  void _stopNavigation() {
    _navPositionSub?.cancel();
    _navPositionSub = null;
    _tts.stop();
    _lastSpokenStepIndex = -1;
    _maneuverPreviewSpoken.clear();
    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _navInstruction = null;
      _navRemainingDistance = null;
      _distanceBeforeManeuver = null;
      _approachNotified = false;
      _arrivalNotified = false;
    });
    // Remettre la carte à l'orientation nord
    if (_currentLat != null && _currentLng != null) {
      GoogleMapsHelpers.animateNavigation(
        _mapController,
        LatLng(_currentLat!, _currentLng!),
        bearing: 0,
      );
    }
  }

  void _onNavPositionUpdate(Position pos) {
    if (!mounted) return;
    setState(() {
      _currentLat = pos.latitude;
      _currentLng = pos.longitude;
    });

    // Recentrer la carte + orienter selon la direction de déplacement
    final heading = pos.heading;
    final bearing = heading.isFinite && heading >= 0 ? heading : 0.0;
    GoogleMapsHelpers.animateNavigation(
      _mapController,
      LatLng(pos.latitude, pos.longitude),
      bearing: bearing,
    );

    // Distance avant le prochain virage + passage à l'étape suivante
    if (_navSteps.isNotEmpty && _currentStepIndex < _navSteps.length) {
      final currentStep = _navSteps[_currentStepIndex];
      final loc = currentStep['maneuver']?['location'];
      if (loc is List && loc.length >= 2) {
        final stepLat = (loc[1] as num).toDouble();
        final stepLng = (loc[0] as num).toDouble();
        final distToManeuver = Geolocator.distanceBetween(
          pos.latitude, pos.longitude, stepLat, stepLng,
        );
        setState(() {
          _distanceBeforeManeuver = distToManeuver < 1000
              ? 'Dans ${distToManeuver.round()} m'
              : 'Dans ${(distToManeuver / 1000).toStringAsFixed(1)} km';
        });

        // Annonce vocale à ~80 m du virage
        if (distToManeuver <= 80 &&
            distToManeuver > 35 &&
            !_maneuverPreviewSpoken.contains(_currentStepIndex)) {
          _maneuverPreviewSpoken.add(_currentStepIndex);
          final preview = _frenchInstruction(currentStep);
          _speakNavInstruction(
            'Dans ${distToManeuver.round()} mètres, $preview',
          );
        }

        if (distToManeuver < 35 && _currentStepIndex < _navSteps.length - 1) {
          final nextIndex = _currentStepIndex + 1;
          setState(() {
            _currentStepIndex = nextIndex;
            _navInstruction = _frenchInstruction(_navSteps[nextIndex]);
            _navIcon = _iconForInstruction(_navSteps[nextIndex]);
          });
          _announceStep(nextIndex);
        }
      }
    }

    // Distance restante + notifications de proximité et d'arrivée
    final dest = _destination;
    if (dest != null) {
      final remaining = Geolocator.distanceBetween(
        pos.latitude, pos.longitude, dest.latitude, dest.longitude,
      );
      setState(() {
        _navRemainingDistance = remaining < 1000
            ? '${remaining.round()} m'
            : '${(remaining / 1000).toStringAsFixed(1)} km';
      });

      // Notification d'approche (200 m)
      if (remaining <= 200 && !_approachNotified) {
        _approachNotified = true;
        _sendNavNotification(
          id: 1,
          title: 'Vous approchez !',
          body: 'Votre destination est à ${remaining.round()} mètres.',
        );
        if (mounted) {
          final approachText =
              'Dans ${remaining.round()} mètres, vous arriverez à destination';
          setState(() {
            _navInstruction = approachText;
            _navIcon = Icons.flag_rounded;
          });
          _speakNavInstruction(approachText);
        }
      }

      // Arrivée à destination (30 m)
      if (remaining <= 30 && !_arrivalNotified) {
        _arrivalNotified = true;
        _sendNavNotification(
          id: 2,
          title: 'Vous êtes arrivé !',
          body: 'Vous avez atteint votre destination : ${_destinationName ?? ""}',
        );
        if (mounted) {
          const arrivalText = 'Vous êtes arrivé à destination';
          setState(() {
            _navInstruction = arrivalText;
            _navIcon = Icons.flag_rounded;
          });
          _speakNavInstruction(arrivalText);
        }
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) _stopNavigation();
        });
      }
    }
  }

  String _embassyDisplayCategory(Map<String, dynamic> e) {
    final mt = (e['mission_type'] ?? '').toString().toLowerCase();
    if (mt.contains('consul')) return 'Consulats';
    return 'Ambassades';
  }

  Map<String, dynamic> _mapEmbassyToPoint(Map<String, dynamic> raw) {
    final id = raw['id'] ?? raw.hashCode;
    final lat = _toDouble(raw['latitude']);
    final lng = _toDouble(raw['longitude']);
    double? distM;
    var distance = 'N/A';
    if (_currentLat != null &&
        _currentLng != null &&
        lat != null &&
        lng != null) {
      distM = LocationService().calculateDistance(
        _currentLat!,
        _currentLng!,
        lat,
        lng,
      );
      distance = distM < 1000
          ? '${distM.round()} m'
          : '${(distM / 1000).toStringAsFixed(1)} km';
    }
    return {
      'id': 'embassy_$id',
      'name': raw['name'],
      'category': _embassyDisplayCategory(raw),
      'distance': distance,
      'distance_meters': distM,
      'latitude': lat,
      'longitude': lng,
      'address': raw['address'],
      'phone': raw['phone'],
    };
  }

  double _sortDistanceMeters(Map<String, dynamic> point) {
    final v = point['distance_meters'];
    if (v is num) return v.toDouble();
    final d = _toDouble(v);
    if (d != null) return d;
    final lat = _toDouble(point['latitude'] ?? point['lat']);
    final lng = _toDouble(
      point['longitude'] ?? point['lng'] ?? point['lon'],
    );
    if (_currentLat != null &&
        _currentLng != null &&
        lat != null &&
        lng != null) {
      return LocationService().calculateDistance(
        _currentLat!,
        _currentLng!,
        lat,
        lng,
      );
    }
    return double.infinity;
  }

  Future<void> _loadPointsOfInterest() async {
    setState(() {
      _isLoadingPoints = true;
      _pointsErrorMessage = null;
    });

    try {
      final apiService = ApiService();
      final lat = _currentLat;
      final lng = _currentLng;

      const mapPoiLimit = 100;
      const nearbySheetLimit = 40;
      List<dynamic> points;
      if (lat != null && lng != null) {
        final nearby = await apiService.getNearby(
          latitude: lat,
          longitude: lng,
          radiusMeters: 10000,
          limit: mapPoiLimit,
        );
        points = nearby.data;
      } else {
        final poi = await apiService.getPointsOfInterest(limit: mapPoiLimit);
        points = poi.data;
      }

      List<dynamic> sites = const [];
      try {
        sites = await apiService.getCompetitionSites();
      } catch (e, st) {
        debugPrint('[Map] competition sites: $e\n$st');
      }

      List<dynamic> embassies = const [];
      try {
        embassies = await apiService.getEmbassies();
      } catch (e, st) {
        debugPrint('[Map] embassies: $e\n$st');
      }

      final sitePoints = sites
          .whereType<Map<String, dynamic>>()
          .map((s) {
            final m = Map<String, dynamic>.from(
              s.map((k, v) => MapEntry(k.toString(), v)),
            );
            final pLat = _toDouble(m['latitude']);
            final pLng = _toDouble(m['longitude']);
            double? dm;
            if (lat != null &&
                lng != null &&
                pLat != null &&
                pLng != null) {
              dm = LocationService().calculateDistance(
                lat,
                lng,
                pLat,
                pLng,
              );
            }
            return <String, dynamic>{
              'id': 'site_${m['id']}',
              'name': m['name'],
              'category': 'Sites JOJ',
              'distance': m['location'] ?? '',
              'distance_meters': dm,
              'latitude': m['latitude'],
              'longitude': m['longitude'],
              'address': m['address'] ?? m['location'],
            };
          })
          .toList();

      final embassyPoints = embassies
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => _mapEmbassyToPoint(
              Map<String, dynamic>.from(
                e.map((k, v) => MapEntry(k.toString(), v)),
              ),
            ),
          )
          .toList();

      final merged = [
        ...points.whereType<Map<String, dynamic>>(),
        ...sitePoints,
        ...embassyPoints,
      ]..sort(
          (a, b) => _sortDistanceMeters(a).compareTo(_sortDistanceMeters(b)),
        );

      final capped = merged.length > mapPoiLimit + 30
          ? merged.take(mapPoiLimit + 30).toList()
          : merged;
      final filtered = capped.where(_matchesCurrentFilter).toList();
      if (!mounted) return;
      setState(() {
        _allPoints = capped;
        _pointsOfInterest = filtered;
        _nearbyListPoints = filtered.take(nearbySheetLimit).toList();
      });
      _syncMapToPoints();
    } catch (e) {
      if (!mounted) return;
      final offlinePoi = await OfflinePackService().readOfflinePoiList();
      final offlineSites =
          await OfflinePackService().readOfflineCompetitionSitesList();
      final offlineEmb =
          await OfflinePackService().readOfflineEmbassiesList();
      if (offlinePoi.isNotEmpty ||
          offlineSites.isNotEmpty ||
          offlineEmb.isNotEmpty) {
        final lat = _currentLat;
        final lng = _currentLng;
        final sitePoints = offlineSites.map((s) {
          final m = Map<String, dynamic>.from(
            s.map((k, v) => MapEntry(k.toString(), v)),
          );
          final pLat = _toDouble(m['latitude']);
          final pLng = _toDouble(m['longitude']);
          double? dm;
          if (lat != null &&
              lng != null &&
              pLat != null &&
              pLng != null) {
            dm = LocationService().calculateDistance(lat, lng, pLat, pLng);
          }
          return <String, dynamic>{
            'id': 'site_${m['id']}',
            'name': m['name'],
            'category': 'Sites JOJ',
            'distance': m['location'] ?? '',
            'distance_meters': dm,
            'latitude': m['latitude'],
            'longitude': m['longitude'],
            'address': m['address'] ?? m['location'],
          };
        }).toList();
        final embassyPoints = offlineEmb
            .map(
              (e) => _mapEmbassyToPoint(
                Map<String, dynamic>.from(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                ),
              ),
            )
            .toList();
        final merged = [
          ...offlinePoi,
          ...sitePoints,
          ...embassyPoints,
        ]..sort(
            (a, b) =>
                _sortDistanceMeters(a).compareTo(_sortDistanceMeters(b)),
          );
        const nearbySheetLimit = 40;
        final filtered = merged.where(_matchesCurrentFilter).toList();
        setState(() {
          _allPoints = merged;
          _pointsOfInterest = filtered;
          _nearbyListPoints = filtered.take(nearbySheetLimit).toList();
          _pointsErrorMessage = null;
        });
        _syncMapToPoints();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showOfflineCacheSnackBar(context);
        });
      } else {
        setState(() {
          _allPoints = [];
          _pointsOfInterest = [];
          _nearbyListPoints = [];
          _pointsErrorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPoints = false;
        });
      }
    }
  }

  bool _matchesCurrentFilter(Map<String, dynamic> point) {
    final category = (point['category'] ?? '').toString().toLowerCase();
    final q = _searchController.text.trim().toLowerCase();

    final matchesQuery =
        q.isEmpty ||
        (point['name'] ?? '').toString().toLowerCase().contains(q) ||
        (point['address'] ?? '').toString().toLowerCase().contains(q) ||
        category.contains(q);

    if (!matchesQuery) return false;

    switch (_selectedFilter) {
      case _MapFilter.all:
        return true;
      case _MapFilter.help:
        return category.contains('hôpital') ||
            category.contains('hopital') ||
            category.contains('pharm') ||
            category.contains('ambass') ||
            category.contains('consul');
      case _MapFilter.sites:
        return category.contains('site') || category.contains('joj');
      case _MapFilter.hotels:
        return category.contains('hôtel') || category.contains('hotel');
      case _MapFilter.restaurants:
        return category.contains('restaurant');
      case _MapFilter.pharmacies:
        return category.contains('pharm');
      case _MapFilter.hospitals:
        return category.contains('hôpital') || category.contains('hopital');
    }
  }

  void _applyLocalFilters() {
    const nearbySheetLimit = 40;
    final filtered = _allPoints.where(_matchesCurrentFilter).toList();
    setState(() {
      _pointsOfInterest = filtered;
      _nearbyListPoints = filtered.take(nearbySheetLimit).toList();
    });
    _syncMapToPoints();
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};
    var index = 0;
    for (final point in _pointsOfInterest) {
      final lat = _toDouble(point['latitude'] ?? point['lat']);
      final lng = _toDouble(
        point['longitude'] ?? point['lng'] ?? point['lon'],
      );
      if (lat == null || lng == null) continue;
      final category = (point['category'] ?? '').toString();
      final name = (point['name'] ?? '').toString().trim();
      final id = (point['id'] ?? index).toString();

      markers.add(
        Marker(
          markerId: MarkerId('poi_$id'),
          position: LatLng(lat, lng),
          infoWindow: name.isEmpty ? InfoWindow.noText : InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            GoogleMapsHelpers.markerHueForCategory(category),
          ),
        ),
      );
      index++;
    }

    final focused = _destination;
    if (focused != null) {
      final label = _destinationName ?? '';
      markers.add(
        Marker(
          markerId: const MarkerId('focused_destination'),
          position: focused,
          infoWindow:
              label.isEmpty ? InfoWindow.noText : InfoWindow(title: label),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildRoutePolylines() {
    if (_routePoints.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: _routePoints,
        color: const Color(0xFF2E8B57),
        width: 5,
      ),
    };
  }

  CameraPosition get _initialCameraPosition {
    final center = _destination ??
        LatLng(
          _currentLat ?? 14.7167,
          _currentLng ?? -17.4677,
        );
    return CameraPosition(
      target: center,
      zoom: _hasDestination ? 16 : 12,
    );
  }

  void _syncMapToPoints() {
    final markers = _buildMapMarkers();
    if (markers.isEmpty) return;
    final first = markers.first.position;
    GoogleMapsHelpers.animateTo(_mapController, first, zoom: 13);
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('ambass') || c.contains('consul')) {
      return Icons.account_balance_rounded;
    }
    if (c.contains('secours') || c.contains('urgence')) {
      return Icons.emergency_rounded;
    }
    if (c.contains('hôpital') || c.contains('hopital')) {
      return Icons.local_hospital_rounded;
    }
    if (c.contains('pharm')) return Icons.local_pharmacy_rounded;
    if (c.contains('hôtel') || c.contains('hotel')) return Icons.hotel_rounded;
    if (c.contains('restaurant')) return Icons.restaurant_rounded;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return Icons.stadium_rounded;
    }
    return Icons.place_rounded;
  }

  Color _colorForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('ambass') || c.contains('consul')) {
      return Colors.indigo;
    }
    if (c.contains('secours') || c.contains('urgence')) {
      return AppTheme.primaryRed;
    }
    if (c.contains('hôpital') || c.contains('hopital')) {
      return AppTheme.primaryRed;
    }
    if (c.contains('pharm')) return Colors.blue;
    if (c.contains('hôtel') || c.contains('hotel')) return Colors.purple;
    if (c.contains('restaurant')) return Colors.orange;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return AppTheme.primaryGreen;
    }
    return AppTheme.textSecondary;
  }

  String _distanceLabelForPoint(Map<String, dynamic> point, String category) {
    final rawDistance = (point['distance'] ?? '').toString().trim();
    if (rawDistance.isNotEmpty && rawDistance.toLowerCase() != 'n/a') {
      return rawDistance;
    }

    final rawMeters = point['distance_meters'];
    final meters = rawMeters is num
        ? rawMeters.toDouble()
        : double.tryParse((rawMeters ?? '').toString());
    if (meters != null && meters >= 0) {
      if (meters < 1000) return '${meters.round()} m';
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }

    final lat = _toDouble(point['latitude'] ?? point['lat']);
    final lng = _toDouble(point['longitude'] ?? point['lng'] ?? point['lon']);
    if (lat != null && lng != null) {
      final originLat = _currentLat ?? _fallbackLat;
      final originLng = _currentLng ?? _fallbackLng;
      final computed = LocationService().calculateDistance(
        originLat,
        originLng,
        lat,
        lng,
      );
      if (computed < 1000) return '${computed.round()} m';
      return '${(computed / 1000).toStringAsFixed(1)} km';
    }

    if (category.isNotEmpty) return category;
    return 'Coordonnees manquantes';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: Stack(
          children: [
            // Google Maps
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (controller) => _mapController = controller,
                markers: _buildMapMarkers(),
                polylines: _buildRoutePolylines(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
            // HUD de navigation affiché en haut quand la navigation est active
            if (_isNavigating)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildNavHud(),
              ),
            if (!_isNavigating)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => _applyLocalFilters(),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: l10n.mapPlaceholderSubtitle,
                                hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              style: GoogleFonts.poppins(
                                color: AppTheme.textPrimary,
                                fontSize: 12,
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
            if (!_isNavigating)
            Positioned(
              top: 68,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(_MapFilter.all, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.help, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.sites, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.hotels, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.restaurants, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.pharmacies, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.hospitals, l10n),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 110,
              left: 16,
              right: 100,
              child: const MapLegendStrip.mapHint(),
            ),
            Positioned(
              right: 16,
              bottom: 250,
              child: FloatingActionButton.small(
                heroTag: 'map_locate',
                backgroundColor: Colors.white,
                onPressed: _centerOnCurrentLocation,
                child: Icon(
                  Icons.my_location_rounded,
                  color: _isLocating ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
            ),
            // Panneau itinéraire — visible uniquement quand on arrive depuis un lieu ciblé.
            if (_hasDestination)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildDestinationPanel(context),
              ),
            if (!_hasDestination)
            DraggableScrollableSheet(
              initialChildSize: 0.30,
              minChildSize: 0.20,
              maxChildSize: 0.78,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.mapNearbyPointsTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _isLoadingPoints
                            ? const TerangaBrandedLoading(
                                dense: true,
                                skeletonItemCount: 5,
                              )
                            : _pointsErrorMessage != null
                            ? Center(
                                child: Text(
                                  _pointsErrorMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : _nearbyListPoints.isEmpty
                            ? Center(
                                child: Text(
                                  l10n.mapNoPoints,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: _nearbyListPoints.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  return _buildPointOfInterestFromData(
                                    _nearbyListPoints[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _focusPointOnMap(Map<String, dynamic> point) {
    final name = (point['name'] ?? '').toString().trim();
    final lat = point['latitude'] ?? point['lat'];
    final lng = point['longitude'] ?? point['lng'] ?? point['lon'];
    final latitude = lat is num ? lat.toDouble() : double.tryParse('$lat');
    final longitude = lng is num ? lng.toDouble() : double.tryParse('$lng');

    if (latitude == null || longitude == null) {
      _openPlaceDetail(point);
      return;
    }

    final target = LatLng(latitude, longitude);
    if (_isNavigating) {
      _stopNavigation();
    }
    setState(() {
      _selectedDestination = target;
      _selectedPlaceName = name.isEmpty ? null : name;
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
      _routeError = null;
    });

    GoogleMapsHelpers.animateTo(_mapController, target, zoom: 15);
    _calculateRoute();
  }

  void _openPlaceDetail(Map<String, dynamic> point) {
    final category = (point['category'] ?? '').toString().trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(
          point: point,
          color: _colorForCategory(category),
          icon: _iconForCategory(category),
        ),
      ),
    );
  }

  void _dismissDestination() {
    if (widget.initialLatLng != null) {
      Navigator.maybePop(context);
      return;
    }
    if (_isNavigating) {
      _stopNavigation();
    }
    setState(() {
      _selectedDestination = null;
      _selectedPlaceName = null;
      _routePoints = [];
      _routeDistance = null;
      _routeDuration = null;
      _routeError = null;
    });
  }

  Widget _buildDestinationPanel(BuildContext context) {
    final name = _destinationName ?? '';

    // Pendant la navigation : pas de second « Démarrer », uniquement arrêter.
    if (_isNavigating) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_navIcon, color: const Color(0xFF2E8B57), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigation en cours',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF1A1F2E),
                        ),
                      ),
                      if (_navRemainingDistance != null)
                        Text(
                          'Reste $_navRemainingDistance',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _dismissDestination,
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                  tooltip: 'Fermer',
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _stopNavigation,
                icon: const Icon(Icons.stop_rounded, size: 20),
                label: const Text('Arrêter la navigation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryRed,
                  side: const BorderSide(color: AppTheme.primaryRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE07B39).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFE07B39),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Destination' : name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF1A1F2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_routeDistance != null && _routeDuration != null)
                      Text(
                        '$_routeDistance · $_routeDuration en voiture',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _dismissDestination,
                icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                tooltip: 'Fermer',
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_routeError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _routeError!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _isLoadingRoute || _isNavigating ? null : _calculateRoute,
                  icon: _isLoadingRoute
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.alt_route_rounded, size: 18),
                  label: Text(
                    _routePoints.isNotEmpty ? 'Recalculer' : 'Voir l\'itinéraire',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E8B57),
                    side: const BorderSide(color: Color(0xFF2E8B57)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoadingRoute || _isNavigating
                      ? null
                      : () async {
                          if (_routePoints.isEmpty) {
                            await _calculateRoute();
                          }
                          if (mounted && _routePoints.isNotEmpty) {
                            _startInAppNavigation();
                          }
                        },
                  icon: _isLoadingRoute
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text('Démarrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavHud() {
    return Container(
      color: const Color(0xFF1A1F2E),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_navIcon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_distanceBeforeManeuver != null)
                          Text(
                            _distanceBeforeManeuver!,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF90EE90),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          _navInstruction ?? 'Navigation…',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _stopNavigation,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              if (_navRemainingDistance != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag_rounded, color: Color(0xFFE07B39), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Distance restante : $_navRemainingDistance',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(_MapFilter filter, AppLocalizations l10n) {
    final isSelected = _selectedFilter == filter;
    final label = switch (filter) {
      _MapFilter.all => l10n.mapFilterAll,
      _MapFilter.help => l10n.mapFilterHelp,
      _MapFilter.sites => l10n.mapFilterSites,
      _MapFilter.hotels => l10n.mapFilterHotels,
      _MapFilter.restaurants => l10n.mapFilterRestaurants,
      _MapFilter.pharmacies => l10n.mapFilterPharmacies,
      _MapFilter.hospitals => l10n.mapFilterHospitals,
    };

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
        _applyLocalFilters();
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1A1F2E),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF1A1F2E)
            : Colors.grey.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildPointOfInterestFromData(Map<String, dynamic> point) {
    final l10n = AppLocalizations.of(context)!;
    final name = (point['name'] ?? '').toString().trim();
    final category = (point['category'] ?? '').toString().trim();
    final distanceLabel = _distanceLabelForPoint(point, category);
    final phone = (point['phone'] ?? '').toString().trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _focusPointOnMap(point),
        onLongPress: () => _openPlaceDetail(point),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8E1D5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _colorForCategory(category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _iconForCategory(category),
                  color: _colorForCategory(category),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? l10n.mapDefaultPointName : name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1A1F2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distanceLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (phone.isNotEmpty)
                IconButton(
                  onPressed: () => _callPhone(phone),
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  color: AppTheme.primaryGreen,
                  tooltip: l10n.call,
                )
              else
                Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      final ok = await launchUrl(uri);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.openPhoneError, style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.openPhoneError, style: GoogleFonts.poppins()),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
    });
    try {
      final locationService = LocationService();
      final pos = await locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      });
      GoogleMapsHelpers.animateTo(
        _mapController,
        LatLng(pos.latitude, pos.longitude),
        zoom: 14,
      );
      _loadPointsOfInterest();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mapPositionUpdated, style: GoogleFonts.poppins()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.mapCannotGetPosition,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

}
