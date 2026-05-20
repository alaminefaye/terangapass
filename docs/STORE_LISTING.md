# Teranga Pass — Textes pour App Store & Google Play

Document prêt à copier-coller dans **App Store Connect** et **Google Play Console**.  
Langue principale : **français** (marché Sénégal / JOJ). Versions **anglais** en fin de fichier.

---

## Identité

| Champ | Valeur |
|-------|--------|
| Nom de l’app | **Teranga Pass** |
| Bundle ID / Package | `com.terangapass.app` |
| Catégorie principale | **Voyages** (Travel) |
| Catégorie secondaire (iOS) | **Style de vie** ou **Utilitaires** |
| Âge | **4+** (ajuster si contenu sensible SOS — souvent **12+** si signalements utilisateurs) |
| URL confidentialité | https://www.terangapass.com/politique-confidentialite |
| URL conditions d’utilisation | https://www.terangapass.com/conditions-utilisation |
| **URL assistance (App Store)** | **https://www.terangapass.com/assistance** |
| URL marketing (optionnel) | https://www.terangapass.com |
| E-mail support | contact@terangapass.com |

---

## App Store Connect — Chiffrement (étape « Objectif de l’app »)

**Champ obligatoire — max 300 caractères** (copier tel quel) :

```
Teranga Pass aide les visiteurs et résidents au Sénégal : découvrir des lieux et services, consulter la carte, suivre les infos JOJ Dakar 2026, et utiliser l’aide en cas de besoin (SOS, alerte médicale, signalement). L’application communique avec nos serveurs via HTTPS standard.
```

*(≈ 248 caractères)*

**Réponses habituelles aux questions chiffrement :**
- Utilisez-vous le chiffrement ? → **Oui**
- Exemption / chiffrement standard uniquement ? → **Oui** (HTTPS, pas de crypto propriétaire militaire)
- `ITSAppUsesNonExemptEncryption` = **false** (déjà dans le projet iOS)

---

## Titre & sous-titre (iOS)

| Champ | Limite | Texte FR |
|-------|--------|----------|
| **Nom** | 30 car. | Teranga Pass |
| **Sous-titre** | 30 car. | Tourisme, JOJ & sécurité |

**Variantes sous-titre :**
- `Sénégal : carte, JOJ, SOS` (26)
- `Voyage, carte et assistance` (27)

---

## Texte promotionnel (iOS — 170 caractères max)

```
Explorez le Sénégal, suivez les JOJ Dakar 2026, trouvez des lieux à proximité et gardez l’assistance à portée de main — carte, transports, annonces et alertes SOS.
```

*(≈ 168 caractères)*

---

## Description courte (Google Play — 80 caractères max)

```
Tourisme, carte, JOJ 2026, lieux utiles et assistance (SOS) au Sénégal.
```

---

## Description complète — FR (App Store / Play)

```
Teranga Pass est votre compagnon mobile pour découvrir le Sénégal en toute sérénité — que vous soyez visiteur, résident ou participant aux Jeux Olympiques de la Jeunesse (JOJ) Dakar 2026.

DÉCOUVRIR
• Annuaire de lieux et services (restaurants, hôtels, pharmacies, banques, sites touristiques…)
• Carte interactive et recherche à proximité
• Recommandations et contenus touristiques
• Convertisseur de devises et informations pratiques

SE DÉPLACER
• Informations transport et navettes
• Itinéraires et points d’intérêt sur la carte

JOJ DAKAR 2026
• Actualités et compte à rebours
• Sites de compétition et calendrier
• Annonces officielles audio

ÊTRE AIDÉ
• Bouton SOS pour alerter en urgence
• Alerte médicale
• Signalement d’incident avec suivi
• Notifications d’alertes et messages utiles (météo, sécurité, transport…)

FONCTIONNALITÉS COMPLÉMENTAIRES
• Assistant d’information (conseils voyage)
• Ambassades et contacts utiles
• Pack de données hors ligne (carte et contenus téléchargeables)
• Profil, langue (FR, EN, ES, PT, AR) et mode sombre
• Mode invité pour explorer sans compte ; connexion pour SOS et suivi personnalisé

Teranga Pass ne remplace pas les services d’urgence officiels (police, pompiers, SAMU). En cas de danger immédiat, appelez les numéros d’urgence locaux.

Support : contact@terangapass.com
Confidentialité : https://www.terangapass.com/politique-confidentialite
Conditions : https://www.terangapass.com/conditions-utilisation
```

---

