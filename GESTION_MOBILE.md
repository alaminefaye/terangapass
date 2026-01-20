# Gestion de l'Application Mobile depuis le Dashboard Web

## 📊 État Actuel de la Gestion Mobile

### ✅ CE QUI EXISTE (Lecture/Monitoring)

#### 1. **Monitoring des Données**
Le dashboard web peut **voir** les données de l'application mobile :

- ✅ **Statistiques générales** (Dashboard)
  - Nombre d'alertes SOS reçues
  - Nombre d'alertes médicales
  - Nombre de signalements d'incidents
  - Nombre d'utilisateurs
  - Statistiques par pays

- ✅ **API de lecture** (existant)
  - `GET /api/alerts/history` - Historique des alertes
  - `GET /api/incidents/history` - Historique des signalements
  - `GET /api/notifications` - Liste des notifications
  - `GET /api/announcements/audio` - Liste des annonces audio
  - `GET /api/user/profile` - Profil utilisateur

- ✅ **Carte interactive** (Dashboard)
  - Visualisation des alertes SOS (pins rouges)
  - Visualisation des alertes médicales (pins bleus)
  - Visualisation des hôtels/restaurants (pins orange/verts)

- ✅ **Graphiques et tableaux** (Dashboard)
  - Tendances des alertes
  - Répartition géographique
  - Statistiques temporelles

---

## ❌ CE QUI MANQUE (Gestion/Contrôle)

### 🔴 CRITIQUE - Gestion du Contenu Mobile

#### 1. **Gestion des Notifications Push** ⚠️ ABSENT
**Problème :** Impossible de créer/envoyer des notifications depuis le dashboard

**Ce qui manque :**
- ❌ **Interface web** pour créer des notifications
- ❌ **Formulaires de création** (titre, message, type, zone, etc.)
- ❌ **Système d'envoi push** (Firebase Cloud Messaging / APNs)
- ❌ **Programmation de notifications** (envoi différé)
- ❌ **Ciblage géographique** (envoyer à une zone spécifique)
- ❌ **Ciblage par type d'utilisateur** (athlète, visiteur, citoyen)
- ❌ **Statistiques d'envoi** (combien d'utilisateurs ont reçu/ouvert)

**Ce qui existe :**
- ✅ API `GET /api/notifications` (lecture uniquement)
- ✅ Modèle `Notification` en base de données
- ✅ Table `notifications` avec champs (title, message, type, zone, etc.)

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── NotificationManagementController.php (CRUD complet)

📁 resources/views/notifications/
   ├── index.blade.php (liste)
   ├── create.blade.php (créer)
   ├── edit.blade.php (modifier)
   └── show.blade.php (détails)

📁 app/Services/
   └── PushNotificationService.php (envoi FCM/APNs)

🔗 Routes:
   - GET    /admin/notifications
   - GET    /admin/notifications/create
   - POST   /admin/notifications
   - GET    /admin/notifications/{id}/edit
   - PUT    /admin/notifications/{id}
   - POST   /admin/notifications/{id}/send (envoyer maintenant)
   - DELETE /admin/notifications/{id}
```

---

#### 2. **Gestion des Annonces Audio** ⚠️ ABSENT
**Problème :** Impossible de créer/modifier/supprimer des annonces audio depuis le dashboard

**Ce qui manque :**
- ❌ **Interface web** pour upload de fichiers audio
- ❌ **Formulaires de création** (titre, description, fichier audio, langue, zone)
- ❌ **Gestion multilingue** (FR, EN, ES)
- ❌ **Programmation des annonces** (date de publication/dépublication)
- ❌ **Statistiques d'écoute** (nombre de lectures, zones les plus écoutées)
- ❌ **Prévisualisation audio** avant publication

**Ce qui existe :**
- ✅ API `GET /api/announcements/audio` (lecture uniquement)
- ✅ Modèle `AudioAnnouncement` en base de données
- ✅ Table `audio_announcements` avec champs

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── AudioAnnouncementManagementController.php

📁 resources/views/audio-announcements/
   ├── index.blade.php
   ├── create.blade.php
   ├── edit.blade.php
   └── show.blade.php

📁 app/Services/
   └── AudioStorageService.php (gestion fichiers audio)

🔗 Routes:
   - GET    /admin/audio-announcements
   - GET    /admin/audio-announcements/create
   - POST   /admin/audio-announcements
   - GET    /admin/audio-announcements/{id}/edit
   - PUT    /admin/audio-announcements/{id}
   - DELETE /admin/audio-announcements/{id}
   - POST   /admin/audio-announcements/{id}/publish
```

---

