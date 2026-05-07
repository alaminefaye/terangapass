# Teranga Pass — Étape 5 paiements — prérequis (cadre avant code)

**Référence plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — section « Étape 5 ».  
**Dernière mise à jour** : 7 mai 2026.

**Report volontaire** : si l’équipe **ne traite pas** les paiements in-app pour l’instant, le chantier suivant est l’**étape 6 — billetterie / QR** (pilote sans encaissement dans l’app). Cette fiche reste la référence **pour plus tard**, quand vous réactiverez Wave / Orange Money / autre dans Teranga Pass.

Cette fiche liste ce qui doit être **clair en amont** avant d’implémenter un flux Wave, Orange Money ou autre moyen local dans l’app. Elle ne remplace pas un avis juridique.

## 1. Juridique et conformité

- Qualification du service Teranga Pass vis-à-vis des **activités de paiement** (intermédiation, encaissement pour compte de tiers, agrément type prestataire de services de paiement selon le cadre applicable au Sénégal et à l’UE si des utilisateurs ou flux le concernent).
- **KYC / AML** : niveau exigé pour le périmètre visé (montants, types d’utilisateurs marchands).
- **Données personnelles** : traitement des numéros de téléphone, historiques de transaction, conservation, droit d’accès (alignement politique de confidentialité et mentions in-app).
- **Contrats** avec les partenaires techniques ou marchands : répartition des responsabilités, incidents, litiges.

## 2. Choix d’intégration technique (à trancher avec les partenaires)

| Piste | Question clé |
|--------|----------------|
| **Lien / deep link** vers l’app du PSP | Qui initie le paiement, comment confirmer le succès côté backend ? |
| **API / SDK marchand** documenté | Environnements sandbox / prod, webhooks, idempotence des paiements. |
| **Passerelle agréée** | Externaliser l’agrément PSP au profit d’un partenaire qui porte la licence. |

Les offres Wave, Orange Money et autres évoluent : la **documentation officielle** et les **contacts partenaires** font foi pour le détail d’intégration.

## 3. Côté produit Teranga Pass

- **Un premier flux unique** (plan 5.3) : par ex. don, billet pilote ou réservation test — pas plusieurs parcours en parallèle au démarrage.
- **Affichage des montants et commissions** (5.4) : textes stables, compréhensibles, avant validation utilisateur.
- **Traçabilité** : journal serveur des tentatives / succès / échecs, corrélation avec l’utilisateur et l’ordre métier (sans stocker de secrets).

## 4. Sécurité minimale

- **Pas de clés secrètes** dans l’application mobile ou le dépôt ; secrets côté serveur uniquement.
- **HTTPS** partout ; validation stricte des callbacks / signatures si le PSP les fournit.
- **Gestion des doublons** : même idempotency key ou équivalent pour éviter les double débits en cas de retry réseau.

## 5. Prochaine action concrète

1. Atelier court **produit + juridique + technique** : valider le périmètre du pilote et le canal d’intégration retenu.  
2. Ouvrir un **document de suivi** (issue / Notion) listant contacts PSP, liens doc, comptes sandbox.  
3. Ensuite seulement : implémentation alignée sur le plan 5.1–5.4.
