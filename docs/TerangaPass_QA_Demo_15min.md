# Teranga Pass — Démo 15 minutes / QA rapide

**Objectif** : valider un parcours visiteur **sans crash** avant démo interne ou partenaires.

**Plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — critère étape 1 « terminé ».

---

## Pré-requis (5 min)

- Backend Laravel accessible (`APP_URL`) ; compte test utilisateur (non admin, non bloqué).
- Clé `TERANGA_PASS_CONTROL_KEY` renseignée si vous testez le contrôle staff (curl).
- App Flutter sur **appareil réel** Android ou iOS (GPS, tuiles OSM).

---

## Parcours (~10 min)

1. **Connexion** : login → pas d’écran figé ; erreur réseau claire si API coupée.
2. **Accueil** : cartes / piliers répondent ; sur la carte JOJ, **légende** (repères verts) visible si sites géolocalisés ; **INFOS JOJ** → **Mon Pass (QR)** s’ouvre.
3. **Pass QR** : chargement du billet ; affichage du QR ; retour arrière OK.
4. **Carte interactive** (`MapScreen`) : tuiles visibles ou snack d’erreur tuiles ; filtres ; liste en bas scrollable ; **légende** (couleurs / filtres) lisible.
5. **À deux pas** (`NearbyScreen`) : autorisation localisation ; repères **vous** / **lieu** / **partenaire** cohérents avec la légende ; liste non vide si données backend.
6. **SOS** (si prévu dans votre build) : action rapide sans crash (pas d’appel réel en recette si risque).

---

## Fin de session

- Noter : version app, OS, crashs éventuels, écran bloquant.
- Si **403** sur le Pass : vérifier révocation admin / compte suspendu / `Accept-Language` (message FR/EN).
