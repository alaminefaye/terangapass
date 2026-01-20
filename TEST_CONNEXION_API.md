# Test de Connexion API - Teranga Pass Mobile

## 🔧 Problèmes Identifiés et Corrigés

### ✅ Problème 1 : `sendSOS()` utilise `$request->user()`
**Problème :** `AlertController::sendSOS()` utilisait `$request->user()->id` alors qu'il n'y a pas de middleware d'authentification configuré.

**Solution :** ✅ Corrigé pour utiliser `getUserFromToken()` comme les autres méthodes.

### ✅ Problème 2 : Méthode `getUserFromToken()` manquante
**Problème :** `AlertController` n'avait pas la méthode `getUserFromToken()`.

**Solution :** ✅ Méthode ajoutée dans `AlertController`.

### ✅ Problème 3 : Configuration CORS
**Problème :** Pas de fichier `config/cors.php`.

**Solution :** ✅ Fichier CORS créé avec configuration permissive pour développement.

---

## 🧪 Comment Tester la Connexion

### Option 1 : Test avec cURL (Terminal)

#### Test 1 : Vérifier que le serveur répond
```bash
curl -X GET http://localhost:8000/api/announcements/audio
```

**Résultat attendu :** 
```json
{"data":[]}
```

#### Test 2 : Test d'inscription
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Résultat attendu :**
```json
{
  "user": {...},
  "token": "base64_token_here"
}
```

#### Test 3 : Test de connexion
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Résultat attendu :**
```json
{
  "user": {...},
  "token": "base64_token_here"
}
```

#### Test 4 : Test avec token (Requête authentifiée)
```bash
# Remplacez TOKEN par le token reçu lors de la connexion
curl -X GET http://localhost:8000/api/user/profile \
  -H "Authorization: Bearer TOKEN"
```

**Résultat attendu :**
```json
{
  "data": {
    "id": 1,
    "name": "Test User",
    "email": "test@example.com",
    ...
  }
}
```

#### Test 5 : Test d'envoi d'alerte SOS
```bash
curl -X POST http://localhost:8000/api/sos/alert \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "latitude": 14.6928,
    "longitude": -17.4467,
    "address": "Dakar, Sénégal"
  }'
```

**Résultat attendu :**
```json
{
  "message": "SOS alert sent successfully",
  "alert": {...}
}
```

---

### Option 2 : Test avec Postman

1. **Créer une nouvelle requête**
   - Méthode : `POST`
   - URL : `http://localhost:8000/api/auth/login`
   - Headers : `Content-Type: application/json`
   - Body (raw JSON) :
     ```json
     {
       "email": "test@example.com",
       "password": "password123"
     }
     ```

2. **Tester l'inscription**
   - Méthode : `POST`
   - URL : `http://localhost:8000/api/auth/register`
   - Body :
     ```json
     {
       "name": "Test User",
       "email": "test@example.com",
       "password": "password123"
     }
     ```

3. **Tester une requête authentifiée**
   - Méthode : `GET`
   - URL : `http://localhost:8000/api/user/profile`
   - Headers : `Authorization: Bearer VOTRE_TOKEN`

---

### Option 3 : Test depuis l'Application Flutter

#### Configuration préalable

1. **Vérifier l'URL de base dans `api_constants.dart`**
   ```dart
   static const String _mode = 'dev'; // ou 'android_emulator'
   ```

2. **Démarrer le serveur Laravel**
   ```bash
   cd /Users/Zhuanz/Desktop/projets/web/terangapass
   php artisan serve --host=0.0.0.0 --port=8000
   ```

3. **Lancer l'application Flutter**

4. **Tester la connexion**
   - Ouvrir l'application
   - Aller à l'écran de connexion
   - Se connecter avec un compte existant ou créer un compte
   - Vérifier que la navigation vers HomeScreen fonctionne

#### Tests dans l'application

1. **Test de connexion**
   - Entrer email et mot de passe
   - Cliquer sur "Se connecter"
   - ✅ **Succès** : Navigation vers HomeScreen
   - ❌ **Erreur** : Message d'erreur affiché

2. **Test d'envoi d'alerte SOS**
   - Ouvrir l'écran SOS
   - Cliquer sur "Envoyer"
   - ✅ **Succès** : Message de confirmation
   - ❌ **Erreur** : Message d'erreur affiché

3. **Test de récupération des données**
   - Ouvrir "Annonces Audio"
   - ✅ **Succès** : Liste des annonces (même vide)
   - ❌ **Erreur** : Données de démonstration affichées

---

## 🔍 Vérifications à Faire

### 1. Vérifier que le serveur Laravel fonctionne

```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan serve
```

Ouvrir dans le navigateur : `http://localhost:8000`

### 2. Vérifier les routes API

```bash
php artisan route:list --path=api
```

### 3. Vérifier la base de données

```bash
php artisan migrate:status
```

Assurez-vous que toutes les migrations sont exécutées :
```bash
php artisan migrate
```

### 4. Vérifier les logs Laravel

```bash
tail -f storage/logs/laravel.log
```

---

## ⚠️ Problèmes Courants

### Problème : "Connection refused" sur Android Emulator

**Solution :** Utilisez `http://10.0.2.2:8000/api` au lieu de `localhost`

Dans `api_constants.dart` :
```dart
static const String _mode = 'android_emulator';
```

### Problème : "CORS policy" dans le navigateur

**Solution :** Le fichier `config/cors.php` a été créé. Vérifiez qu'il est chargé :

```bash
php artisan config:cache
php artisan config:clear
```

### Problème : "401 Unauthorized"

**Causes possibles :**
1. Token invalide ou expiré
2. Token non envoyé dans les headers
3. Format du token incorrect

**Solution :** Vérifiez que le token est bien sauvegardé après la connexion et ajouté aux headers.

### Problème : "500 Internal Server Error"

**Solution :** Vérifiez les logs Laravel :
```bash
tail -f storage/logs/laravel.log
```

---

## ✅ Checklist de Vérification

- [ ] Serveur Laravel démarré (`php artisan serve`)
- [ ] Migrations exécutées (`php artisan migrate`)
- [ ] Configuration CORS activée (`config/cors.php` existe)
- [ ] URL de base configurée dans `api_constants.dart`
- [ ] Test cURL de base réussi
- [ ] Test d'inscription réussi
- [ ] Test de connexion réussi
- [ ] Test de requête authentifiée réussi
- [ ] Application Flutter se connecte correctement
- [ ] Token sauvegardé après connexion
- [ ] Requêtes authentifiées fonctionnent

---

## 📊 Résultat Attendu

Si tout fonctionne correctement :

1. ✅ **Inscription/Connexion** : Token reçu et sauvegardé
2. ✅ **Requêtes authentifiées** : Données retournées avec le token
3. ✅ **Envoi d'alertes** : Alertes créées dans la base de données
4. ✅ **Récupération de données** : Données affichées dans l'app

---

## 🚀 Commandes de Test Rapide

```bash
# 1. Démarrer le serveur
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan serve --host=0.0.0.0 --port=8000

# 2. Dans un autre terminal, tester l'API
curl http://localhost:8000/api/announcements/audio

# 3. Tester l'inscription
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"password123"}'

# 4. Vérifier les routes
php artisan route:list --path=api
```

---

*Document créé le 20 janvier 2025*
