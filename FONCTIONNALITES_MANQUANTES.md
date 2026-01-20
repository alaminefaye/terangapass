# Fonctionnalités Manquantes dans le Dashboard

## 📱 Fonctionnalités de l'Application Mobile

### ✅ CE QUI EXISTE DANS LE DASHBOARD

1. **✅ SOS Urgence** 
   - Dashboard : Gestion complète des alertes SOS
   - API : `/api/sos/alert`

2. **✅ Alerte Médicale**
   - Dashboard : Gestion complète des alertes médicales
   - API : `/api/medical/alert`

3. **✅ Signalement d'Incidents**
   - Dashboard : Gestion complète (liste, détails, validation, rejet)
   - API : `/api/incidents/report`

4. **✅ Annonces Audio**
   - Dashboard : Gestion complète (CRUD + upload)
   - API : `/api/announcements/audio`

5. **✅ Notifications Push**
   - Dashboard : Gestion complète (créer, envoyer, programmer)
   - API : `/api/notifications`

---

### ❌ CE QUI MANQUE DANS LE DASHBOARD

#### 1. **❌ Gestion du Tourisme & Services Utiles**
**Dans l'app mobile :**
- Hôtels partenaires
- Restaurants partenaires
- Pharmacies
- Hôpitaux
- Ambassades
- Sites touristiques
- Guides touristiques

**État actuel :**
- ✅ API existe : `/api/tourism/points-of-interest`
- ❌ **Pas d'interface web** pour gérer ces données
- ✅ Modèle `Partner` existe
- ❌ **Pas de contrôleur web** pour la gestion

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── TourismManagementController.php (CRUD complet)

📁 resources/views/tourism/
   ├── index.blade.php (liste avec filtres par catégorie)
   ├── create.blade.php (créer un partenaire)
   ├── edit.blade.php (modifier)
   └── show.blade.php (détails avec carte)

🔗 Routes:
   - GET    /admin/tourism
   - GET    /admin/tourism/create
   - POST   /admin/tourism
   - GET    /admin/tourism/{id}/edit
   - PUT    /admin/tourism/{id}
   - DELETE /admin/tourism/{id}
```

---

#### 2. **❌ Gestion des Sites de Compétition JOJ**
**Dans l'app mobile :**
- Liste des sites (Stade Olympique, Dakar Arena, etc.)
- Calendrier des compétitions
- Informations par sport (26 sports)
- Informations d'accès
- Carte avec localisation des sites

**État actuel :**
- ✅ API existe : `/api/sites/competitions` et `/api/sites/calendar`
- ❌ **Pas d'interface web** pour gérer ces données
- ❌ **Pas de modèle** pour les sites de compétition
- ❌ **Pas de migration** pour la table

**À créer :**
```
📁 database/migrations/
   └── create_competition_sites_table.php

📁 app/Models/
   └── CompetitionSite.php

📁 app/Http/Controllers/Web/
   └── CompetitionSiteManagementController.php

📁 resources/views/competition-sites/
   ├── index.blade.php
   ├── create.blade.php
   ├── edit.blade.php
   └── show.blade.php (avec calendrier, sports, carte)

🔗 Routes:
   - GET    /admin/competition-sites
   - GET    /admin/competition-sites/create
   - POST   /admin/competition-sites
   - GET    /admin/competition-sites/{id}/edit
   - PUT    /admin/competition-sites/{id}
   - DELETE /admin/competition-sites/{id}
```

---

#### 3. **❌ Gestion du Transport & Navettes**
**Dans l'app mobile :**
- Navettes gratuites JOJ (horaires, itinéraires)
- Ligne Express-JOJ
- Transport partenaires
- Points d'arrêt
- Horaires en temps réel

**État actuel :**
- ✅ API existe : `/api/transport/shuttles`
- ❌ **Pas d'interface web** pour gérer ces données
- ❌ **Pas de modèle** pour les navettes/transports
- ❌ **Pas de migration** pour la table

**À créer :**
```
📁 database/migrations/
   └── create_shuttles_table.php
   └── create_shuttle_stops_table.php
   └── create_shuttle_schedules_table.php

📁 app/Models/
   └── Shuttle.php
   └── ShuttleStop.php
   └── ShuttleSchedule.php

📁 app/Http/Controllers/Web/
   └── TransportManagementController.php