## Mots-clés (App Store — 100 caractères max, virgules sans espace)

```
Sénégal,Dakar,tourisme,JOJ,carte,SOS,voyage,transport,sécurité,visiteur,annuaire,alerte
```

---

## Notes pour l’équipe de revue (App Store — « Notes App Review »)

```
Compte de test (si demandé) :
- E-mail : [votre compte test]
- Mot de passe : [mot de passe]

Parcours invité : ouvrir l’app sans connexion → accueil, carte, tourisme.
Parcours connecté : connexion → profil → SOS (nécessite compte) / signalement.

L’app utilise la localisation pour la carte, la météo et les alertes de proximité.
Les notifications push servent aux alertes et messages officiels (Firebase).

API production : https://www.terangapass.com/api/v1
```

---

## Google Play — fiche complémentaire

| Champ | Texte FR |
|-------|----------|
| **Titre** | Teranga Pass |
| **Description courte** | Voir section « Description courte » ci-dessus |
| **Description complète** | Même texte que « Description complète — FR » |
| **Type d’application** | Application |
| **Catégorie** | Voyages et local |
| **Balises** | Tourisme, Carte, Sécurité, Sénégal, JOJ |
| **Coordonnées développeur** | contact@terangapass.com |
| **Site web** | https://www.terangapass.com |
| **Politique de confidentialité** | https://www.terangapass.com/politique-confidentialite |

**Déclarations Play Console :**
- **Annonces** : selon activation des pop-ups promo dans l’app (à déclarer si campagnes actives)
- **Localisation** : Oui — fonctionnalité principale (carte, proximité, SOS)
- **Données collectées** : compte (e-mail, téléphone), position, photos/signalements si utilisateur les envoie

---

## « Quoi de neuf » — version 1.0.0

```
Première version publique de Teranga Pass :
• Accueil avec météo, recherche et 4 piliers (Découvrir, Se déplacer, JOJ, Être aidé)
• Carte, tourisme, transports et infos JOJ Dakar 2026
• SOS, alerte médicale, signalements et notifications
• Assistant, ambassades, pack hors ligne et multilingue
```

---

# English (App Store / Play — optional)

## App objective (encryption — max 300 characters)

```
Teranga Pass helps visitors and residents in Senegal discover places and services, use the map, follow Youth Olympic Games Dakar 2026 info, and access assistance (SOS, medical alert, incident reports). The app uses standard HTTPS to communicate with our servers.
```

## Subtitle (30 chars)

```
Travel, map, YOG & safety
```

## Short description (Google Play, 80 chars)

```
Tourism, map, YOG 2026, nearby places and SOS assistance in Senegal.
```

## Promotional text (170 chars)

```
Explore Senegal, follow YOG Dakar 2026, find nearby places, and keep assistance at hand — map, transport, announcements and SOS alerts.
```

## Full description (EN)

```
Teranga Pass is your mobile companion to discover Senegal with peace of mind — whether you are a visitor, resident, or attending the Youth Olympic Games (YOG) Dakar 2026.

DISCOVER
• Directory of places and services (restaurants, hotels, pharmacies, banks, tourist sites…)
• Interactive map and nearby search
• Tourism content and recommendations
• Currency converter and practical information

GET AROUND
• Transport and shuttle information
• Routes and points of interest on the map

YOG DAKAR 2026
• News and countdown
• Competition venues and calendar
• Official audio announcements

GET HELP
• SOS button for emergencies
• Medical alert
• Incident reporting with tracking
• Notifications (weather, security, transport…)

Teranga Pass does not replace official emergency services. In immediate danger, call local emergency numbers.

Support: contact@terangapass.com
Privacy: https://www.terangapass.com/privacy-policy
Terms: https://www.terangapass.com/terms-of-use
```

## Keywords (App Store)

```
Senegal,Dakar,tourism,YOG,map,SOS,travel,transport,safety,visitor,directory,alert
```

---

## Captures d’écran — suggestions de légendes

1. Accueil — « Découvrez le Sénégal en un coup d’œil »
2. Carte — « Lieux et services autour de vous »
3. Tourisme — « Annuaire complet des points d’intérêt »
4. JOJ 2026 — « Suivez les Jeux Olympiques de la Jeunesse »
5. SOS — « Assistance d’urgence à portée de main »
6. Notifications — « Alertes et infos utiles en temps réel »
7. Profil — « Compte, langue et préférences »

---

*Dernière mise à jour : mai 2026 — Teranga Pass v1.0.0*
