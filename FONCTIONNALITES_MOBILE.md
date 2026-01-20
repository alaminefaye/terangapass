# Teranga Pass - Fonctionnalités Mobile à Développer

## Vue d'ensemble
**Teranga Pass** est une application mobile de sécurité, d'assistance et de tourisme permettant d'alerter, signaler, informer et accompagner en temps réel les athlètes, visiteurs et citoyens, tout en connectant Dakar à un centre opérationnel de sécurité et de santé, avant, pendant et après les JOJ (Jeux Olympiques de la Jeunesse) 2026.

---

## 1. Bouton SOS & Alerte Médicale

### Description
Système d'alerte d'urgence immédiate avec géolocalisation pour coordonner les services de secours.

### Fonctionnalités à développer
- **Bouton SOS Urgence**
  - Alerte immédiate avec géolocalisation précise (précision à 7 mètres)
  - Affichage de la position actuelle (ex: "Dakar Plateau, 9 Rue Carnot")
  - Indication de la précision de la géolocalisation

- **Bouton Alerte Médicale**
  - Alerte médicale avec géolocalisation
  - Coordination avec les services médicaux

- **Coordination des services**
  - Contact direct avec Police (17)
  - Contact direct avec Pompiers (18)
  - Contact direct avec SAMU (15)
  - Affichage des temps de réponse estimés pour chaque service
  - Affichage de la distance et du temps d'arrivée des secours sur une carte

- **Interface utilisateur**
  - Boutons d'urgence visibles et accessibles en permanence
  - Carte interactive montrant les services de secours à proximité
  - Section "Urgence signalée" avec confirmation de coordination immédiate
  - Historique des alertes envoyées

### Données nécessaires
- Géolocalisation en temps réel
- Base de données des services de secours (police, pompiers, SAMU, hôpitaux)
- API de calcul d'itinéraires et de temps de trajet
- Système de notification push pour les services de secours

---

## 2. Signalement d'Incidents

### Description
Permet aux utilisateurs de signaler divers types d'incidents avec photos, audio et messages géolocalisés.

### Fonctionnalités à développer
- **Types d'incidents**
  - Perte d'objets
  - Accidents
  - Situations suspectes

- **Formulaire de signalement**
  - Question initiale: "Quel est ce qu'il est arrivé?"
  - Sélection du type d'incident (boutons: "Perte", "Accident", "Suspect")
  - Champ de description: "Décrire l'incident, donner des détails"
  - Ajout de photos
  - Enregistrement audio
  - Géolocalisation automatique de l'incident

- **Envoi du signalement**
  - Bouton "Envoyer ma position"
  - Bouton "Envoyer Signalement"
  - Confirmation d'envoi

- **Coordination avec les services**
  - Affichage des contacts d'urgence (Police 17, Pompiers 18, SAMU 15)
  - Temps de réponse estimés pour chaque service
  - Carte montrant la localisation de l'incident

### Données nécessaires
- Stockage de photos et fichiers audio
- Géolocalisation
- Base de données des signalements
- Système de notification pour les autorités compétentes

---

## 3. Annonces Audio Officielles

### Description
Système de diffusion d'annonces audio officielles multilingues avec lecteur audio prioritaire.

### Fonctionnalités à développer
- **Lecteur audio**
  - Lecteur audio prioritaire sur l'application
  - Contrôles de lecture (play/pause, avancer, reculer)
  - Barre de progression avec temps actuel et durée totale
  - Support multilingue (français, anglais, espagnol, etc.)

- **Affichage des annonces**
  - Section "Annonce Officielle"
  - Drapeaux des langues disponibles
  - Liste des annonces officielles avec:
    - Titre de l'annonce
    - Contenu textuel
    - Horodatage ("il y a X min", "il y a X h")
    - Bouton "Voir plus d'annonces"

- **Types d'annonces**
  - Messages de sécurité
  - Consignes JOJ
  - Alertes officielles
  - Informations sur les villages JOJ
  - Informations sur les navettes

- **Géolocalisation des annonces**
  - Annonces ciblées par zone géographique
  - Carte interactive montrant les zones concernées

### Données nécessaires
- Stockage de fichiers audio
- Base de données des annonces officielles
- Système de traduction multilingue
- Géolocalisation pour le ciblage

---

## 4. Notifications en Temps Réel

### Description
Système de notifications push pour la sécurité, la météo, la circulation et les consignes JOJ, avec alertes ciblées par zone.

