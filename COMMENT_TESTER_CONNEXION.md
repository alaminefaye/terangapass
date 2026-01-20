# Comment Tester la Connexion API Mobile - Guide Rapide

## 🎯 Objectif

Vérifier que l'application mobile Flutter se connecte correctement à l'API web Laravel.

---

## ✅ Corrections Effectuées

1. ✅ **Routes API configurées** dans `bootstrap/app.php`
2. ✅ **Configuration CORS créée** dans `config/cors.php`
3. ✅ **Méthode `getUserFromToken()` ajoutée** dans `AlertController`
4. ✅ **Script de test automatique créé** : `test_api_connection.sh`

---

## 🚀 Test Rapide (3 étapes)

### Étape 1 : Démarrer le serveur Laravel

**Terminal 1 :**
```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan serve --host=0.0.0.0 --port=8000
```

**Important :** Utilisez `--host=0.0.0.0` pour permettre les connexions depuis le réseau local (nécessaire pour les appareils physiques).

### Étape 2 : Exécuter les tests automatiques

**Terminal 2 :**
```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
./test_api_connection.sh
```

Ce script teste automatiquement :
- ✅ Connexion au serveur
- ✅ Inscription d'un utilisateur
- ✅ Connexion d'un utilisateur
- ✅ Requête authentifiée (profil)
- ✅ Envoi d'alerte SOS
- ✅ Récupération de données

### Étape 3 : Tester depuis l'application Flutter

1. **Configurer l'URL dans `api_constants.dart`** :
   ```dart
   static const String _mode = 'dev'; // ou 'android_emulator'
   ```

2. **Lancer l'application Flutter** :
   ```bash
   cd terangapassapp
   flutter run
   ```

3. **Tester la connexion** :
   - Ouvrir l'écran de connexion
   - Créer un compte ou se connecter
   - ✅ **Si la navigation vers HomeScreen fonctionne** : La connexion est réussie !
   - ❌ **Si une erreur apparaît** : Vérifier les logs dans le terminal Flutter

---

## 🧪 Test Manuel avec cURL

### Test 1 : Vérifier que l'API répond
```bash
curl http://localhost:8000/api/announcements/audio
```

**Résultat attendu :** `{"data":[]}`

### Test 2 : Test d'inscription
```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"password123"}'
```

**Résultat attendu :** JSON avec `user` et `token`

### Test 3 : Test de connexion
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password123"}'
```

**Résultat attendu :** JSON avec `user` et `token`

---

## ✅ Format des Réponses API (Compatibilité Flutter)

### Authentification (Login/Register)
```json
{
  "user": {...},
  "token": "base64_encoded_token"
}
```
✅ **Compatible avec Flutter** : `response.data['token']` ✅

### Liste de données (GET)
```json
{
  "data": [...]
}
```
✅ **Compatible avec Flutter** : `response.data['data'] ?? []` ✅

### Objet unique (GET)
```json
{
  "data": {...}
}
```
✅ **Compatible avec Flutter** : `response.data['data'] ?? {}` ✅

### Création (POST)
```json
{
  "message": "Success message",
  "alert": {...}
}
```
✅ **Compatible avec Flutter** : `response.data['alert']` ✅

---

## 🔍 Vérification Rapide

### Checklist de Vérification

- [ ] Serveur Laravel démarré (`php artisan serve --host=0.0.0.0 --port=8000`)
- [ ] Migrations exécutées (`php artisan migrate`)
- [ ] Test cURL de base réussi (`curl http://localhost:8000/api/announcements/audio`)
- [ ] Test d'inscription réussi
- [ ] Test de connexion réussi
- [ ] URL de base configurée dans `api_constants.dart`
- [ ] Application Flutter se connecte correctement
- [ ] Token sauvegardé après connexion
- [ ] Requêtes authentifiées fonctionnent

---

## ⚠️ Problèmes Courants et Solutions

### "Connection refused" sur Android Emulator
**Solution :** Changez `_mode` à `'android_emulator'` dans `api_constants.dart`

### "CORS policy" dans le navigateur
**Solution :** Vérifiez que `config/cors.php` existe et exécutez :
```bash
php artisan config:clear
php artisan config:cache
```

### "401 Unauthorized"
**Solution :** Vérifiez que le token est bien sauvegardé après la connexion dans les logs Flutter

### "500 Internal Server Error"
**Solution :** Vérifiez les logs Laravel :
```bash
tail -f storage/logs/laravel.log
```

---

## 📊 Résultat

**L'application mobile peut se connecter correctement à l'API web** si :

1. ✅ Le serveur Laravel est démarré avec `--host=0.0.0.0`
2. ✅ L'URL de base est configurée selon l'environnement
3. ✅ Les migrations sont exécutées
4. ✅ Les tests cURL passent

**Si tous les tests passent, l'intégration est fonctionnelle !** ✅

---

## 🎯 Prochaines Étapes

1. **Exécuter le script de test** : `./test_api_connection.sh`
2. **Vérifier les résultats** : Tous les tests doivent passer
3. **Tester depuis l'app Flutter** : Se connecter et vérifier que tout fonctionne
4. **Vérifier les logs** : S'assurer qu'il n'y a pas d'erreurs

---

*Document créé le 20 janvier 2025*
