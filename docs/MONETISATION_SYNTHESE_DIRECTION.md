# Teranga Pass — Synthèse monétisation (direction)

**Document pour la direction** — mai 2026  
**Application** : Teranga Pass (mobile + tableau de bord web)  
**Périmètre** : Jeux Olympiques de la Jeunesse (JOJ), tourisme au Sénégal, sécurité du visiteur

> Guide technique détaillé : [MONETISATION_TERANGA_PASS.md](MONETISATION_TERANGA_PASS.md)

---

## 1. Message en une minute

Teranga Pass est **déjà une application riche et utilisable**. On peut **commencer à générer des revenus sans attendre un an de développement**, en vendant surtout :

1. **La visibilité aux entreprises locales** (restaurants, hôtels, banques, pharmacies…) dans notre annuaire.
2. **Des contrats avec des institutions** (tourisme, ville, organisateurs JOJ, hôtels) pour la sécurité et la communication.
3. **La billetterie numérique** (QR Pass), une fois le paiement mobile branché.

**Ce qui n’existe pas encore** : paiement Wave / Orange Money **dans l’application**, vente d’eSIM, abonnement payant pour le grand public. Ce sont des chantiers planifiés, pas du « déjà en ligne ».

---

## 2. Tableau : qu’est-ce qu’on peut monétiser ?

| # | Offre | Déjà dans l’app ? | Peut rapporter de l’argent quand ? | Type de client |
|---|--------|-------------------|-------------------------------------|----------------|
| **A** | **Fiche entreprise dans l’annuaire** (nom, adresse, téléphone, photo, avis) | ✅ Oui — plus de **2 500 lieux** au Sénégal | **Maintenant** (vente commerciale) | Restaurants, hôtels, banques, pharmacies… |
| **B** | **Partenaire « mis en avant »** (badge, priorité dans « À deux pas ») | ✅ Oui — option admin « sponsor » | **Maintenant** (à renforcer sur tous les écrans) | Marques, chaînes, grands comptes |
| **C** | **Campagnes notification / audio** (message officiel ou sponsor) | ✅ Oui — envoi depuis le dashboard | **Maintenant** | Opérateurs, sponsors JOJ, ministères |
| **D** | **Licence sécurité** (SOS, alerte médicale, suivi dashboard) | ✅ Oui — opérationnel | **Maintenant** (B2B / institutionnel) | Hôtels, campus, comité JOJ, assurances |
| **E** | **Billet / Pass QR** (entrée événement, site, musée) | ✅ Technique prête — **gratuit aujourd’hui** | **Dès que le paiement mobile est branché** | Organisateurs, musées, JOJ |
| **F** | **Pack hors ligne** (carte + lieux sans internet) | ✅ Oui — gratuit aujourd’hui | **Après création d’un abonnement « Plus »** | Touristes, diaspora |
| **G** | **Assistant IA** (conseils voyage) | ✅ Oui — illimité aujourd’hui | **Après limite gratuite + offre payante** | Utilisateurs premium |
| **H** | **Transport / navettes** (horaires, infos) | ✅ Oui | **Partenariat opérateurs** (commission ou forfait) | Sociétés de transport |
| **I** | **Paiement dans l’app** (Wave, Orange Money, carte) | ❌ Non — prévu, pas codé | **3 à 6 mois** (partenaire + juridique) | Tous flux transactionnels |
| **J** | **Vente eSIM** (internet touriste) | ❌ Écran « bientôt » seulement | **3 à 6 mois** (contrat type Airalo) | Touristes internationaux |
| **K** | **Subventions & partenariats publics** | ✅ Produit démontrable | **En parallèle** — dossiers ASPT, tourisme, ville, bailleurs | État, collectivités, UE |

---

## 3. Ce qui est déjà prêt à vendre (priorité immédiate)

### A. Annuaire professionnel — **cœur du business court terme**

**Ce que le client achète** : être trouvé par des milliers d’utilisateurs (touristes, athlètes, familles JOJ) sur mobile.

**Contenu livré aujourd’hui** :
- Fiche sur la carte et dans « Tourisme & services »
- Recherche par catégorie (hôtel, resto, banque, pharmacie, etc.)
- Distance par rapport à la position du téléphone
- Possibilité d’avis clients

**Prix indicatif à étudier** :
- Fiche simple : **10 000 – 30 000 FCFA / mois**
- Partenaire mis en avant : **50 000 – 200 000 FCFA / mois**

**Manque pour facturer proprement** : statistiques automatiques (« X personnes ont vu votre fiche »). Le champ existe en base mais n’est pas encore alimenté — **petit développement à prévoir** pour justifier le renouvellement.

---

### B. Partenaire sponsor — **déjà actif partiellement**

**Ce que le client achète** : apparaître **en premier** et avec un badge **« Partenaire »** quand on cherche des lieux à proximité.

**État** : fonctionnel sur l’écran **« À deux pas »** ; à généraliser sur la carte et l’annuaire complet pour un forfait premium crédible.

---

### C. Contrats institutionnels — **revenus B2G / grands comptes**

**Ce que l’acheteur achète** : une **plateforme de confiance** pendant les JOJ et le tourisme.

| Service | Intérêt pour l’institution | Monétisation |
|---------|----------------------------|--------------|
| SOS + alerte médicale + carte ops | Sécurité des visiteurs, image pays | Licence annuelle ou forfait événement |
| Dashboard web (alertes, incidents, stats) | Supervision temps réel | Pack « comité JOJ » ou « ville de Dakar » |
| Notifications push ciblées | Information officielle | Forfait campagne |
| Annonces audio officielles | Communication grand public | Forfait campagne |

