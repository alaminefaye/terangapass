# Teranga Pass - Reference Maquette et Cahier des Charges

## Objectif de ce document

Ce document transforme la maquette interactive et le cahier des charges en reference operationnelle pour l'application mobile Flutter.

## Ce qu'il faut retenir du cahier des charges

- Teranga Pass doit etre une app tourisme + services + securite, pas une app centree uniquement sur l'urgence.
- L'accueil doit rassurer et donner envie (decouverte d'abord), avec la securite visible mais non dominante.
- L'architecture produit cible repose sur 4 piliers:
  - Decouvrir (vert)
  - Se deplacer (bleu)
  - JOJ Dakar 2026 (or)
  - Etre aide (rouge discret)
- Date cible de stabilisation production: avant le 1er septembre 2026.
- Les exigences non negotiables: securite des donnees sensibles, performance, et souverainete d'hebergement des donnees.

## Lecture rapide de la maquette interactive

### Direction visuelle

- Fond global clair et chaleureux (sable), cartes blanches arrondies.
- Hierarchie claire: hero > recherche > 4 piliers > modules contextuels (ex: JOJ).
- Utilisation forte des couleurs par domaine fonctionnel.

### Ecran accueil (S03) - pattern cible

- Bandeau hero en haut avec message de bienvenue.
- Barre de recherche generale juste sous le hero.
- Grille 2x2 des 4 piliers (icones + sous-titres courts).
- Bandeau JOJ "jours restants" pour la temporalite evenementielle.
- Bouton SOS present mais secondaire visuellement.

### Ecrans cles de la maquette

- S03: Accueil (structure de navigation principale)
- S04: Carte interactive (filtres + bottom sheet)
- S07: SOS urgence (action critique)
- S09/S10: Signalement et suivi incident
- S11: Ambassades
- S13: Calendrier JOJ
- S17: Convertisseur FCFA

## Decisions de transposition dans l'app actuelle

- Conserver l'image de header existante dans l'app (comme demande), sans imposer l'image de la maquette.
- Appliquer la logique S03 sur l'accueil:
  - recherche
  - 4 piliers
  - bandeau JOJ
- Garder les modules deja existants (annonces officielles, infos JOJ, navigation bas).
- Eviter que les boutons d'urgence dominent le premier niveau visuel.

## Mapping des 4 piliers vers l'existant Flutter

- Decouvrir -> `TourismScreen`
- Se deplacer -> `TransportScreen`
- JOJ 2026 -> `JOJInfoScreen`
- Etre aide -> `IncidentReportScreen` (point d'entree aide)

## Ce qui reste a faire ensuite (prochaines iterations)

- Lier la barre de recherche a la recherche reelle POI.
- Calculer dynamiquement le compteur JOJ au lieu d'une valeur fixe.
- Harmoniser les labels FR/EN via les fichiers de localisation.
- Aligner ensuite les autres ecrans critiques (S04, S07, S09, S10, S11, S13, S17) sur la meme grammaire visuelle.

