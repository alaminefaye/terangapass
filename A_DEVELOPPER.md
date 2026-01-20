# Teranga Pass - Ce qui reste à développer

## 📊 État actuel du projet

### ✅ CE QUI EST FAIT

#### Backend Laravel (Dashboard Web)
- ✅ **Migrations de base de données** (alerts, incidents, notifications, audio_announcements, partners, users, notification_logs)
- ✅ **Modèles Eloquent** (Alert, Incident, Notification, AudioAnnouncement, Partner, NotificationLog, User)
- ✅ **Dashboard principal** (page d'accueil avec statistiques, carte, graphiques)
- ✅ **Contrôleurs API** (Auth, Alert, Incident, Notification, AudioAnnouncement, CompetitionSite, Transport, Tourism, User)
- ✅ **Routes API** (toutes les routes API configurées)
- ✅ **Vue dashboard.blade.php** (design complet du dashboard)

#### Application Flutter (Mobile)
- ✅ **Design de l'écran d'accueil** (HomeScreen avec tous les éléments visuels)
- ✅ **Structure du projet** (dossiers organisés, services, modèles)
- ✅ **Thème de l'application** (couleurs sénégalaises, police Poppins)
- ✅ **Écrans de base** (HomeScreen, LoginScreen, RegisterScreen, SOSScreen, MedicalAlertScreen, IncidentReportScreen, ProfileScreen, AudioAnnouncementsScreen, JOJInfoScreen, TransportScreen, TourismScreen, NotificationsScreen, MapScreen)
- ⚠️ **Écrans créés mais fonctionnalités limitées** (design présent, logique à compléter)

---

## ❌ CE QUI RESTE À DÉVELOPPER

### 🔴 PRIORITÉ HAUTE - Dashboard Web Laravel

#### 1. **Pages Web manquantes** (URGENT)

Les liens dans le sidebar pointent vers `#` - il faut créer les pages suivantes :

##### a) Page "Alertes" 
**Route :** `/alerts`
**Fichiers à créer :**
- `app/Http/Controllers/AlertController.php` (contrôleur web, pas API)
- `resources/views/alerts/index.blade.php`

**Fonctionnalités :**
- Liste des alertes SOS et médicales
- Filtres (type, date, zone, statut)
- Détails d'une alerte (carte, informations utilisateur, historique)
- Actions : Assigner, Marquer comme résolue, Archiver
- Export des données

##### b) Page "Signalements"
**Route :** `/incidents`
**Fichiers à créer :**
- `app/Http/Controllers/IncidentController.php` (contrôleur web)
- `resources/views/incidents/index.blade.php`

**Fonctionnalités :**
- Liste des signalements d'incidents
- Filtres (type, date, zone, statut)
- Détails d'un signalement (photos, audio, localisation)
- Actions : Valider, Assigner, Résoudre
- Export des données

##### c) Page "Statistiques"
**Route :** `/statistics`
**Fichiers à créer :**
- `app/Http/Controllers/StatisticsController.php`
- `resources/views/statistics/index.blade.php`

**Fonctionnalités :**
- Statistiques détaillées avec graphiques avancés
- Répartition géographique (carte avec heatmap)
- Tendances temporelles (graphiques linéaires, barres)
- Export PDF/Excel des statistiques
- Filtres par période (jour, semaine, mois, année)

##### d) Page "Utilisateurs"
**Route :** `/users`
**Fichiers à créer :**
- `app/Http/Controllers/UserController.php` (contrôleur web)
- `resources/views/users/index.blade.php`
- `resources/views/users/show.blade.php` (détails utilisateur)

**Fonctionnalités :**
- Liste des utilisateurs avec pagination
- Filtres (pays, type d'utilisateur, date d'inscription)
- Recherche par nom, email, téléphone
- Détails utilisateur (profil, historique des alertes/signalements, statistiques)
- Actions : Désactiver/Activer un compte, Modifier les permissions

##### e) Page "Partenaires"
**Route :** `/partners`
**Fichiers à créer :**
- `app/Http/Controllers/PartnerController.php` (contrôleur web)
- `resources/views/partners/index.blade.php`
- `resources/views/partners/create.blade.php` (créer/modifier partenaire)
- `resources/views/partners/show.blade.php` (détails partenaire)

**Fonctionnalités :**
- Liste des partenaires (hôtels, restaurants, pharmacies, etc.)
- Filtres par catégorie, zone, statut
- Créer/Modifier/Supprimer un partenaire
- Détails partenaire (informations, localisation sur carte, statistiques de visites)
- Gestion des sponsors

##### f) Page "Joindre" (Contact/Support)
**Route :** `/contact`
**Fichiers à créer :**
- `app/Http/Controllers/ContactController.php`
- `resources/views/contact/index.blade.php`

**Fonctionnalités :**
- Formulaire de contact
- Liste des demandes de contact
- Système de tickets (optionnel)

#### 2. **Authentification Web**
- ✅ Page de login existe
- ❌ Middleware d'authentification à finaliser
- ❌ Système de permissions/rôles (admin, opérateur, etc.)

#### 3. **Fonctionnalités supplémentaires Dashboard**
- ❌ **Gestion des annonces audio** (interface pour créer/modifier/supprimer)
- ❌ **Gestion des notifications** (créer et envoyer des notifications)
- ❌ **Tableaux de bord personnalisables** (widgets draggable)

---

### 🟡 PRIORITÉ MOYENNE - Application Flutter Mobile

#### 1. **Fonctionnalités Core - À finaliser**

##### a) **Géolocalisation précise**
- ✅ Service LocationService créé
- ❌ Test et affinement de la précision
- ❌ Gestion des permissions sur Android/iOS
- ❌ Mode de suivi en arrière-plan

##### b) **Intégration API complète**
- ✅ Service ApiService créé
- ✅ Endpoints configurés dans ApiConstants
- ❌ Gestion complète des erreurs réseau
- ❌ Retry automatique en cas d'échec
- ❌ Cache local des données
- ❌ Synchronisation offline/online

##### c) **Notifications Push**
- ✅ Service NotificationService créé
- ❌ Configuration Firebase Cloud Messaging (FCM)
- ❌ Configuration APNs (Apple Push Notification Service)
- ❌ Gestion des tokens
- ❌ Notifications en arrière-plan

##### d) **Authentification complète**
- ✅ LoginScreen et RegisterScreen créés
- ❌ Gestion des tokens (stockage sécurisé)
- ❌ Refresh token automatique
- ❌ Déconnexion et nettoyage des données

#### 2. **Écrans à finaliser**

##### a) **SOS Screen**
- ✅ Design créé
- ❌ Géolocalisation en temps réel
- ❌ Appel direct aux services d'urgence (17, 18, 15)
- ❌ Compte à rebours avant envoi automatique
- ❌ Confirmation d'envoi avec suivi

##### b) **Medical Alert Screen**
- ✅ Design créé
- ❌ Sélection du type d'urgence médicale
- ❌ Informations sur l'état du patient
- ❌ Contact SAMU avec position

##### c) **Incident Report Screen**
- ✅ Design créé
- ❌ Upload de photos multiples
- ❌ Enregistrement audio fonctionnel
- ❌ Sélection du type d'incident
- ❌ Prévisualisation avant envoi

##### d) **Map Screen**
- ✅ Écran créé (basique)
- ❌ Intégration Google Maps/Mapbox
- ❌ Affichage des services de secours à proximité
- ❌ Calcul d'itinéraires
- ❌ Navigation GPS
- ❌ Filtres par catégorie

##### e) **Audio Announcements Screen**
- ✅ Design créé
- ❌ Lecteur audio fonctionnel (play/pause, slider)
- ❌ Liste des annonces avec filtres
- ❌ Téléchargement pour lecture offline
- ❌ Multilingue (FR, EN, ES)

##### f) **JOJ Info Screen**
- ✅ Design créé
- ❌ Onglet Calendrier avec événements
- ❌ Onglet Sports (26 sports) avec détails
- ❌ Onglet Accès avec carte des sites
- ❌ Intégration API pour données dynamiques

##### g) **Transport Screen**
- ✅ Design créé
- ❌ Horaires des navettes en temps réel
- ❌ Carte avec arrêts de bus
- ❌ Suivi des navettes en direct
- ❌ Calcul d'itinéraires de transport

##### h) **Tourism Screen**
- ✅ Design créé
- ❌ Liste des hôtels avec filtres
- ❌ Liste des restaurants avec filtres
- ❌ Pharmacies, hôpitaux, ambassades
- ❌ Carte avec tous les points d'intérêt
- ❌ Appel direct depuis l'app

##### i) **Notifications Screen**
- ✅ Design créé
- ❌ Liste des notifications en temps réel
- ❌ Filtres par zone et type
- ❌ Marquer comme lu/non lu
- ❌ Pull-to-refresh

##### j) **Profile Screen**
- ✅ Design créé
- ❌ Modifier les informations personnelles
- ❌ Changer la langue
- ❌ Paramètres de notifications
- ❌ Historique des alertes/signalements
- ❌ Statistiques personnelles

---

### 🟢 PRIORITÉ BASSE - Améliorations et Optimisations

#### Backend
- ❌ **Tests unitaires et d'intégration**
- ❌ **Seeders** pour données de test/démo
- ❌ **Jobs et Queues** pour tâches asynchrones (envoi notifications, génération rapports)
- ❌ **Export de données** (PDF, Excel, CSV)
- ❌ **API de recherche avancée** (Elasticsearch)
- ❌ **Cache Redis** pour améliorer les performances
- ❌ **Documentation API** (Swagger/OpenAPI)

#### Flutter
- ❌ **Mode sombre** (dark mode)
- ❌ **Internationalisation complète** (FR, EN, ES avec fichiers de traduction)
- ❌ **Tests unitaires et d'intégration**
- ❌ **Performance optimization** (images lazy loading, pagination)
- ❌ **Accessibilité** (support lecteurs d'écran)
- ❌ **Analytics** (Firebase Analytics)
- ❌ **Crash reporting** (Firebase Crashlytics)
- ❌ **CI/CD** (automatisation build et déploiement)

---

## 📋 Checklist de développement recommandée

### Phase 1 - Dashboard Web (1-2 semaines)
1. [ ] Créer page Alertes avec liste et détails
2. [ ] Créer page Signalements avec liste et détails
3. [ ] Créer page Statistiques avec graphiques avancés
4. [ ] Créer page Utilisateurs avec gestion complète
5. [ ] Créer page Partenaires avec CRUD complet
6. [ ] Créer page Joindre/Contact
7. [ ] Finaliser l'authentification web
8. [ ] Tester toutes les pages

### Phase 2 - Application Flutter Core (2-3 semaines)
1. [ ] Finaliser géolocalisation et permissions
2. [ ] Compléter intégration API avec gestion d'erreurs
3. [ ] Configurer notifications push (FCM + APNs)
4. [ ] Finaliser écran SOS avec appel direct
5. [ ] Finaliser écran Alertes Médicales
6. [ ] Finaliser écran Signalements avec upload fichiers
7. [ ] Intégrer Google Maps dans Map Screen
8. [ ] Finaliser écran Profil

### Phase 3 - Application Flutter Features (2-3 semaines)
1. [ ] Finaliser lecteur audio pour annonces
2. [ ] Compléter écran JOJ Info avec onglets
3. [ ] Finaliser écran Transport avec horaires temps réel
4. [ ] Finaliser écran Tourisme avec tous les points d'intérêt
5. [ ] Compléter écran Notifications temps réel
6. [ ] Implémenter mode offline/cache
7. [ ] Ajouter internationalisation (i18n)

### Phase 4 - Tests et Optimisations (1-2 semaines)
1. [ ] Tests unitaires backend
2. [ ] Tests d'intégration API
3. [ ] Tests Flutter (widgets, intégration)
4. [ ] Optimisation performances
5. [ ] Correction bugs
6. [ ] Documentation utilisateur

---

## 🎯 Prochaines étapes immédiates

**Priorité 1 :** Créer les pages web manquantes du dashboard (Alertes, Signalements, Statistiques, Utilisateurs, Partenaires)

**Priorité 2 :** Finaliser les fonctionnalités core de l'application Flutter (géolocalisation, API, notifications)

**Priorité 3 :** Compléter les écrans Flutter avec toutes leurs fonctionnalités

---

*Document créé le 19 janvier 2025*
