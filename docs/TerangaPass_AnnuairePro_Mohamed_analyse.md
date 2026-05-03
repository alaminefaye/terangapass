# Analyse — Annuaire professionnel Sénégal (document Mohamed)

**Référence** : `TerangaPass_AnnuairePro_Mohamed.pdf` (UTA-TP-DB-2026-V1, 2 mai 2026).  
**Destinataire** : Mohamed (lead mobile).  
**Objectif document** : cahier des charges **base de données** et **sources** pour les listes professionnelles TerangaPass, avec volumes, monétisation et phasage.

## 1. Synthèse exécutive

Le PDF définit **12 catégories** d’annuaire national (banques, notaires, avocats, santé, pharmacies, hôtels, restaurants, stations, administrations, éducation, médias & culture, services pros + volet religion/spiritualité). Il fixe une **stratégie d’intégration progressive** : la **bêta lundi** ne porte que **5 catégories** — banques, pharmacies, stations-service, restaurants, hôtels — cible **~500 lieux Dakar** ; le reste est planifié en sprints 2–4 puis production JOJ (**15 000+** entrées).

Le document évoque une table **`places`** et une table dédiée **`banks`** avec champs riches (SWIFT, frais ATM, agrégation PI-SPI, etc.). **Dans le dépôt actuel**, la proximité V1 s’appuie sur la table **`partners`** + enum `category` (dont `bank`, `gas_station`, `shop`, `hotel`, `restaurant`, `pharmacy`, etc.) : c’est un **mapping pragmatique** en attendant un modèle `places` / `banks` normalisé.

## 2. Les 12 catégories (rappel)

| # | Catégorie | Volume indicatif (doc) | Sources / notes (doc) |
|---|-----------|-------------------------|------------------------|
| 1 | Banques & EF | 28 banques agréées + EFCB + microfinances + mobile money + bureaux de change + ATM | BCEAO, sites banques, app PI-SPI |
| 2 | Notaires | ~120 | Chambre des Notaires (notaires.sn) |
| 3 | Avocats | ~1 200 (Dakar) | Ordre des avocats (barreaudakar.sn), huissiers, médiateurs |
| 4 | Hôpitaux, cliniques & médecins | ~5 000 médecins, 80+ cliniques, 30 hôpitaux | Liste hôpitaux/cliniques dans le PDF |
| 5 | Pharmacies | ~1 500 | Gardes, officiel |
| 6 | Hôtels | ~400 Sénégal | |
| 7 | Restaurants | ~250 SiraResto + ~1 000 autres | |
| 8 | Stations-service | ~600 | Partenariats hydrocarbures, prix carburant |
| 9 | Administrations | Régions, départements, mairies, police, impôts, CSS, IPRES, ambassades… | Gratuit utilisateur ; sponsoring institutionnel |
| 10 | Éducation | 30 universités, 11 000+ écoles | UCAD, UGB, grandes écoles privées, ONFP… |
| 11 | Médias & culture | TV, radios, presse, théâtres, musées, événements | RTS, Walf, Dak’Art, JOJ 2026… |
| 12 | Services pros | Artisans, agences, BTP, religion (mosquées, églises, confréries…) | Forte spécificité locale |

## 3. Synthèse revenus (document)

Tableau cumulé **Y1** fourni dans le PDF : fourchette **~540 M à ~1,25 Md FCFA** pour l’annuaire seul (ordre de grandeur business ; dépend des partenariats réels).

## 4. Phasage (document)

| Phase | Période | Contenu |
|--------|---------|---------|
| Bêta lundi | Semaine en cours | 5 catégories : banques, pharmacies, stations, restos, hôtels — ~500 lieux Dakar |
| Sprint 2 | +1 semaine | Médecins/hôpitaux, notaires, avocats — ~1 500 entrées |
| Sprint 3 | +2 semaines | Admin, écoles, médias — ~2 500 entrées |
| Sprint 4 | +1 mois | Services pros + religion — ~5 000 entrées |
| Production JOJ | | Toutes catégories — 15 000+ |

## 5. Implémentation dans ce dépôt (état au livrable)

| Élément | Statut |
|---------|--------|
| **MD présent** | Ce fichier. |
| **Données banques BCEAO (28)** | Seeder `DirectoryBanksBceaoSeeder` : crée/met à jour des **`partners`** `category = bank` (coordonnées de démo Dakar pour affichage « À deux pas » ; à remplacer par données réelles / import BCEAO). |
| **5 catégories bêta dans l’app** | Écran **À deux pas** : restos, banques, stations, **hôtels**, pharmacies (+ boutiques). |
| **Sprint 2 annuaire (code)** | Catégories **`notary`**, **`lawyer`**, **`doctor`**, **`clinic`** en base (`partners`), admin + API `/nearby`, chips **À deux pas** (hôpitaux, cliniques, notaires, avocats, médecins). Seeder **`DirectoryAnnuaireSprint2Seeder`** (échantillons Dakar). |
| **Sprint 3 annuaire (code)** | **`government`**, **`school`**, **`university`**, **`media`** : migration, seed **`DirectoryAnnuaireSprint3Seeder`** (mairie, UCAD, RTS, MCN, etc.), admin, API, chips **À deux pas**. |
| **Table `banks` dédiée** | **Non** — champs avancés (frais ATM, SWIFT, `services[]`…) à concevoir en migration V2 si le produit valide le modèle relationnel. |
| **Table `places`** | **Non** — même remarque ; `partners` sert de véhicule d’intégration rapide. |
| **Collecte terrain** (Catherine, El Gamou, Codou) | Processus humain — hors code. |

## 6. Risques & recommandations

- **Données officielles** : droits d’usage des listes (notaires, barreau) — accords / lettres de partenariat mentionnés dans le PDF.
- **Coordonnées** : ne pas publier en production des positions **fictives** ; le seeder est pour **démo / dev**.
- **Religion & spiritualité** : catégorie sensible — produit, légal et communautés à cadrer avant intégration (Sprint 4).

## 7. Références fichiers

- Seeder : `DirectoryBanksBceaoSeeder`, `DirectoryAnnuaireSprint2Seeder`, `DirectoryAnnuaireSprint3Seeder`  
- Enregistrement : `database/seeders/DatabaseSeeder.php`  
- Migrations catégories : `2026_05_04_160000_add_annuaire_categories_notary_lawyer_doctor_clinic.php`, `2026_05_05_120000_add_annuaire_sprint3_government_school_university_media.php`  
- Proximité API : `app/Http/Controllers/Api/NearbyController.php`  
- App : `terangapassapp/lib/screens/nearby_screen.dart`  

Document connexe : `docs/TerangaPass_SprintBeta_Lundi_analyse.md` (périmètre bêta technique global).

---

*Document d’analyse aligné sur le PDF Annuaire Pro ; à faire évoluer au fil des sprints d’import données.*
