# Teranga Pass — Plan d’action étape par étape

**Objectif** : enchaîner les sujets **sans tout mélanger** : produit technique d’abord, puis monétisation lourde, puis « super-app », avec le **institutionnel en parallèle** dès que possible.

**Lien stratégie / inspiration** : [TerangaPass_Inspirations_Strategie.md](TerangaPass_Inspirations_Strategie.md)

**Dernière mise à jour** : 7 mai 2026.

---

## Comment utiliser ce document

1. Valider **une étape à la fois** (revue courte + décision go / no-go).
2. Ne pas commencer une étape **N+1** si la **N** n’a pas ses critères « terminé » cochés — **sauf** saut explicite ci-dessous pour l’étape 5.
3. Les étapes **A** (institutionnel) peuvent avancer **en parallèle** des étapes techniques : elles ne bloquent pas le code, sauf contrainte légale explicite.
4. **Saut de l’étape 5 (paiements in-app)** : si le cadre juridique / partenaire PSP n’est pas prêt, **reporter** l’étape 5 et enchaîner avec l’**étape 6** (billetterie / QR), dans un périmètre **sans encaissement in-app** (pilote gratuit, invitations, paiement géré hors app). Revenir à l’étape 5 dès qu’un flux Wave / Orange Money / autre PSP doit vivre **dans** l’application.

---

## Étape 0 — Cadrage (quelques jours)

| Action | Détail |
|--------|--------|
| Prioriser les **3 objectifs** pour les JOJ | Ex. : sécurité + tourisme + info officielle |
| Liste des **risques** | Données perso, paiement, carte, disponibilité API |
| **Un** responsable produit / arbitrage | Qui tranche les conflits de périmètre |

**Terminé quand** : une page (Notion / PDF / issue GitHub) résume périmètre JOJ + hors-périmètre explicite.

---

## Étape 1 — Socle produit « utile le jour J » (technique)

**But** : ce qui doit marcher pour un visiteur / résident sans payer encore dans l’app.

| Sous-étape | Livrable |
|------------|----------|
| 1.1 | Comptes, auth API, profil, **blocage admin** cohérent |
| 1.2 | **Tourisme & proximité** : données chargées, erreurs gérées, perf GPS raisonnable |
| 1.3 | **Alertes / signalements** : création + historique + suivi si prévu |
| 1.4 | **Notifications** (liste + lecture) + push si déjà branché |
| 1.5 | **Admin** : utilisateurs mobiles, partenaires, contenus critiques à jour |

**Terminé quand** : scénario de démo **15 minutes** sans crash + checklist QA cochée.

---

## Étape 2 — Qualité & confiance (court terme)

| Sous-étape | Livrable |
|------------|----------|
| 2.1 | **Tests** manuels documentés (ou tests auto sur parties critiques) |
| 2.2 | **Journalisation** erreurs API / timeouts côté app (message utilisateur clair) |
| 2.3 | **Sécurité** : HTTPS partout, pas de secrets dans le repo, revue tokens |
| 2.4 | **Accessibilité** de base (tailles de texte, contrastes sur écrans clés) |

**Terminé quand** : une passe « bêta utilisateurs » avec retours traités ou backlog priorisé.

---

## Étape 3 — Données & contenu (en continu)

| Sous-étape | Livrable |
|------------|----------|
| 3.1 | **Qualité annuaire** (partenaires, catégories, coordonnées) |
| 3.2 | **Process** de mise à jour (qui saisit l’admin, fréquence) |
| 3.3 | **Images / médias** optimisés (poids, CDN ou cache si besoin) |

**Terminé quand** : indicateur interne (ex. % fiches complètes, taux d’erreur API) défini et suivi.

---

## Étape 4 — Carte in-app « pro » (moyen terme)

**Décision** : conserver la **carte actuelle** du projet — **`flutter_map`** + tuiles **OpenStreetMap** (`tile.openstreetmap.org`). Pas de changement de SDK (Mapbox, Google Maps natif, HERE) dans le cadre de cette étape ; les autres options restent documentées à titre **d’information** dans [TerangaPass_Inspirations_Strategie.md](TerangaPass_Inspirations_Strategie.md) pour un éventuel arbitrage ultérieur.

