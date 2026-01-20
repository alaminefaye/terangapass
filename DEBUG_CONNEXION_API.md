# Guide de Debug - Problème de Connexion API

## Problème Identifié

L'application mobile affiche le message d'erreur :
**"Service temporairement indisponible. Veuillez réessayer dans quelques instants."**

Ce message correspond généralement à :
- Code HTTP 503 (Service Unavailable)
- Erreur de connexion réseau
- Timeout de connexion
- Problème DNS
- Serveur non accessible

## Étapes de Debug

### 1. Vérifier les Logs de l'Application Flutter

Lorsque vous essayez de vous connecter, regardez les logs de l'application Flutter. Vous devriez voir :

```
=== API SERVICE INITIALIZATION ===
Base URL: [URL utilisée]
Mode: [ApiConstants ou Custom]
==================================

=== API REQUEST ===
URL: POST [URL complète]
Headers: [Headers de la requête]
Data: [Données envoyées]
==================

=== API ERROR ===
[Informations détaillées sur l'erreur]
==================
```

### 2. Tester la Connexion avec le Script de Debug

Exécutez le script de test :

```bash
./test_api_connection_debug.sh
```

Ce script va :
- Tester la connexion à l'URL de production
- Vérifier si le serveur répond
- Tester l'endpoint `/api/v1/auth/login`
- Vérifier la résolution DNS
- Vérifier le certificat SSL (si HTTPS)

### 3. Vérifier la Configuration de l'URL

Vérifiez le fichier `terangapassapp/lib/constants/api_constants.dart` :

```dart
static const String _mode = 'production'; // ou 'dev', 'android_emulator', 'physical_device'
```

**URLs disponibles :**
- `production`: `https://terangapass.universaltechnologiesafrica.com/api/v1`
- `dev`: `http://localhost:8000/api/v1` (iOS Simulator)
- `android_emulator`: `http://10.0.2.2:8000/api/v1`
- `physical_device`: `http://192.168.1.100:8000/api/v1` (remplacez par votre IP)

### 4. Vérifier que le Serveur Laravel est Accessible

#### Pour l'URL de production :
```bash
curl -I https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login
```

#### Pour l'URL locale :
```bash
curl -I http://localhost:8000/api/v1/auth/login
```

### 5. Vérifier les Logs Laravel

```bash
tail -f storage/logs/laravel.log
```

Cherchez les erreurs liées aux requêtes API.

### 6. Tester l'Endpoint de Login Directement

```bash
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

### 7. Vérifier la Configuration CORS

Le fichier `config/cors.php` doit avoir :
```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_origins' => ['*'],
'allowed_headers' => ['*'],
```

### 8. Problèmes Courants et Solutions

#### Problème : Timeout de connexion
**Solution :**
- Vérifiez votre connexion internet
- Vérifiez que le serveur est en cours d'exécution
- Augmentez le timeout dans `api_service.dart` (actuellement 30 secondes)

#### Problème : DNS non résolu
**Solution :**
- Vérifiez que le domaine existe et est accessible
- Pour le développement local, utilisez l'IP de votre machine au lieu du domaine

#### Problème : Certificat SSL invalide
**Solution :**
- Vérifiez que le certificat SSL est valide
- Pour le développement, vous pouvez désactiver la vérification SSL (non recommandé en production)

#### Problème : Code 503 (Service Unavailable)
**Solution :**
- Le serveur peut être en maintenance
- Vérifiez les logs du serveur
- Vérifiez que tous les services nécessaires sont en cours d'exécution

#### Problème : Code 401 (Unauthorized)
**Solution :**
- Les identifiants sont incorrects
- Vérifiez que l'utilisateur existe dans la base de données
- Vérifiez que le mot de passe est correct

#### Problème : Code 422 (Validation Error)
**Solution :**
- Les données envoyées sont invalides
- Vérifiez le format de l'email
- Vérifiez que tous les champs requis sont remplis

## Améliorations Apportées

### 1. Logging Amélioré dans ApiService
- Logs détaillés de toutes les requêtes
- Logs détaillés de toutes les erreurs
- Informations sur le type d'erreur (timeout, connexion, etc.)

### 2. Gestion d'Erreurs Améliorée dans LoginScreen
- Messages d'erreur plus clairs
- Logs détaillés dans la console
- Affichage des erreurs avec stack trace

### 3. Script de Test
- Script bash pour tester la connexion
- Tests automatiques de différents scénarios
- Vérification DNS et SSL

## Prochaines Étapes

1. **Exécutez le script de test** pour identifier le problème exact
2. **Vérifiez les logs** de l'application Flutter lors d'une tentative de connexion
3. **Vérifiez les logs Laravel** pour voir si les requêtes arrivent au serveur
4. **Testez avec différentes URLs** (production, local, etc.)
5. **Vérifiez votre connexion internet** et les paramètres réseau

## Commandes Utiles

```bash
# Voir les logs Laravel en temps réel
tail -f storage/logs/laravel.log

# Tester l'endpoint de login
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"votre@email.com","password":"votre_mot_de_passe"}'

# Vérifier si le serveur répond
curl -I https://terangapass.universaltechnologiesafrica.com/up

# Tester la résolution DNS
nslookup terangapass.universaltechnologiesafrica.com
```

## Support

Si le problème persiste après avoir suivi ces étapes, fournissez :
1. Les logs complets de l'application Flutter
2. Les logs Laravel (dernières 50 lignes)
3. Le résultat du script de test
4. La configuration actuelle dans `api_constants.dart`