#### 3. **Gestion des Alertes** ⚠️ PARTIELLEMENT
**Problème :** Les alertes sont reçues mais pas gérées depuis le dashboard

**Ce qui manque :**
- ❌ **Interface web** pour voir et gérer les alertes
- ❌ **Assignation des alertes** aux services compétents
- ❌ **Statut des alertes** (en attente, en cours, résolue, archivée)
- ❌ **Historique des interventions**
- ❌ **Notes et commentaires** sur les alertes
- ❌ **Export des alertes** (PDF, Excel)

**Ce qui existe :**
- ✅ API `POST /api/sos/alert` et `POST /api/medical/alert` (réception)
- ✅ API `GET /api/alerts/history` (lecture)
- ✅ Modèle `Alert` en base de données

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── AlertManagementController.php

📁 resources/views/alerts/
   ├── index.blade.php (liste avec filtres)
   ├── show.blade.php (détails avec carte)
   └── assign.blade.php (assigner à un service)

🔗 Routes:
   - GET    /admin/alerts
   - GET    /admin/alerts/{id}
   - PUT    /admin/alerts/{id}/status (changer statut)
   - POST   /admin/alerts/{id}/assign (assigner)
   - POST   /admin/alerts/{id}/resolve (marquer résolue)
```

---

#### 4. **Gestion des Signalements** ⚠️ PARTIELLEMENT
**Problème :** Les signalements sont reçus mais pas gérés depuis le dashboard

**Ce qui manque :**
- ❌ **Interface web** pour voir et gérer les signalements
- ❌ **Validation des signalements** (accepter/rejeter)
- ❌ **Assignation aux autorités compétentes**
- ❌ **Visualisation des photos/audio** depuis le dashboard
- ❌ **Statut des signalements** (en attente, validé, traité, résolu)
- ❌ **Export des signalements**

**Ce qui existe :**
- ✅ API `POST /api/incidents/report` (réception)
- ✅ API `GET /api/incidents/history` (lecture)
- ✅ Modèle `Incident` en base de données

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── IncidentManagementController.php

📁 resources/views/incidents/
   ├── index.blade.php
   ├── show.blade.php (avec photos/audio)
   └── validate.blade.php (valider un signalement)

🔗 Routes:
   - GET    /admin/incidents
   - GET    /admin/incidents/{id}
   - PUT    /admin/incidents/{id}/status
   - POST   /admin/incidents/{id}/validate
   - POST   /admin/incidents/{id}/assign
```

---

#### 5. **Gestion des Utilisateurs Mobile** ⚠️ PARTIELLEMENT
**Problème :** Pas d'interface pour gérer spécifiquement les utilisateurs mobile