**But** : même stack, mais **plus fluide**, plus **cohérente** (une seule config tuiles / user-agent), branding Teranga Pass sur les cartes, puis option **hors ligne** en sous-étape ultérieure.

Constantes partagées côté app : `terangapassapp/lib/constants/map_constants.dart` (`MapConstants.osmTileUrlTemplate`, `MapConstants.tileUserAgentPackageName`).

**Note de synthèse (choix UX / technique)** : [TerangaPass_Etape4_Carte_Choix.md](TerangaPass_Etape4_Carte_Choix.md).

| Sous-étape | Livrable | Statut (mai 2026) |
|------------|----------|-------------------|
| 4.1 | **Base unifiée** : `MapConstants` utilisé partout (`HomeScreen` aperçu JOJ, `MapScreen`, `NearbyScreen`) — éviter URLs / user-agent dupliqués ou divergents | OK côté code |
| 4.2 | **UX carte** : zoom par défaut, marqueurs, légende / contrôles homogènes entre écrans | Zoom et tuiles alignés ; **légende** `MapLegendStrip` sur **accueil JOJ** (sites), **Carte** (filtres) et **À deux pas** (vous / lieu / partenaire) |
| 4.3 | **Perf** : limiter les rebuilds lourds, éviter rechargements tuiles inutiles, tester sur appareil faible | `RepaintBoundary` sur les trois cartes ; **test dispositif réel** encore recommandé |
| 4.4 | **Tuiles / réseau** : message clair si les tuiles OSM sont indisponibles (timeout) ; pas d’abus des serveurs publics OSM | `TerangaOsmTileLayer` : `errorImage` + snack throttlé sur erreur tuile + user-agent unifié ; [politique tuiles OSM](https://operations.osmfoundation.org/policies/tiles/) |
| 4.5 | **Offline (optionnel, plus tard)** : cache ou pack tuiles — seulement après stabilisation du flux en ligne | Non démarré |

**Terminé quand** : les trois parcours carte (accueil JOJ, carte globale, proximité) partagent la même config de base, **comportement validé sur Android + iOS** (checklist QA terrain), et la note [TerangaPass_Etape4_Carte_Choix.md](TerangaPass_Etape4_Carte_Choix.md) à jour.

---

## Étape 5 — Paiements in-app (Wave / Orange Money, etc.)

**Statut** : peut être **mise en pause** — le produit peut avancer sur l’**étape 6** sans avoir bouclé celle-ci (voir règle 4 en tête de document).

**Attention** : étape **juridique + technique** — ne pas coder le wallet avant le cadre.

**Avant de coder** : lire la fiche [TerangaPass_Etape5_Paiements_Prerequis.md](TerangaPass_Etape5_Paiements_Prerequis.md) (cadre, intégration, sécurité).

| Sous-étape | Livrable |
|------------|----------|
| 5.1 | **Veille réglementaire** (agrément PSP, KYC, partenaires) |
| 5.2 | **Choix intégration** (SDK marchand, deep link, partenaire agréé) |
| 5.3 | **Premier flux** : un seul cas (ex. don / billet test / réservation pilote) |
| 5.4 | **Commissions** : règles affichées à l’utilisateur + contrat marchands |

**Terminé quand** : un paiement réel **pilote** validé en conditions sécurisées.

---

## Étape 6 — Billetterie & Pass (QR, multi-services)

**Prochain chantier recommandé** si l’**étape 5 est reportée** : modèle QR, délivrance d’au moins un type de billet / pass, sans obligation d’intégration PSP dans l’app tant que l’encaissement reste externe ou le pilote est gratuit.

| Sous-étape | Livrable | Statut (mai 2026) |
|------------|----------|-------------------|
| 6.1 | Modèle **anti-fraude** (QR signé, horodatage, révocation) | **MVP** : format `TPASS1` + HMAC + table `pass_tickets` ; révocation possible côté données ([note technique](TerangaPass_Etape6_Pass_QR.md)) |
| 6.2 | Intégration **un** type de billet (JOJ ou musée pilote) | **MVP** : type `joj_visitor_pilot` + écran QR + `GET /api/v1/pass/ticket` |
| 6.3 | Scénarios **offline** de contrôle (si applicable) | **Partiel** : `GET /api/v1/pass/revocations` (+ `since`) pour synchro des révocations côté staff ; validation QR toujours en ligne (`POST /api/v1/pass/validate`) |

**Terminé quand** : documentation opérateur + tests de charge légers sur la validation.

**Documentation** : [TerangaPass_Etape6_Pass_QR.md](TerangaPass_Etape6_Pass_QR.md).

---

## Étape 7 — Mode offline « pack Dakar »

| Sous-étape | Livrable |
|------------|----------|
| 7.1 | Liste des **données** à embarquer (POI, cartes, annonces d’urgence) |
| 7.2 | Téléchargement **1 clic** + gestion stockage / mise à jour |
| 7.3 | Comportement si données **périmées** |

**Terminé quand** : test terrain sans réseau sur parcours défini.

---

## Étape 8 — « Super-app » (long terme, découpé)

Ne démarrer qu’avec des **micro-livrables** :

| Sous-étape | Exemple de livrable |
|------------|---------------------|
| 8.1 | **Itinéraires** : un mode transport à la fois |
| 8.2 | **Fidélité** : points sur une seule action (ex. visite partenaire) |
| 8.3 | **IA** : Wolof + FR sur un domaine restreint (FAQ) avant tout-chat |
| 8.4 | **AR** : un seul POI pilote |

**Terminé quand** : chaque sous-étape a son propre critère « done » (pas de gros bloc monolithique).

---

## Fil A — Institutionnel & financements (en parallèle)

À lancer **dès l’étape 1** sans attendre le code final.

| Sous-étape | Livrable |
|------------|----------|
| A.1 | **One-pager** + pitch 3 minutes (dérivé du doc inspiration) |
| A.2 | **Liste de rendez-vous** : ASPT, Ville de Dakar, Tourisme, APIX (ordre à adapter) |
| A.3 | **Note de subvention** ciblée (une institution à la fois) : problème, solution, budget, KPI, calendrier |
| A.4 | **Dossier partenaires** (logos, co-branding, mentions légales) |

**Terminé quand** : au moins un **premier entretien** ou une **réponse écrite** avec suite identifiée.

---

## Synthèse visuelle (ordre recommandé)

```text
0 Cadrage
    ↓
1 Socle produit JOJ          │  A Institutionnel (parallèle)
    ↓                        │
2 Qualité & confiance        │
    ↓                        │
3 Données & contenu ─────────┤
    ↓                        │
4 Carte pro                  │
    ↓                        │
5 Paiements in-app           │  ← peut être sauté (report juridique / PSP) ;
    ↓                        │    passer alors directement au 6 (QR sans caisse in-app).
6 Billetterie / Pass QR      │
    ↓                        │
7 Offline « pack Dakar »       │
    ↓                        │
8 Super-app (par morceaux)   │
```

---

## Liens dans le dépôt

| Document | Rôle |
|----------|------|
| [TerangaPass_Inspirations_Strategie.md](TerangaPass_Inspirations_Strategie.md) | Pourquoi / qui / quelles pistes |
| [TerangaPass_Etape4_Carte_Choix.md](TerangaPass_Etape4_Carte_Choix.md) | Décisions carte in-app (`flutter_map`, OSM, UX réseau) |
| [TerangaPass_Etape5_Paiements_Prerequis.md](TerangaPass_Etape5_Paiements_Prerequis.md) | Cadre avant toute intégration Wave / OM |
| [TerangaPass_Etape6_Pass_QR.md](TerangaPass_Etape6_Pass_QR.md) | Pass QR / billetterie pilote (API + staff) |
| [TerangaPass_Operateur_Pass_Controle.md](TerangaPass_Operateur_Pass_Controle.md) | Opérateur : en-tête contrôle, `validate`, `revocations` |
| [TerangaPass_QA_Demo_15min.md](TerangaPass_QA_Demo_15min.md) | Démo 15 min / QA étape 1 |
| [TerangaPass_Security_Checklist.md](TerangaPass_Security_Checklist.md) | Rappel sécurité (HTTPS, secrets, contrôle Pass) |
| [TerangaPass_Process_Contenu_Annuaire.md](TerangaPass_Process_Contenu_Annuaire.md) | Process contenu / annuaire (étape 3) |
| **Ce fichier** | Par quoi commencer, dans quel ordre, critères de fin |

Entrées README : `README.md` (racine) et `terangapassapp/README.md` pointent vers ce plan, le document d’inspiration et les fiches étapes 4–6.
