# Teranga Pass — Étape 7 — Mode offline « pack Dakar »

**Référence plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — section « Étape 7 ».

## Socle livré

- **API** : `GET /api/v1/utility/offline-manifest` (sans authentification) renvoie un manifeste JSON :
  - `schema_version` : version du format (entier, actuellement `1`).
  - `pack_version` : chaîne configurable via `TERANGA_OFFLINE_CATALOG_VERSION` (défaut dans `config/terangapass.php`).
  - `generated_at` : horodatage ISO génération côté serveur.
  - `min_app_semver` : réservé pour exiger une version minimale de l’app (nullable).
  - **`bundles`** : une entrée par lot avec `url` absolue, `sha256`, `byte_size` (calculés côté serveur à chaque requête manifeste). Identifiants : `poi`, `competition_sites`, `embassies`, `competition_calendar`, `audio_announcements`.

- **Téléchargement public** (même contenu que les routes métier, sans auth) :
  - `GET /api/v1/utility/offline-bundle/poi`
  - `GET /api/v1/utility/offline-bundle/competition-sites`
  - `GET /api/v1/utility/offline-bundle/embassies`
  - `GET /api/v1/utility/offline-bundle/competition-calendar`
  - `GET /api/v1/utility/offline-bundle/audio-announcements`

- **App** : `OfflinePackService` enregistre le manifeste puis **télécharge les JSON** vers `Documents/offline_packs/` lorsque `pack_version` change (vérification **SHA-256**). L’**accueil** lance `refreshIfStale` (max 1 / 6 h) ; le **profil** force une sync à l’ouverture. Rubrique « Pack hors ligne » affiche la **version de catalogue**, la **version des fichiers locaux** si elle diffère, et un **message** si les fichiers sont plus anciens que le catalogue (invitation à se reconnecter pour terminer la mise à jour).

- **Téléchargement manuel** : dans le dialogue du pack hors ligne, **Télécharger / mettre à jour** lance `downloadPackNow` (barre de progression, lot en cours). Les opérations sont **sérialisées** ; une **reprise** est possible : chaque fichier local dont le **SHA-256** correspond au manifeste est **sauté** (pas de re-téléchargement).

- **Stockage** : le profil affiche une ligne **Stockage local** (somme des `offline_packs/*.json`, en Mo / MB selon la langue).

- **Retry (HTTP)** : chaque lot est retéléchargé au plus **3 fois** si l’échec est considéré comme transitoire (timeouts, coupure, **5xx**, **408**, **429**). Échec de **SHA-256** : pas de retry (données incorrectes).

- **Après téléchargement automatique** (hors dialogue) : un snackbar sur l’accueil indique que le pack « X » a été enregistré (`maybeShowPackUpdatedToast`). Un téléchargement depuis le profil affiche un retour dans le **dialogue** / snackbar dédiés, sans dupliquer ce toast sur l’accueil.

> **Note déploiement** : les URLs des bundles utilisent `APP_URL`. L’appareil doit pouvoir joindre ce même hôte que dans `ApiConstants` (dev : IP locale / émulateur).

## Lecture hors ligne (UX)

- **Accueil** (annonce officielle), **embassades**, **annonces audio**, **INFOS JOJ** (calendrier) : repli sur les fichiers `offline_packs/*.json` si l’API échoue, avec snackbar « données en cache » quand c’est le cas.

## Suite (backlog)

1. **Paiements** : hors périmètre étape 7 (étape 5).

## Variables

Voir `.env.example` : `TERANGA_OFFLINE_CATALOG_VERSION`.