**Ce qui manque :**
- ❌ **Liste des utilisateurs mobile** avec filtres
- ❌ **Statistiques par utilisateur** (nombre d'alertes, signalements)
- ❌ **Désactiver/Activer un compte mobile**
- ❌ **Voir l'historique d'un utilisateur**
- ❌ **Gérer les permissions** (bloquer certaines fonctionnalités)
- ❌ **Notifications aux utilisateurs** (message direct)

**Ce qui existe :**
- ✅ API `GET /api/user/profile` (lecture profil)
- ✅ Modèle `User` en base de données

**À créer :**
```
📁 app/Http/Controllers/Web/
   └── MobileUserController.php

📁 resources/views/mobile-users/
   ├── index.blade.php
   ├── show.blade.php (profil + historique)
   └── edit.blade.php (modifier statut/permissions)

🔗 Routes:
   - GET    /admin/mobile-users
   - GET    /admin/mobile-users/{id}
   - PUT    /admin/mobile-users/{id}/status
   - POST   /admin/mobile-users/{id}/notify (notifier directement)
```

---

#### 6. **Gestion des Tokens de Notifications Push** ⚠️ ABSENT
**Problème :** Pas de système pour gérer les tokens FCM/APNs des utilisateurs mobile

**Ce qui manque :**
- ❌ **Stockage des tokens** (table `device_tokens` ou colonne dans `users`)
- ❌ **API pour enregistrer les tokens** depuis l'app mobile
- ❌ **Gestion des tokens** (vérifier si valide, nettoyer les anciens)
- ❌ **Ciblage par token** pour notifications spécifiques

**À créer :**
```
📁 database/migrations/
   └── create_device_tokens_table.php

📁 app/Models/
   └── DeviceToken.php

📁 app/Http/Controllers/Api/
   └── DeviceTokenController.php (register/update token)

📁 app/Services/
   └── PushNotificationService.php (utilise les tokens)
```

---

### 🟡 IMPORTANT - Fonctionnalités de Contrôle

#### 7. **Gestion de la Maintenance** ⚠️ ABSENT
**Fonctionnalités manquantes :**
- ❌ **Mode maintenance** (désactiver l'app pour tous les utilisateurs)
- ❌ **Messages de maintenance** affichés dans l'app
- ❌ **Désactivation temporaire** de certaines fonctionnalités
- ❌ **Statut de l'API** (vérifier si l'API est en ligne)

---

#### 8. **Gestion des Versions de l'App** ⚠️ ABSENT
**Fonctionnalités manquantes :**
- ❌ **Gestion des versions** (version actuelle, versions supportées)
- ❌ **Forcer la mise à jour** (obliger les utilisateurs à mettre à jour)
- ❌ **Messages de mise à jour** (informer les utilisateurs)
- ❌ **Statistiques de versions** (combien d'utilisateurs sur chaque version)

---

#### 9. **Analytics et Monitoring Mobile** ⚠️ PARTIELLEMENT
**Ce qui manque :**
- ❌ **Dashboard analytics** (nombre d'utilisateurs actifs, temps d'utilisation)
- ❌ **Erreurs et crash reports** depuis l'app mobile
- ❌ **Performance monitoring** (temps de réponse API, latence)
- ❌ **Géolocalisation en temps réel** des utilisateurs actifs (carte live)

---

#### 10. **Gestion des Zones Géographiques** ⚠️ ABSENT
**Problème :** Pas de système pour définir les zones pour le ciblage

**Ce qui manque :**
- ❌ **Interface pour créer/gérer des zones** (polygones sur carte)
- ❌ **Noms de zones** (Dakar Plateau, Ouakam, etc.)
- ❌ **Ciblage par zone** pour notifications/annonces

**À créer :**
```
📁 database/migrations/
   └── create_zones_table.php

📁 app/Models/
   └── Zone.php

📁 app/Http/Controllers/Web/
   └── ZoneController.php

📁 resources/views/zones/
   ├── index.blade.php
   └── create.blade.php (avec carte pour dessiner zone)
```

---

## 📋 Récapitulatif - Ce qui doit être créé

### 🔴 PRIORITÉ HAUTE (Fonctionnellement critique)

1. **Gestion des Notifications Push**
   - Interface web CRUD
   - Service d'envoi FCM/APNs
   - Système de tokens

2. **Gestion des Annonces Audio**
   - Interface web CRUD
   - Upload fichiers audio
   - Gestion multilingue

3. **Gestion des Alertes** (completer)
   - Interface web complète
   - Assignation et statuts

4. **Gestion des Signalements** (completer)
   - Interface web complète
   - Validation et traitement

---

### 🟡 PRIORITÉ MOYENNE (Important mais pas bloquant)

5. **Gestion des Utilisateurs Mobile**
   - Interface dédiée
   - Statistiques par utilisateur

6. **Gestion des Zones**
   - Système de zones géographiques
   - Ciblage par zone

7. **Analytics Mobile**
   - Dashboard analytics
   - Crash reports

---

### 🟢 PRIORITÉ BASSE (Améliorations)

8. **Mode Maintenance**
9. **Gestion des Versions**
10. **Monitoring en temps réel**

---

## 🛠️ Architecture Recommandée

### Structure de Fichiers

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── Web/
│   │   │   ├── NotificationManagementController.php
│   │   │   ├── AudioAnnouncementManagementController.php
│   │   │   ├── AlertManagementController.php
│   │   │   ├── IncidentManagementController.php
│   │   │   ├── MobileUserController.php
│   │   │   └── ZoneController.php
│   │   └── Api/
│   │       └── DeviceTokenController.php (enregistrer tokens)
│   └── Services/
│       ├── PushNotificationService.php
│       ├── AudioStorageService.php
│       └── MobileAnalyticsService.php

resources/
└── views/
    ├── notifications/
    ├── audio-announcements/
    ├── alerts/
    ├── incidents/
    ├── mobile-users/
    └── zones/

database/
└── migrations/
    ├── create_device_tokens_table.php
    └── create_zones_table.php
```

---

## 🚀 Plan d'Action Recommandé

### Phase 1 (Semaine 1-2) - Fondations
1. Créer système de tokens (device_tokens)
2. Créer PushNotificationService avec FCM/APNs
3. Créer interface de gestion des notifications

### Phase 2 (Semaine 3-4) - Contenu
1. Créer interface de gestion des annonces audio
2. Compléter gestion des alertes
3. Compléter gestion des signalements

### Phase 3 (Semaine 5-6) - Utilisateurs et Zones
1. Créer interface gestion utilisateurs mobile
2. Créer système de zones géographiques
3. Ajouter analytics de base

---

*Document créé le 19 janvier 2025*
