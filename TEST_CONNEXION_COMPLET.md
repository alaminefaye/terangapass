# Test de Connexion API - Guide Complet

## ✅ État : Prêt pour Test

Toutes les corrections ont été effectuées. L'application mobile peut maintenant se connecter à l'API web.

---

## 🚀 Test Rapide (2 minutes)

### Étape 1 : Démarrer le serveur Laravel

**Dans un terminal :**
```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
php artisan serve --host=0.0.0.0 --port=8000
```

**Résultat attendu :**
```
INFO  Server running on [http://0.0.0.0:8000]
```

### Étape 2 : Exécuter les tests automatiques

**Dans un autre terminal :**
```bash
cd /Users/Zhuanz/Desktop/projets/web/terangapass
./test_api_simple.sh
```

**Résultat attendu :** Tous les tests passent ✅

---

## 🧪 Tests Manuels avec cURL

### Test 1 : Vérifier que l'API répond

```bash
curl http://localhost:8000/api/announcements/audio
```

**✅ Succès :** `{"data":[]}`

**❌ Erreur :** Vérifier que le serveur est démarré

### Test 2 : Test d'inscription

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

**✅ Succès :** JSON avec `user` et `token`

**Exemple de réponse :**
```json
{
  "user": {
    "id": 1,
    "name": "Test User",
    "email": "test@example.com"
  },
  "token": "base64_encoded_token_here"
}
```

### Test 3 : Test de connexion

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**✅ Succès :** JSON avec `user` et `token`

### Test 4 : Test avec token (remplacez TOKEN)

```bash
# Remplacez TOKEN par le token reçu lors de la connexion
curl -X GET http://localhost:8000/api/user/profile \
  -H "Authorization: Bearer TOKEN" \
  -H "Accept: application/json"
```

**✅ Succès :** JSON avec `data` contenant le profil utilisateur

### Test 5 : Envoi d'alerte SOS

```bash
curl -X POST http://localhost:8000/api/sos/alert \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -H "Accept: application/json" \
  -d '{
    "latitude": 14.6928,
    "longitude": -17.4467,
    "address": "Dakar, Sénégal"
  }'
```

**✅ Succès :** JSON avec `message` et `alert`

---

## 📱 Test depuis l'Application Flutter

### Configuration Préalable

1. **Vérifier l'URL dans `terangapassapp/lib/constants/api_constants.dart`** :
   ```dart
   static const String _mode = 'dev'; // ou 'android_emulator'
   ```

2. **Serveur Laravel démarré** :
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

### Tests dans l'Application

#### Test 1 : Connexion
1. Lancer l'app Flutter : `flutter run`
2. Aller à l'écran de connexion
3. Créer un compte ou se connecter
4. **Résultat :**
   - ✅ **Succès** : Navigation vers HomeScreen
   - ❌ **Erreur** : Message d'erreur affiché (vérifier les logs)

#### Test 2 : Envoi d'alerte SOS
1. Cliquer sur "SOS Urgence"
2. Autoriser la localisation
3. Cliquer sur "Envoyer"
4. **Résultat :**
   - ✅ **Succès** : Message de confirmation
   - ❌ **Erreur** : Message d'erreur (vérifier les logs)

#### Test 3 : Récupération de données
1. Ouvrir "Annonces Audio"
2. **Résultat :**
   - ✅ **Succès** : Liste affichée (même vide)
   - ❌ **Erreur** : Données de démonstration affichées (normal si l'API échoue)

---

## 🔍 Vérification des Logs

### Logs Laravel

**Voir les requêtes en temps réel :**
```bash
tail -f storage/logs/laravel.log
```

### Logs Flutter

Dans le terminal où vous avez lancé `flutter run`, vous verrez :
- Les requêtes HTTP
- Les erreurs de connexion
- Les erreurs d'authentification

---

## ✅ Checklist de Vérification

### Serveur Laravel
- [ ] Serveur démarré avec `php artisan serve --host=0.0.0.0 --port=8000`
- [ ] Pas d'erreur au démarrage
- [ ] Routes API chargées (vérifier avec `php artisan route:list --path=api`)

### Base de Données
- [ ] Migrations exécutées (`php artisan migrate`)
- [ ] Pas d'erreur lors des migrations

### Configuration
- [ ] CORS configuré (`config/cors.php` existe)
- [ ] Configuration cache nettoyée (`php artisan config:clear`)

### Tests API
- [ ] Test cURL de base réussi
- [ ] Test d'inscription réussi
- [ ] Test de connexion réussi
- [ ] Test de requête authentifiée réussi

### Application Flutter
- [ ] URL de base configurée dans `api_constants.dart`
- [ ] Application se connecte correctement
- [ ] Token sauvegardé après connexion
- [ ] Requêtes authentifiées fonctionnent

---

## ⚠️ Problèmes Courants

### Problème 1 : "Connection refused"

**Causes :**
- Serveur Laravel non démarré
- Mauvais port utilisé
- Firewall bloque le port

**Solutions :**
```bash
# Vérifier si le port est utilisé
lsof -i :8000

# Démarrer le serveur
php artisan serve --host=0.0.0.0 --port=8000
```

### Problème 2 : "CORS policy"

**Solution :**
```bash
php artisan config:clear
php artisan config:cache
```

### Problème 3 : "401 Unauthorized"

**Vérifications :**
1. Token sauvegardé après connexion ?
2. Token envoyé dans les headers ?
3. Format du token correct ?

**Solution :** Vérifier dans les logs Flutter

### Problème 4 : "500 Internal Server Error"

**Solution :** Vérifier les logs Laravel :
```bash
tail -f storage/logs/laravel.log
```

---

## 📊 Résultat Attendu

Si tout fonctionne correctement :

✅ **Inscription/Connexion** : Token reçu et sauvegardé
✅ **Requêtes authentifiées** : Données retournées avec le token
✅ **Envoi d'alertes** : Alertes créées dans la base de données
✅ **Récupération de données** : Données affichées dans l'app

---

## 🎯 Prochaines Étapes

1. ✅ Démarrer le serveur Laravel
2. ✅ Exécuter `./test_api_simple.sh`
3. ✅ Vérifier que tous les tests passent
4. ✅ Tester depuis l'application Flutter
5. ✅ Vérifier les logs pour s'assurer qu'il n'y a pas d'erreur

---

**Si tous les tests passent, l'intégration est fonctionnelle !** ✅🚀

*Document créé le 20 janvier 2025*
