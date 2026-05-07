# Teranga Pass — Process contenu / annuaire (étape 3)

**Objectif** : garder les **fiches lieux** (proximité, carte, tourisme) **exploitables** sans dette silencieuse.

**Plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — étape 3.

---

## Rôles (à adapter)

| Rôle | Responsibility |
|------|----------------|
| **Éditeur** | Saisie / mise à jour coordonnées, catégorie, téléphone, tags sponsor. |
| **Validateur** | Contrôle ponctuel terrain ou second avis sur les champs critiques (urgence, santé). |

---

## Fréquence minimale suggérée

- **Avant événement majeur (ex. JOJ)** : passage complet des catégories exposées dans l’app (hôtels, sites, SOS médical si lié à l’annuaire).
- **En continu** : traiter les retours support / partenaires sous forme de tickets priorisés.

---

## Qualité d’une fiche

- **Coordonnées** : latitude / longitude cohérentes avec l’adresse affichée.
- **Catégorie** : alignée avec les filtres de l’app (`NearbyScreen`, `MapScreen`) pour des couleurs / filtres pertinents.
- **Partenaires sponsor** : indicateur `is_sponsor` (ou équivalent backend) **explicite** — évite les ambiguïtés légales d’affichage.

---

## Indicateurs (exemples)

- % de fiches avec téléphone renseigné dans les catégories « urgence / aide ».
- Nombre de signalements utilisateurs « lieu incorrect » / trimestre.
