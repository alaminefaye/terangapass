# Teranga Pass — Carte in-app (étape 4) — choix techniques

**Référence plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — section « Étape 4 ».  
**Dernière mise à jour** : 7 mai 2026.

## Décision de stack

- **Moteur** : `flutter_map`.
- **Tuiles** : OpenStreetMap via le modèle d’URL défini dans `MapConstants.osmTileUrlTemplate` (serveur public OSM standard).
- **User-Agent** : identifiant cohérent sur toutes les couches tuiles (`MapConstants.tileUserAgentPackageName`), conformément aux bonnes pratiques demandées par les fournisseurs de tuiles.

## Fichiers concernés

| Écran | Fichier |
|--------|---------|
| Aperçu JOJ (accueil) | `terangapassapp/lib/screens/home_screen.dart` |
| Carte globale | `terangapassapp/lib/screens/map_screen.dart` |
| Proximité | `terangapassapp/lib/screens/nearby_screen.dart` |
| Constantes | `terangapassapp/lib/constants/map_constants.dart` |
| Tuiles OSM (widget partagé) | `terangapassapp/lib/widgets/teranga_osm_tile_layer.dart` |

## Comportement commun

- **Une seule source** pour URL tuiles, user-agent, et image de repli en cas d’échec de chargement : widget partagé `TerangaOsmTileLayer` (accueil JOJ, carte globale, proximité) qui configure `TileLayer` avec `errorImage` et `errorTileCallback`.
- **Message utilisateur** : en cas d’échec de chargement d’une tuile (réseau, timeout, HTTP), un snackbar est affiché au plus une fois toutes les 30 s (`mapTilesLoadIssue` / l10n), en complément de la tuile grise de repli.
- **`RepaintBoundary`** autour de `FlutterMap` pour limiter les repaints coûteux lorsque le reste de l’écran se reconstruit.
- **Zoom initial** : volontairement différent selon l’usage — carte globale / JOJ vers **12**, liste proximité centrée utilisateur vers **13** (vue plus serrée).

## Tuiles OSM et réseau

- En cas d’indisponibilité ou timeout, l’utilisateur voit une tuile de repli uniforme au lieu d’un fond cassé.
- Respecter la [politique d’usage des tuiles OSM](https://operations.osmfoundation.org/policies/tiles/) : pas de surcharge, user-agent identifiable, considérer à terme un hébergeur de tuiles ou un cache si le trafic augmente (piste étape 4.5 / offline).

## QA recommandée (checklist rapide)

1. **Accueil (aperçu JOJ)** : carte visible, marqueurs sites ; pas de freeze au scroll de la page.
2. **Carte interactive** : filtres, recentrage GPS si applicable ; tuiles qui se chargent en 4G / Wi‑Fi.
3. **Proximité** : carte + liste ; position utilisateur cohérente.
4. **Réseau** : couper données / Wi‑Fi → fond tuiles en repli + snack « connexion » (au plus une fois / 30 s par écran) ; rétablir le réseau → rechargement correct.
5. **Stabilité** : aucune exception rouge en console sur ces parcours.

À cocher après essai sur **au moins un appareil Android et un iOS** si possible.