### Fonctionnalités à développer
- **Types de notifications**
  - Sécurité
  - Météo
  - Circulation
  - Consignes JOJ
  - Alertes ciblées par zone ou site de compétition

- **Interface de notifications**
  - Section "Notifications en temps réel"
  - Filtres par zone: "Dakar Centre", "M'Bour 4 Stadium", "Plateau"
  - Liste des notifications avec:
    - Type d'alerte (badge: "Sécurité", icône météo, etc.)
    - Titre de l'alerte
    - Description détaillée
    - Horodatage ("il y a X min")
    - Zone concernée (dropdown)
    - Actions: cœur (like), commentaire, partage, icône JOJ

- **Exemples de notifications**
  - Alertes de sécurité (ex: "Alerte Sécurité: Stadium Assane vigilance!")
  - Navettes gratuites (ex: "Navettes Gratuites JOJ 2026")
  - Alertes météo (ex: "Météo: Chaleur importante ce midi" avec température)
  - Sécurité routière (ex: "Sécurité routière: Pose de dispositifs de sécurité")

- **Fonctionnalités sociales**
  - Système de likes
  - Commentaires
  - Partage
  - Compteur d'interactions

- **Bouton "Voir plus d'alertes"**
  - Chargement de plus de notifications

### Données nécessaires
- Système de notifications push
- Base de données des notifications
- Géolocalisation pour le ciblage
- API météo
- Système de commentaires et interactions sociales

---

## 5. Infos JOJ & Sites de Compétitions

### Description
Informations complètes sur les villages JOJ, stades, arènes, calendrier, accès et consignes spécifiques.

### Fonctionnalités à développer
- **Navigation par onglets**
  - Onglet "Calendrier"
  - Onglet "Sports (26)" - liste des sports
  - Onglet "Accès" - informations d'accès

- **Affichage des sites**
  - Liste des sites de compétition:
    - **Stade Olympique**
      - Dates: "16-23 AOÛT"
      - Programme détaillé
      - Localisation: "Dakar Centre"
    - **Dakar Arena**
      - Dates: "16-18 AOÛT"
      - Programme détaillé
      - Localisation: "Dakar Centre"

- **Informations détaillées**
  - Villages JOJ
  - Stades
  - Arènes
  - Sites culturels
  - Sites touristiques
  - Consignes spécifiques par site

- **Carte interactive**
  - Affichage des sites sur une carte
  - Localisation "Plateau"
  - Pins pour les différents sites

- **Navigation**
  - Barre de navigation inférieure: "Infos", "Carte", "Transport", "Menu"

### Données nécessaires
- Base de données des sites de compétition
- Calendrier des événements
- Coordonnées GPS des sites
- Informations d'accès et consignes
- Intégration de cartes (Google Maps, OpenStreetMap)

---

## 6. Transport & Navettes

### Description
Informations sur les itinéraires sécurisés, navettes JOJ et transports partenaires.

### Fonctionnalités à développer
- **Navettes Gratuites JOJ 2026**
  - Période: "16-23 AOÛT"
  - Horaires: "Aujourd'hui (tous les 20min): 08:30 à 19:30"
  - Jours: "Navettes gratuites lundi au dimanche"
  - Horaires de départ: 08:30, 08:50, 09:10, 10:10, etc.
  - Affichage "Prochain départ: 08:30"
  - Localisation: "Dakar Centre"
  - Badge "Itinéraire Sécurisé"
  - Icônes: bus, train, bateau

- **Ligne Express-JOJ**
  - Période: "16-18 AOÛT"
  - Itinéraire: "Gare des Baux Maraîchers - Blaise Diagne"
  - Terminus: "Acapes DK-13"
  - Horaires: "Aujourd'hui: 07:00 - 20:00"
  - Informations de retour
  - Badge "Itinéraire Sécurisé"
  - Icône "Gare Centre"

- **Transport Partenaires**
  - Section "Navettes JOJ"
  - Section "Transport" (partenaires)
  - Navigation vers les détails

- **Carte interactive**
  - Affichage de la position "Plateau"
  - Points d'arrêt des navettes
  - Itinéraires sécurisés

- **Navigation**
  - Barre de navigation: "Infos JOJ", "Transport", "Carte", "Transport", "Menu"

### Données nécessaires
- Horaires des navettes en temps réel
- Itinéraires et trajets
- Coordonnées GPS des arrêts
- Informations sur les transports partenaires
- Système de suivi en temps réel des navettes

