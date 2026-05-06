import 'package:flutter/foundation.dart';

/// Etat global minimal pour piloter des éléments d'UI transverses
/// (ex: affichage du bouton SOS uniquement après authentification).
final ValueNotifier<bool> isAuthenticatedNotifier = ValueNotifier<bool>(false);