**Important** : le **SOS d’urgence reste gratuit pour l’utilisateur** ; on facture l’**organisation** qui déploie le service (hôtel, événement, État).

---

### D. Notifications et visibilité sponsors JOJ

**Exemples** :
- Message push à l’arrivée sur un site JOJ
- Annonce audio sponsor sur l’écran d’accueil

**Modèle** : forfait à la campagne (ex. **500 000 – 2 000 000 FCFA** selon portée et durée).

---

## 4. Ce qui rapportera de l’argent après un chantier court

| Offre | Travail nécessaire | Délai estimé | Potentiel |
|-------|-------------------|--------------|-----------|
| **Pass QR payant** (billet JOJ, musée, concert) | Brancher Wave / Orange Money + lien paiement → billet | 2–4 mois | Élevé pendant JOJ |
| **Abonnement « Teranga Plus »** | Limite gratuite offline + IA ; paiement récurrent | 2–3 mois | Revenu récurrent touristes |
| **Stats annonceurs** (vues, clics appel, itinéraire) | Développement léger + rapport PDF admin | 2–4 semaines | Indispensable pour vendre A et B |
| **Portail « modifier ma fiche »** pour commerçants | Espace web partenaire | 2–3 mois | Réduit la charge admin, scale commercial |

---

## 5. Ce qui n’est pas encore possible (à ne pas promettre au client)

| Promesse à éviter aujourd’hui | Réalité |
|------------------------------|---------|
| « Payez votre billet dans l’app avec Wave » | Paiement **non intégré** — étape projet documentée, pas livrée |
| « Achetez votre eSIM ici » | Écran **placeholder** seulement |
| « Abonnement premium déjà actif » | Pas de gestion d’abonnement en base |
| « Nous garantissons X vues par mois » | Compteur de vues **pas encore fiable** |

---

## 6. Ordre de priorité recommandé pour la direction

```
┌─────────────────────────────────────────────────────────────┐
│  MAINTENANT (0–3 mois)                                      │
│  • Vendre 10–30 fiches + 3–5 sponsors « mis en avant »      │
│  • 1–2 contrats institution (hôtel, JOJ, tourisme)          │
│  • Activer les statistiques de vues (preuve pour renouveler) │
├─────────────────────────────────────────────────────────────┤
│  MOYEN TERME (3–6 mois)                                     │
│  • Billetterie QR payante                                   │
│  • Abonnement Teranga Plus (offline + IA)                   │
│  • Paiement mobile in-app (Wave / OM / PayDunya)            │
├─────────────────────────────────────────────────────────────┤
│  EN PARALLÈLE (tout le temps)                               │
│  • Subventions, co-branding ASPT / ministère / ville        │
│  • Sponsors événement (Orange, banques, telco)              │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Estimation du potentiel (ordre de grandeur, à affiner)

*Hypothèses conservatrices — pas un engagement financier.*

| Source | Hypothèse | CA annuel indicatif |
|--------|-----------|---------------------|
| 50 fiches pro à 15 000 FCFA/mois | Annuaire | ~9 M FCFA |
| 10 sponsors à 80 000 FCFA/mois | Mise en avant | ~9,6 M FCFA |
| 2 contrats institution à 5 M FCFA/an | SOS / dashboard | ~10 M FCFA |
| 1 grosse campagne JOJ notification | Sponsor | ~2 M FCFA (ponctuel) |
| Billetterie QR (phase 2) | 5 % sur 100k billets à 5 000 F | variable événement |

**Total réaliste année 1 (mix)** : fourchette **15–40 M FCFA** si l’équipe commerciale démarre tout de suite sur l’annuaire + institutionnel, **sans** compter encore eSIM ni super-app.

---

## 8. Arguments pour un partenaire ou un financeur

1. **Produit déjà déployable** — pas une maquette : carte, annuaire national, SOS, JOJ, offline, QR Pass.
2. **Alignement JOJ 2026** — outil de sécurité et d’orientation pour des dizaines de milliers de visiteurs.
3. **Actif data** — base de lieux géolocalisés sur tout le Sénégal (sync Google + admin).
4. **Double modèle** : revenus **commerciaux** (PME) + **institutionnels** (État, sponsors).
5. **Scalable** — même moteur pour d’autres villes ou événements (white-label futur).

---

## 9. Décisions à trancher en réunion direction

| Question | Options |
|----------|---------|
| Le SOS reste-t-il 100 % gratuit pour le citoyen ? | **Recommandé : oui** — monétiser B2B uniquement |
| Quel est le **premier flux payant** in-app ? | Billet QR vs abonnement Plus vs eSIM |
| Quel PSP mobile signer en premier ? | Wave, Orange Money, PayDunya (cf. doc étape 5) |
| Qui porte la **force de vente** annuaire ? | Équipe interne vs agence partenaire |
| Budget **stats + sponsor sur toute l’app** ? | 2–4 semaines dev — ROI commercial direct |

---

## 10. Résumé pour le boss (3 phrases)

1. **On peut monétiser dès maintenant** l’annuaire (fiches pro + partenaires sponsors) et des **contrats institutionnels** (sécurité, notifications, JOJ) — le produit est prêt.  
2. **La billetterie QR, l’eSIM et les paiements in-app** sont les gros leviers suivants, mais il faut **3 à 6 mois** et des accords partenaires (Wave, Airalo, etc.).  
3. **Priorité** : vendre 10–30 clients annuaire, activer les **statistiques de vues**, et lancer **1 pilote Pass QR payant** pendant un événement JOJ.

---

*Document préparé pour présentation direction — Teranga Pass, mai 2026.*