---

## 7. Tourisme & Services Utiles

### Description
Informations sur les hôtels partenaires, restaurants, sites touristiques, guides, pharmacies, hôpitaux et ambassades.

### Fonctionnalités à développer
- **Hôtels & Restaurants Partenaires**
  - Liste des hôtels partenaires (ex: "Hôtel Radisson Dakar" - 6 min en voiture)
  - Liste des restaurants partenaires (ex: "Restaurant Chez Loutcha" - 4 min à pied)
  - Informations de disponibilité (ex: "Hôtel King Fahd Palace" - Aujourd'hui jusqu'à 20h)
  - Distance et temps de trajet

- **Sites Touristiques & Guides**
  - Liste des sites touristiques
  - Guides touristiques disponibles
  - Informations pratiques

- **Services Utiles**
  - **Pharmacies** (ex: "Pharmacie Medina" - 3 min à pied)
  - **Hôpitaux** (ex: "Hôpital Principal de Dakar")
  - **Ambassades** (ex: "Ambassade de France")

- **Section "PARTENAIRES OFFICIELS - DESTINATIONS"**
  - Liste organisée des partenaires officiels
  - Catégorisation par type de service

- **Carte interactive**
  - Affichage de tous les points d'intérêt sur une carte
  - Localisation "Plateau"
  - Icônes différenciées (hôpital, pharmacie, restaurant, hôtel, ambassade)

- **Navigation**
  - Barres de navigation avec compteurs: "SOS 21", "JOJ 96", "Y 47"
  - Onglets: "Infos", "Transport", "Tourisme", "Menu"

### Données nécessaires
- Base de données des partenaires (hôtels, restaurants, pharmacies, etc.)
- Coordonnées GPS de tous les points d'intérêt
- Informations de contact
- Horaires d'ouverture
- Système de réservation (pour hôtels/restaurants si applicable)

---

## 8. Carte Interactive

### Description
Carte géolocalisée affichant tous les services, sites JOJ, hôtels, secours et permettant la navigation.

### Fonctionnalités à développer
- **Affichage sur carte**
  - Services de secours (police, pompiers, SAMU, hôpitaux)
  - Sites JOJ (villages, stades, arènes)
  - Hôtels partenaires
  - Restaurants partenaires
  - Pharmacies
  - Ambassades
  - Points d'arrêt de transport
  - Zones de compétition

- **Navigation géolocalisée**
  - Calcul d'itinéraires
  - Navigation GPS
  - Itinéraires sécurisés
  - Temps de trajet estimé
  - Distance

- **Filtres et recherche**
  - Filtrage par catégorie de service
  - Recherche par nom
  - Recherche par type de service

- **Informations contextuelles**
  - Popup avec détails au clic sur un point
  - Distance et temps de trajet depuis la position actuelle
  - Informations de contact
  - Horaires d'ouverture

- **Marqueurs personnalisés**
  - Icônes différenciées par type de service
  - Badges de statut (ouvert/fermé, disponible)
  - Indicateurs de distance

### Données nécessaires
- Service de cartographie (Google Maps, Mapbox, OpenStreetMap)
- Géolocalisation en temps réel
- Base de données géolocalisée de tous les points d'intérêt
- API de calcul d'itinéraires
- Système de navigation GPS

---

## 9. Profil Utilisateur

### Description
Gestion du profil utilisateur et des paramètres de l'application.

### Fonctionnalités à développer
- **Informations personnelles**
  - Nom, prénom
  - Photo de profil
  - Langue préférée
  - Type d'utilisateur (athlète, visiteur, citoyen)

- **Paramètres**
  - Notifications (activer/désactiver par type)
  - Préférences de langue
  - Préférences de zone géographique
  - Confidentialité et sécurité

- **Historique**
  - Historique des alertes envoyées
  - Historique des signalements
  - Notifications reçues
  - Itinéraires consultés

- **Statistiques**
  - Nombre d'alertes envoyées
  - Nombre de signalements
  - Zones visitées

### Données nécessaires
- Système d'authentification
- Base de données des utilisateurs
- Stockage des préférences
- Historique des actions utilisateur

---

## 10. Système de Notifications Push

### Description
Système de notifications push pour toutes les fonctionnalités de l'application.

### Fonctionnalités à développer
- **Types de notifications**
  - Alertes d'urgence
  - Notifications de sécurité
  - Alertes météo
  - Informations sur le trafic
  - Annonces officielles
  - Mises à jour sur les navettes
  - Réponses aux signalements

