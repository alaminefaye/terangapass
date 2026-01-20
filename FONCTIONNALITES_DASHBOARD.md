# Teranga Pass - Fonctionnalités Dashboard Web

## Vue d'ensemble
Dashboard web pour le centre opérationnel de sécurité et de santé de Teranga Pass, permettant de gérer et monitorer toutes les activités de l'application mobile.

---

## 1. Dashboard Principal

### Widgets de Métriques
- **Mesures audio** : Nombre total d'annonces audio envoyées (147,233)
- **Alertes SOS** : Nombre d'alertes SOS reçues (768) avec pourcentage d'augmentation
- **Notifications envoyées** : Total des notifications (412,673)
- **Signalements d'incidents** : Nombre de signalements (2,781) avec types (Perte, Accident, Situation suspecte)
- **Publicité sponsors** : Nombre de publicités (96) avec CTR (11%)
- **Utilisateurs JOJ** : Total des utilisateurs (76,810) avec répartition par pays

### Carte Interactive
- Affichage de la carte avec pins colorés :
  - Rouge : Alertes SOS
  - Bleu : Alertes médicales
  - Orange : Hôtels
  - Vert : Restaurants
- Filtres : SOS, Alertes, Hôtels, Restos
- Indicateur de progression (68.8%)

### Tableaux de Données
- **Notifications / Signalements géolocalisés** :
  - Liste des sites avec nombre d'incidents, alertes et total
  - Sites : Stade Mbour 4, Village Athlètes, Fan Zone, Stade Olympique, Hôtel King Fahd Palace
  - Pagination

### Graphiques
- **Annonces et alertes (semaine)** : Graphique linéaire avec deux lignes (Messages audio, Alertes/emails)
- **Sources de trafic (hebdomadaire)** : Graphique linéaire avec plusieurs lignes (Hôtels & restos, Compétitions JOJ, Transport, Autres Services)

---

## 2. Navigation

### Menu Principal
- **Accueil** : Dashboard principal
- **Alertes** : Gestion des alertes SOS et médicales
- **Signalements** : Gestion des signalements d'incidents
- **Statistiques** : Statistiques détaillées
- **Utilisateurs** : Gestion des utilisateurs
- **Partenaires** : Gestion des partenaires
- **Joindre** : Contact/Support

---

## 3. Gestion des Alertes

### Fonctionnalités
- Liste des alertes SOS reçues
- Liste des alertes médicales
- Filtres par zone géographique
- Statut des alertes (en attente, en cours, résolue)
- Assignation aux services compétents
- Historique des interventions

### Données nécessaires
- Table `alerts` (SOS et médicales)
- Géolocalisation
- Statut et historique

---

## 4. Gestion des Signalements

### Fonctionnalités
- Liste des signalements d'incidents
- Types : Perte, Accident, Situation suspecte
- Photos et enregistrements audio
- Géolocalisation
- Validation et traitement
- Assignation aux autorités compétentes

### Données nécessaires
- Table `incidents`
- Stockage des fichiers (photos, audio)
- Géolocalisation

---

## 5. Gestion des Notifications

### Fonctionnalités
- Création et envoi de notifications
- Ciblage par zone géographique
- Types : Sécurité, Météo, Circulation, Consignes JOJ
- Programmation des notifications
- Statistiques d'envoi

### Données nécessaires
- Table `notifications`
- Zones géographiques
- Historique d'envoi

---

## 6. Gestion des Annonces Audio

### Fonctionnalités
- Création d'annonces audio officielles
- Upload de fichiers audio
- Support multilingue (FR, EN, ES)
- Ciblage géographique
- Programmation des annonces
- Statistiques d'écoute

### Données nécessaires
- Table `audio_announcements`
- Stockage des fichiers audio
- Traductions multilingues

---

## 7. Gestion des Utilisateurs

### Fonctionnalités
- Liste des utilisateurs
- Statistiques par pays
- Types d'utilisateurs (Athlète, Visiteur, Citoyen)
- Historique des activités
- Gestion des permissions

### Données nécessaires
- Table `users` (étendue)
- Statistiques par pays
- Historique des actions

---

## 8. Gestion des Partenaires

### Fonctionnalités
- Liste des partenaires (Hôtels, Restaurants, Pharmacies, etc.)
- Gestion des informations
- Statistiques de visites
- Publicité sponsors

### Données nécessaires
- Table `partners`
- Catégories de partenaires
- Statistiques

---

## 9. Statistiques

### Fonctionnalités
- Statistiques globales
- Graphiques temporels
- Répartition géographique
- Sources de trafic
- Tendances et analyses

### Données nécessaires
- Agrégations de données
- Graphiques (ApexCharts)
- Export de données

---

## 10. API Endpoints

### Endpoints nécessaires
- `GET /api/dashboard/stats` : Statistiques du dashboard
- `GET /api/alerts` : Liste des alertes
- `POST /api/alerts` : Créer une alerte
- `GET /api/incidents` : Liste des signalements
- `GET /api/notifications` : Liste des notifications
- `POST /api/notifications` : Créer une notification
- `GET /api/audio-announcements` : Liste des annonces audio
- `POST /api/audio-announcements` : Créer une annonce
- `GET /api/users` : Liste des utilisateurs
- `GET /api/users/stats` : Statistiques utilisateurs
- `GET /api/partners` : Liste des partenaires
- `GET /api/map-data` : Données pour la carte

---

## Structure de Base de Données

### Tables principales
1. **alerts** : Alertes SOS et médicales
2. **incidents** : Signalements d'incidents
3. **notifications** : Notifications envoyées
4. **audio_announcements** : Annonces audio officielles
5. **users** : Utilisateurs (étendu)
6. **partners** : Partenaires
7. **notification_logs** : Historique des notifications
8. **alert_responses** : Réponses aux alertes
9. **incident_responses** : Réponses aux signalements

---

## Technologies Utilisées

- **Backend** : Laravel 12
- **Frontend** : Blade Templates + Bootstrap
- **Graphiques** : ApexCharts
- **Cartes** : Google Maps API / Leaflet
- **Base de données** : MySQL/PostgreSQL

---

*Document créé le 19 janvier 2025*
