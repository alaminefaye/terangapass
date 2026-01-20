# Vérification de la Connexion API Mobile - Teranga Pass

## ✅ Corrections Effectuées

### 1. ✅ Routes API ajoutées dans `bootstrap/app.php`
**Problème :** Les routes API n'étaient pas chargées.

**Correction :** Ajout de `api: __DIR__.'/../routes/api.php'` dans la configuration.

### 2. ✅ Méthode `getUserFromToken()` ajoutée dans `AlertController`
**Problème :** La méthode `sendSOS()` utilisait `$request->user()->id` sans middleware d'authentification.

**Correction :** Utilisation de `getUserFromToken()` comme les autres méthodes.

### 3. ✅ Configuration CORS créée
**Problème :** Pas de fichier `config/cors.php`.

**Correction :** Fichier CORS créé avec configuration permissive pour le développement.

---

## 🧪 Comment Vérifier la Connexion

### Étape 1 : Démarrer le serveur Laravel

```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan serve --host=0.0.0.0 --port=8000
```

**Important :** Utilisez `--host=0.0.0.0` pour permettre les connexions depuis le réseau local (appareil physique).

### Étape 2 : Exécuter le script de test

```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
./test_api_connection.sh
```

Ce script teste automatiquement :
1. ✅ Connexion au serveur
2. ✅ Inscription d'un utilisateur
3. ✅ Connexion d'un utilisateur
4. ✅ Requête authentifiée (profil)
5. ✅ Envoi d'alerte SOS
6. ✅ Récupération de données

### Étape 3 : Tester manuellement avec cURL

#### Test 1 : Vérifier que l'API répond
```bash
curl http://localhost:8000/api/announcements/audio
```

**Résultat attendu :**
```json
{"data":[]}
```

#### Test 2 : Tester l'inscription
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
  "user": {
    "id": 1,
    "name": "Test User",
    "email": "test@example.com",
    ...
  },
  "token": "base64_encoded_token"
}
```

#### Test 3 : Tester la connexion
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Résultat attendu :** Même format que l'inscription avec un token.

#### Test 4 : Tester avec token (remplacez TOKEN par le token reçu)
```bash
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

---

## 📱 Test depuis l'Application Flutter

### Configuration Préalable

1. **Vérifier l'URL de base dans `api_constants.dart`**
   ```dart
   static const String _mode = 'dev'; // ou 'android_emulator'
   ```

2. **Démarrer le serveur Laravel**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

3. **Lancer l'application Flutter**
   ```bash
   cd terangapassapp
   flutter run
   ```

### Tests dans l'Application

#### Test 1 : Connexion
1. Ouvrir l'application
2. Aller à l'écran de connexion
3. Créer un compte ou se connecter
4. ✅ **Succès** : Navigation vers HomeScreen
5. ❌ **Erreur** : Vérifier les logs Flutter (`flutter run`)

#### Test 2 : Envoi d'alerte SOS
1. Cliquer sur "SOS Urgence"
2. Autoriser la localisation
3. Cliquer sur "Envoyer"
4. ✅ **Succès** : Message de confirmation
5. ❌ **Erreur** : Vérifier les logs

#### Test 3 : Récupération de données
1. Ouvrir "Annonces Audio"
2. ✅ **Succès** : Liste affichée (même vide `{"data":[]}`)
3. ❌ **Erreur** : Données de démonstration affichées (normal si l'API échoue)

---

## 🔍 Vérification des Logs

### Logs Laravel
```bash
tail -f storage/logs/laravel.log
```

### Logs Flutter
Dans le terminal où vous avez lancé `flutter run`, vous verrez :
- Les requêtes HTTP
- Les erreurs de connexion
- Les erreurs d'authentification

---

## ⚠️ Problèmes Courants

### Problème 1 : "Connection refused" sur Android Emulator

**Solution :** Changez l'URL dans `api_constants.dart` :
```dart
static const String _mode = 'android_emulator';
```

### Problème 2 : "CORS policy" dans le navigateur

**Solution :** Vérifiez que CORS est bien configuré :
```bash
php artisan config:clear
php artisan config:cache
```

### Problème 3 : "401 Unauthorized"

**Causes :**
- Token non sauvegardé après connexion
- Token non envoyé dans les headers
- Token expiré ou invalide

**Solution :** Vérifiez dans les logs Flutter que le token est bien sauvegardé et ajouté aux headers.

### Problème 4 : "500 Internal Server Error"

**Solution :** Vérifiez les logs Laravel pour voir l'erreur exacte.

---

## ✅ Format des Réponses API

### Authentification (Login/Register)
```json
{
  "user": {...},
  "token": "base64_encoded_token"
}
```

### Liste de données (GET)
```json
{
  "data": [...]
}
```

### Objet unique (GET)
```json
{
  "data": {...}
}
```

### Création (POST)
```json
{
  "message": "Success message",
  "alert": {...} // ou "incident", etc.
}
```

---

## 📊 Statut de Compatibilité

### ✅ Compatible
- **Format des réponses** : Compatible ✅
- **Authentification** : Compatible ✅
- **Headers** : Compatible ✅
- **Gestion des erreurs** : Compatible ✅

### ⚠️ À Vérifier
- **CORS** : Configuration créée, à tester
- **Authentification** : Token simple (à remplacer par Sanctum plus tard)
- **URL de base** : À configurer selon l'environnement

---

## 🎯 Conclusion

**L'application mobile peut se connecter correctement à l'API web** si :

1. ✅ Le serveur Laravel est démarré
2. ✅ L'URL de base est configurée correctement dans `api_constants.dart`
3. ✅ Les migrations sont exécutées (`php artisan migrate`)
4. ✅ CORS est configuré (fichier créé)

**Pour tester maintenant :**
```bash
# Terminal 1 : Démarrer le serveur
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 : Exécuter les tests
./test_api_connection.sh
```

**Si tous les tests passent, l'intégration est fonctionnelle !** ✅

---

*Document créé le 20 janvier 2025*