- **Paramètres de notification**
  - Activation/désactivation par type
  - Préférences de zone géographique
  - Fréquence des notifications
  - Mode silencieux

- **Badge de notification**
  - Compteur de notifications non lues
  - Badge sur l'icône de l'application

### Données nécessaires
- Service de notifications push (Firebase Cloud Messaging, Apple Push Notification Service)
- Système de gestion des tokens de notification
- Base de données des préférences de notification

---

## 11. Multilingue

### Description
Support multilingue pour l'application (français, anglais, espagnol, etc.).

### Fonctionnalités à développer
- **Langues supportées**
  - Français
  - Anglais
  - Espagnol
  - Autres langues selon les besoins

- **Interface multilingue**
  - Traduction de tous les textes de l'interface
  - Traduction des annonces officielles
  - Traduction des notifications
  - Sélection de langue dans les paramètres

- **Annonces audio multilingues**
  - Support audio dans plusieurs langues
  - Sélection de langue pour les annonces

### Données nécessaires
- Fichiers de traduction (i18n)
- Base de données multilingue pour le contenu
- Système de détection automatique de langue

---

## 12. Centre Opérationnel (Backend)

### Description
Interface backend pour le centre opérationnel de sécurité et de santé.

### Fonctionnalités à développer
- **Tableau de bord**
  - Vue d'ensemble des alertes en temps réel
  - Statistiques des incidents
  - Carte opérationnelle

- **Gestion des alertes**
  - Réception des alertes SOS et médicales
  - Assignation aux services compétents
  - Suivi du statut des interventions
  - Historique des alertes

- **Gestion des signalements**
  - Réception des signalements d'incidents
  - Validation et traitement
  - Assignation aux autorités compétentes
  - Suivi des actions

- **Gestion des annonces**
  - Création et publication d'annonces officielles
  - Enregistrement audio
  - Ciblage géographique
  - Programmation des annonces

- **Gestion des notifications**
  - Création et envoi de notifications
  - Ciblage par zone
  - Programmation des notifications

### Données nécessaires
- API backend pour le centre opérationnel
- Base de données centralisée
- Système d'authentification pour les opérateurs
- Interface d'administration web

---

## Technologies Recommandées

### Frontend Mobile
- **Framework**: React Native ou Flutter (pour iOS et Android)
- **Cartes**: Google Maps API, Mapbox, ou OpenStreetMap
- **Géolocalisation**: React Native Geolocation, Google Location Services
- **Notifications**: Firebase Cloud Messaging, Apple Push Notification Service
- **Audio**: React Native Sound, ExoPlayer

### Backend
- **Framework**: Laravel (déjà présent dans le projet)
- **Base de données**: MySQL/PostgreSQL
- **API**: REST API ou GraphQL
- **Stockage**: AWS S3, Google Cloud Storage pour fichiers média
- **Temps réel**: Laravel Echo, WebSockets, Pusher

### Services Externes
- **Cartes et navigation**: Google Maps API, Mapbox
- **Météo**: OpenWeatherMap API
- **SMS/Voice**: Twilio (pour appels d'urgence)
- **Analytics**: Firebase Analytics, Google Analytics

---

## Priorités de Développement

### Phase 1 - Essentiel (MVP)
1. Bouton SOS & Alerte Médicale
2. Signalement d'Incidents
3. Carte Interactive de base
4. Authentification utilisateur

### Phase 2 - Fonctionnalités Core
5. Notifications en Temps Réel
6. Annonces Audio Officielles
7. Infos JOJ & Sites de Compétitions
8. Profil Utilisateur

### Phase 3 - Services Complémentaires
9. Transport & Navettes
10. Tourisme & Services Utiles
11. Multilingue complet
12. Centre Opérationnel (Backend)

---

## Notes Importantes

- **Sécurité**: Toutes les communications doivent être chiffrées (HTTPS, TLS)
- **Performance**: Optimisation pour les connexions réseau limitées
- **Accessibilité**: Interface accessible pour tous les utilisateurs
- **Offline**: Mode hors ligne pour les fonctionnalités essentielles
- **Conformité**: Respect des réglementations sur la protection des données (RGPD, etc.)
- **Tests**: Tests approfondis, notamment pour les fonctionnalités critiques (SOS)

---

*Document créé le 19 janvier 2025*
*Basé sur l'analyse de la présentation PowerPoint "Présentation teranga pass.pptx"*