📁 resources/views/transport/
   ├── index.blade.php (liste des navettes)
   ├── create.blade.php
   ├── edit.blade.php
   ├── stops.blade.php (gestion des arrêts)
   └── schedules.blade.php (gestion des horaires)

🔗 Routes:
   - GET    /admin/transport
   - GET    /admin/transport/create
   - POST   /admin/transport
   - GET    /admin/transport/{id}/edit
   - PUT    /admin/transport/{id}
   - DELETE /admin/transport/{id}
   - GET    /admin/transport/{id}/stops
   - GET    /admin/transport/{id}/schedules
```

---

#### 4. **❌ Gestion des Utilisateurs Mobile**
**Dans l'app mobile :**
- Profil utilisateur
- Historique des alertes/signalements
- Statistiques personnelles
- Paramètres

**État actuel :**
- ✅ API existe : `/api/user/profile`
- ❌ **Pas d'interface web** pour gérer les utilisateurs mobile
- ✅ Modèle `User` existe
- ❌ **Pas de contrôleur web** pour la gestion

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── MobileUserController.php

📁 resources/views/mobile-users/
   ├── index.blade.php (liste avec filtres)
   ├── show.blade.php (profil + historique)
   └── edit.blade.php (modifier statut/permissions)

🔗 Routes:
   - GET    /admin/mobile-users
   - GET    /admin/mobile-users/{id}
   - PUT    /admin/mobile-users/{id}/status
   - POST   /admin/mobile-users/{id}/notify
```

---

#### 5. **❌ Gestion des Partenaires**
**Dans l'app mobile :**
- Hôtels partenaires
- Restaurants partenaires
- Sponsors
- Partenaires officiels

**État actuel :**
- ✅ Modèle `Partner` existe
- ✅ Migration `create_partners_table` existe
- ❌ **Pas d'interface web** pour gérer les partenaires
- ❌ **Pas de contrôleur web** pour la gestion

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── PartnerManagementController.php

📁 resources/views/partners/
   ├── index.blade.php (liste avec filtres)
   ├── create.blade.php
   ├── edit.blade.php
   └── show.blade.php (détails avec carte)

🔗 Routes:
   - GET    /admin/partners
   - GET    /admin/partners/create
   - POST   /admin/partners
   - GET    /admin/partners/{id}/edit
   - PUT    /admin/partners/{id}
   - DELETE /admin/partners/{id}
```

---

#### 6. **❌ Page Statistiques**
**Dans le menu :**
- Statistiques détaillées
- Graphiques avancés
- Export de données

**État actuel :**
- ✅ Dashboard principal avec statistiques de base
- ❌ **Pas de page dédiée** avec statistiques avancées

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── StatisticsController.php

📁 resources/views/statistics/
   └── index.blade.php (graphiques, tableaux, export)

🔗 Routes:
   - GET    /admin/statistics
```

---

#### 7. **❌ Page Joindre/Contact**
**Dans le menu :**
- Formulaire de contact
- Support

**État actuel :**
- ❌ **Rien n'existe**

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── ContactController.php

📁 resources/views/contact/
   └── index.blade.php

🔗 Routes:
   - GET    /admin/contact
   - POST   /admin/contact
```

---

## 📊 Récapitulatif

### Fonctionnalités complètes : 5/12 (42%)
- ✅ Alertes SOS
- ✅ Alertes Médicales
- ✅ Signalements
- ✅ Annonces Audio
- ✅ Notifications Push

### Fonctionnalités manquantes : 7/12 (58%)
- ❌ Tourisme & Services Utiles
- ❌ Sites de Compétition JOJ
- ❌ Transport & Navettes
- ❌ Utilisateurs Mobile
- ❌ Partenaires
- ❌ Statistiques (page dédiée)
- ❌ Contact/Joindre

---

## 🎯 Priorités de Développement

### 🔴 PRIORITÉ HAUTE
1. **Gestion des Partenaires** (déjà dans le menu, modèle existe)
2. **Gestion du Tourisme** (API existe, modèle existe)
3. **Gestion des Utilisateurs Mobile** (API existe, modèle existe)

### 🟡 PRIORITÉ MOYENNE
4. **Gestion des Sites de Compétition JOJ** (API existe, mais pas de modèle)
5. **Gestion du Transport** (API existe, mais pas de modèle)
6. **Page Statistiques** (dashboard existe, mais page dédiée manquante)

### 🟢 PRIORITÉ BASSE
7. **Page Contact/Joindre** (simple formulaire)

---

*Document créé le 19 janvier 2025*
