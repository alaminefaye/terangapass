# Analyse sprint bêta — TerangaPass (document du lundi)

**Référence** : cahier sprint « Bêta lundi » (échéance indicative : démo DG, modules de proximité, eSIM).  
**Date d’analyse** : 3 mai 2026.

## 1. Synthèse du document

Le sprint vise une **application stable** pour une démonstration, avec notamment :

- **Correctifs prioritaires (bugs P0)** : débordements UI, chevauchements SOS / barres, FAB IA, accents et textes tronqués, logo SVG, z-index, hero interactif, tiroir notifications, squelettes de chargement, boutons retour.
- **Découverte « à deux pas »** : rayon typique **2 km**, carte (ex. OSM / `flutter_map`), filtres par **catégories** (restaurants, banques / DAB, stations, boutiques, pharmacies de garde), **mise en avant sponsorisée**, endpoint **`GET /api/v1/nearby`** avec calcul de distance (Haversine), modèle de données (lieux, catégories, listings sponsorisés, avis, etc. selon version du cahier).
- **eSIM** : intégration type **Airalo** (ou équivalent), **forfaits** présentés dans l’app, activation (QR / e-mail), paiements (ex. PayDunya, Wave), grilles tarifaires et aspects commerciaux / conformité.

**Écart stack document vs dépôt** : le PDF mentionne parfois **PostgreSQL** ; le projet Laravel ici utilise **MySQL** — à garder en tête pour les migrations et les requêtes SQL brutes.

## 2. État dans le dépôt (après cette passe)

| Thème | État |
|--------|------|
| Bugs P0 (liste PDF) | Partiellement traités (IA `mounted`, navigation, **SOS vs barre du bas** via réserve verticale dans `main.dart`, **accents** SOS + piliers accueil + feuille d’aide, etc.). QA **bug par bug** encore recommandée. |
| **Proximité** | **Implémenté en V1** : `GET /api/v1/nearby` (Haversine, rayon, filtre catégorie, sponsors en tête) sur la table **`partners`** ; catégories **`bank`**, **`gas_station`**, **`shop`** ajoutées en base ; écran Flutter **« À deux pas »** + entrée depuis **Tourisme**. |
| **eSIM** | **Écran placeholder** + entrée profil ; pas encore d’Airalo / PayDunya / QR en production. |
| Tables dédiées `places` / `sponsored_listings` (nommage PDF) | **Non** — réutilisation de **`partners`** + `is_sponsor` pour limiter la dette avant la bêta ; migration possible ensuite. |

## 3. Plan de complétion recommandé

1. **QA P0** : grille de tests sur appareils réels (petits écrans, iOS/Android), accents FR, retours arrière, SOS.
2. **Proximité V2** : données OSM enrichies ou table `places` si volume / perfs ; endpoint inchangé ou versionné (`/nearby/v2`).
3. **eSIM** : contrat Airalo (ou autre), webhooks, stockage commandes, flux paiement, mentions légales et support client.
4. **Alignement doc** : mettre à jour le cahier interne sur **MySQL** et sur le mapping **partners** ↔ « lieux » pour éviter les malentendus équipe / DG.

## 4. Risques

- **Paiements eSIM** : conformité PCI / partenaires locaux, délais d’homologation.
- **Données proximité** : qualité des coordonnées et catégories ; le `PartnerSeeder` inclut désormais des exemples **bank / gas_station / shop** (réexécuter seeders uniquement sur base de dev si besoin).
- **Charge** : filtrage SQL par distance sur gros volumes → index géographique ou cache si besoin.

## 5. Références techniques (implémentation V1)

- **API** : `routes/api.php` — route `GET /v1/nearby`.
- **Contrôleur** : `App\Http\Controllers\Api\NearbyController`.
- **App mobile** : `terangapassapp/lib/screens/nearby_screen.dart`, `ApiService.getNearby`, navigation depuis `tourism_screen.dart`.
- **eSIM UI** : `terangapassapp/lib/screens/esim_coming_screen.dart`, lien profil.

---

*Document produit pour cadrer le sprint ; à faire évoluer après la démo DG.*
