# Teranga Pass — Étape 7 — Mode offline « pack Dakar »

**Référence plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — section « Étape 7 ».

## Socle livré (v1)

- **API** : `GET /api/v1/utility/offline-manifest` (sans authentification) renvoie un manifeste JSON :
  - `schema_version` : version du format (entier, actuellement `1`).
  - `pack_version` : chaîne configurable via `TERANGA_OFFLINE_CATALOG_VERSION` (défaut dans `config/terangapass.php`).
  - `generated_at` : horodatage ISO génération côté serveur.
  - `min_app_semver` : réservé pour exiger une version minimale de l’app (nullable).
  - `bundles` : liste des artefacts à télécharger (vide au départ ; futurs ZIP / JSON signés).

- **App** : depuis le **profil**, rubrique « Pack hors ligne » affiche le texte produit et la **version de catalogue** après synchronisation réussie avec l’API ; sinon mention « non synchronisé ».
- **Sync** : `OfflinePackService` met en cache le manifeste JSON (`SharedPreferences`) ; l’**accueil** déclenche une sync en arrière-plan au plus une fois toutes les **6 h** (`refreshIfStale`) ; le **profil** force une `refresh` à l’ouverture pour un numéro de catalogue à jour.

## Suite (backlog)

1. **Remplir `bundles`** : `{ "id", "url", "sha256", "byte_size", "kind" }` par type (POI, sites JOJ, annonces audio, etc.).
2. **Téléchargement** : stockage local (`path_provider` / fichier sécurisé), barre de progression, reprise après coupure.
3. **Lecture hors ligne** : adapters des écrans carte / liste pour lire le cache quand l’API est injoignable.
4. **Périmé** : si `pack_version` ou checksum local ≠ manifeste → inviter à mettre à jour le pack.

## Variables

Voir `.env.example` : `TERANGA_OFFLINE_CATALOG_VERSION`.
