# Teranga Pass — Étape 7 — Mode offline « pack Dakar »

**Référence plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — section « Étape 7 ».

## Socle livré

- **API** : `GET /api/v1/utility/offline-manifest` (sans authentification) renvoie un manifeste JSON :
  - `schema_version` : version du format (entier, actuellement `1`).
  - `pack_version` : chaîne configurable via `TERANGA_OFFLINE_CATALOG_VERSION` (défaut dans `config/terangapass.php`).
  - `generated_at` : horodatage ISO génération côté serveur.
  - `min_app_semver` : réservé pour exiger une version minimale de l’app (nullable).
  - **`bundles`** : entrées `poi` et `competition_sites` avec `url` absolue, `sha256`, `byte_size` (calculés côté serveur à chaque requête manifeste).

- **Téléchargement public** (même contenu que les routes tourisme / sites, sans auth) :
  - `GET /api/v1/utility/offline-bundle/poi`
  - `GET /api/v1/utility/offline-bundle/competition-sites`

- **App** : `OfflinePackService` enregistre le manifeste puis **télécharge les JSON** vers `Documents/offline_packs/` lorsque `pack_version` change (vérification **SHA-256**). L’**accueil** lance `refreshIfStale` (max 1 / 6 h) ; le **profil** force une sync à l’ouverture. Rubrique « Pack hors ligne » affiche la **version de catalogue** (ou « non synchronisé »).

> **Note déploiement** : les URLs des bundles utilisent `APP_URL`. L’appareil doit pouvoir joindre ce même hôte que dans `ApiConstants` (dev : IP locale / émulateur).

## Suite (backlog)

1. **Autres bundles** : annonces audio, ambassades, etc.
2. **UX téléchargement** : barre de progression, reprise après coupure, indicateur « X Mo » dans le profil.
3. **Lecture hors ligne** : carte / listes lisent `offline_packs/*.json` si l’API est injoignable.
4. **Périmé** : invitation explicite à mettre à jour le pack si le manifeste change.

## Variables

Voir `.env.example` : `TERANGA_OFFLINE_CATALOG_VERSION`.
