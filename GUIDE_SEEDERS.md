# Guide des Seeders - Teranga Pass

## 📊 Vue d'ensemble

Tous les seeders ont été créés pour remplir votre base de données avec des données de test réalistes pour les Jeux Olympiques de la Jeunesse 2026 à Dakar.

---

## 📋 Liste des Seeders

### 1. ✅ ZoneSeeder
**Données créées :** 5 zones géographiques
- Dakar Centre
- M'Bour 4 Stadium
- Plateau
- Ouakam
- Almadies

### 2. ✅ UserSeeder
**Données créées :** 7 utilisateurs
- 1 admin (`admin@terangapass.com` / `password`)
- 6 utilisateurs mobiles (visiteurs, athlètes, volontaires)

### 3. ✅ PartnerSeeder
**Données créées :** 12 partenaires
- 3 Hôtels (Radisson, Pullman, Terrou-Bi)
- 3 Restaurants (Chez Loutcha, Le Ngor, La Fourchette)
- 2 Pharmacies
- 2 Hôpitaux
- 2 Ambassades (France, USA)

### 4. ✅ CompetitionSiteSeeder
**Données créées :** 6 sites de compétition
- Stade Olympique de Dakar
- Dakar Arena
- Piscine Olympique
- Complexe Sportif de M'Bour
- Centre Équestre
- Terrain de Beach Volley

### 5. ✅ ShuttleSeeder
**Données créées :** 3 navettes
- Navettes Gratuites JOJ 2026 (avec arrêts et horaires)
- Ligne Express-JOJ vers M'Bour
- Navette Almadies - Centre

### 6. ✅ AudioAnnouncementSeeder
**Données créées :** 6 annonces audio
- Consignes de sécurité (FR/EN)
- Navettes gratuites (FR/EN)
- Météo du jour
- Horaires des compétitions

### 7. ✅ NotificationSeeder
**Données créées :** 6 notifications
- Alertes sécurité
- Informations transport
- Météo
- Consignes JOJ
- Sécurité routière
- Circulation

### 8. ✅ AlertSeeder
**Données créées :** 4 alertes
- Alertes SOS résolues/en cours/en attente
- Alertes médicales

### 9. ✅ IncidentSeeder
**Données créées :** 4 incidents
- Pertes d'objets
- Accidents
- Comportements suspects

---

## 🚀 Comment Utiliser les Seeders

### Option 1 : Exécuter tous les seeders

```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan migrate:fresh --seed
```

**⚠️ ATTENTION :** Cette commande va :
- Supprimer toutes les tables
- Recréer toutes les tables
- Remplir avec les données de seeders

### Option 2 : Exécuter uniquement les seeders (sans recréer les tables)

```bash
php artisan db:seed
```

### Option 3 : Exécuter un seeder spécifique

```bash
# Exemple : Seeder des zones uniquement
php artisan db:seed --class=ZoneSeeder

# Exemple : Seeder des utilisateurs uniquement
php artisan db:seed --class=UserSeeder
```

---

## 📊 Données de Test Créées

### Utilisateurs de Test

| Email | Password | Type | Description |
|-------|----------|------|-------------|
| `admin@terangapass.com` | `password` | Admin | Administrateur du système |
| `amadou.diallo@example.com` | `password` | Visitor | Visiteur sénégalais |
| `mariama.sarr@example.com` | `password` | Athlete | Athlète sénégalaise |
| `john.smith@example.com` | `password` | Visitor | Visiteur américain |
| `sophie.martin@example.com` | `password` | Volunteer | Volontaire française |

### Zones Créées

- **Dakar Centre** : Zone centrale (150 000 habitants)
- **M'Bour 4 Stadium** : Zone du stade (50 000 habitants)
- **Plateau** : Quartier administratif (80 000 habitants)
- **Ouakam** : Quartier résidentiel (60 000 habitants)
- **Almadies** : Zone touristique (40 000 habitants)

### Sites de Compétition

1. **Stade Olympique de Dakar** (60 000 places)
   - Sports : Athlétisme, Cérémonies
   - Dates : 16-23 août 2026

2. **Dakar Arena** (8 000 places)
   - Sports : Escrime, Badminton, Tennis de table
   - Dates : 16-23 août 2026

3. **Piscine Olympique** (5 000 places)
   - Sports : Natation, Water-polo
   - Dates : 16-22 août 2026

4. **Complexe Sportif de M'Bour** (12 000 places)
   - Sports : Basketball, Volleyball
   - Dates : 16-23 août 2026

5. **Centre Équestre** (3 000 places)
   - Sports : Équitation
   - Dates : 17-21 août 2026

6. **Terrain de Beach Volley** (2 000 places)
   - Sports : Beach Volley
   - Dates : 16-23 août 2026

---

## ✅ Vérification après Exécution

### Vérifier le nombre de données créées

```bash
# Dans tinker
php artisan tinker

# Puis dans tinker :
User::count()              // Devrait retourner 7
Zone::count()              // Devrait retourner 5
Partner::count()           // Devrait retourner 12
CompetitionSite::count()   // Devrait retourner 6
Shuttle::count()           // Devrait retourner 3
AudioAnnouncement::count() // Devrait retourner 6
Notification::count()      // Devrait retourner 6
Alert::count()             // Devrait retourner 4
Incident::count()          // Devrait retourner 4
```

### Vérifier dans le Dashboard Laravel

1. **Ouvrir le dashboard** : `http://localhost:8000/admin`
2. **Se connecter** avec `admin@terangapass.com` / `password`
3. **Vérifier chaque section** :
   - ✅ Utilisateurs : 7 utilisateurs
   - ✅ Zones : 5 zones
   - ✅ Partenaires : 12 partenaires
   - ✅ Sites JOJ : 6 sites
   - ✅ Transport : 3 navettes
   - ✅ Annonces Audio : 6 annonces
   - ✅ Notifications : 6 notifications
   - ✅ Alertes : 4 alertes
   - ✅ Signalements : 4 incidents

---

## 🔄 Réinitialiser les Données

Si vous voulez recommencer avec des données propres :

```bash
# Supprimer toutes les tables et recréer avec les seeders
php artisan migrate:fresh --seed

# OU simplement vider les tables et réexécuter les seeders
php artisan migrate:refresh --seed
```

---

## 📝 Modifier les Données de Test

Si vous voulez modifier ou ajouter des données de test :

1. **Ouvrir le fichier seeder** correspondant dans `database/seeders/`
2. **Modifier les données** dans le tableau `$data`
3. **Réexécuter le seeder** :
   ```bash
   php artisan db:seed --class=NomDuSeeder
   ```

---

## ⚠️ Notes Importantes

1. **Ordre d'exécution** : Les seeders sont exécutés dans un ordre spécifique :
   - Zones → Users → Partenaires → Sites → Navettes → Annonces → Notifications → Alertes → Incidents

2. **Dépendances** : Certains seeders dépendent d'autres :
   - `AlertSeeder` et `IncidentSeeder` nécessitent des utilisateurs
   - `NotificationSeeder` utilise des zones

3. **Données réalistes** : Toutes les données sont basées sur de vraies localisations à Dakar et des informations réalistes pour les JOJ 2026.

---

## 🎯 Prochaines Étapes

1. **Exécuter les seeders** :
   ```bash
   php artisan migrate:fresh --seed
   ```

2. **Vérifier dans le dashboard** que toutes les données sont présentes

3. **Tester l'application mobile** pour voir les données dynamiques

4. **Créer vos propres données** via le dashboard ou les seeders

---

**Les seeders sont prêts à être utilisés !** 🚀

*Document créé le 20 janvier 2025*
