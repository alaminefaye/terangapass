# Teranga Pass — Inspirations et pistes stratégiques

**Référence** : note produit / partenariats / vision « super-app » (interne).  
**Dernière mise à jour** : 7 mai 2026.

Ce document synthétise des **sources d’inspiration**, des **cibles institutionnelles** et des **pistes techniques** pour faire évoluer Teranga Pass (web + mobile). Il ne constitue pas un engagement contractuel ni une promesse de fonctionnalités livrées telles quelles.

**Plan d’exécution ordonné (étapes techniques + institutionnel)** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md)

---

## 1. Kaspi.kz (Kazakhstan) — modèle « super-app »

**Principe** : une application qui concentre **paiement**, **marketplace**, **billetterie** et **services publics** dans un seul écosystème.

**Monétisation typique** :

- commissions sur les transactions ;
- frais marchands ;
- services financiers (crédit, assurance, etc.) selon cadre légal.

**Application à Teranga Pass** :

- intégration native des moyens de paiement locaux (**Wave**, **Orange Money**, autres agréés) ;
- **billetterie JOJ** et événements ;
- **réservations** (hôtels, restaurants) ;
- **paiements** lieux (musées, taxis, navettes) ;

**Piste de chiffre** : viser une **commission de l’ordre de 2 à 5 %** sur les flux encadrés légalement, avec transparence utilisateur et partenaires.

---

## 2. Partenaires institutionnels et financements (Sénégal et bailleurs)

Pistes à activer en parallèle du développement produit (ordre non strict) :

| Acteur | Angle d’approche |
|--------|-------------------|
| **Ministère du Tourisme** (ex. fonds type **FDSTS**) | App de **promotion de destination**, données tourisme, impact JOJ |
| **ASPT** (Agence sénégalaise de promotion touristique) | **Co-branding** officiel, contenus certifiés, campagnes |
| **APIX** | Startup **stratégique JOJ**, scalabilité, emploi numérique |
| **Ville de Dakar** | Convention type **« Dakar Smart City »** : mobilité, sécurité, inclusion |
| **AFD**, **Banque mondiale**, **BAD** | Programmes **tourisme numérique** Afrique |
| **UE** — Team Europe Sénégal | **Digitalisation** des services publics et tourisme |
| **Expression directe — Présidence** (Vision Sénégal 2050, pilier numérique) | Alignement **nation branding** + JOJ + souveraineté des données |

**Argument clé** : Teranga Pass comme **vitrine numérique officielle** du Sénégal pendant les JOJ et au-delà (sécurité du visiteur, information, mobilité, confiance).

---

## 3. Carte intégrée sans quitter l’app

**Objectif** : navigation et découverte **dans** l’application, sans dépendre d’un navigateur embarqué fragile pour l’usage terrain.

**Options techniques** (à arbitrer selon budget, offline et design) :

| Solution | Atouts principaux |
|----------|-------------------|
| **Mapbox** (SDK) | Design poussé, tuiles custom, **offline** possible, écosystème mature |
| **OpenStreetMap + MapLibre / Leaflet** | **Open source**, contrôle des coûts, personnalisation (couleurs Teranga Pass) |
| **Google Maps SDK** (natif, pas WebView) | Familiarité utilisateur, couverture ; attention quotas et coûts |
| **HERE Maps** | Bonne couverture **Afrique**, navigation **offline** native |

**Recommandation de compromis (note interne, hors périmètre immédiat)** :

- **Mapbox** : bon équilibre design, offline, coût maîtrisé si volumétrie suivie ; ou  
- **MapLibre + tuiles OSM** : privilégier si l’objectif prioritaire est le **coût zéro / maîtrise totale** des tuiles.

**État dans le dépôt (décision étape 4 du plan)** : l’app mobile utilise **OpenStreetMap** via **`flutter_map`** (`HomeScreen`, `MapScreen`, `NearbyScreen`). Le **plan d’exécution** ([TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md), étape 4) prévoit de **consolider cette stack** (constantes partagées `MapConstants`, perf, UX) avant toute migration éventuelle vers une autre technologie.

---

## 4. Pistes produit pour viser le « top »

1. **Mode offline** : pack « Dakar » téléchargeable en un clic (POI, cartes, annonces critiques).
2. **Itinéraires multimodaux** : BRT, TER, taxi, marche — idéalement avec **temps réel** quand les données existent.
3. **QR code « Pass » unique** : billet JOJ + transport + musées (identité et anti-fraude à cadrer).
4. **Wallet intégré** (Wave / OM) : paiements in-app sous réglementation **PSP / agrément**.
5. **Notifications push géolocalisées** : proximité site JOJ, événement, sécurité (opt-in strict).
6. **Réalité augmentée** sur sites emblématiques (Gorée, Monument de la Renaissance, etc.) — POC puis déploiement ciblé.
7. **Chatbot multilingue** : **Wolof**, **français**, **anglais** / **arabe** selon maturité — le bouton IA central existant peut servir de point d’entrée.
8. **Programme fidélité** : points par visite, scan, signalement utile — échange chez **partenaires** (réductions).

Chaque item doit passer par une phase **cadrage légal + RGPD + accessibilité** avant industrialisation.

---

## 5. Pitch institutionnel (brouillon)

> Teranga Pass : la **super-app** de référence pour le Sénégal — **sécurité**, **tourisme**, **mobilité** et **paiement**. Inspirée de modèles comme **Kaspi** (Kazakhstan) ou **Visit Qatar**, **adaptée** au contexte sénégalais (moyens de paiement locaux, langues, institutions). Objectif : **monétisation** par commissions et sponsoring, **réduction** de la dépendance à un financement public pur, tout en restant alignée avec les **priorités nationales** (JOJ, tourisme, numérique).

À adapter à chaque interlocuteur (durée d’intervention, chiffres, preuves de traction).

---

## 6. Suite possible : note de demande de subvention

Une **note ciblée** (Ministère du Tourisme, ASPT ou Ville de Dakar) devrait reprendre :

- problème public / opportunité mesurable ;
- solution Teranga Pass (2 pages max) ;
- budget, calendrier, indicateurs d’impact (KPI) ;
- co-financement et contreparties (open data limitée, transparence, formation).

**Ce document ne remplace pas** cette note : il en constitue la **matière première** stratégique.

---

## 7. Liens utiles dans le dépôt

- **Plan étape par étape** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md)
- Cahiers et analyses existants : répertoire `docs/` (sprints, annuaire, Wi-Fi, etc.).
- Application mobile : `terangapassapp/`.
- API et administration : racine Laravel (`routes/api.php`, `routes/web.php`).

Pour toute évolution majeure (carte, wallet, offline), créer une **issue ou un fichier d’ADR** dédié afin de tracer les arbitrages techniques et juridiques.
