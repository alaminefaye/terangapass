# Configuration de l'API - Teranga Pass Mobile

## 🔧 Configuration de l'URL de Base

### Fichier : `lib/constants/api_constants.dart`

L'URL de base de l'API est configurée de manière flexible selon votre environnement.

### Mode de Configuration

Dans `api_constants.dart`, changez la variable `_mode` :

```dart
static const String _mode = 'dev'; // Options: 'dev', 'android_emulator', 'physical_device', 'production'
```

### Options Disponibles

#### 1. **Mode 'dev'** (Développement - Détection automatique)
```dart
static const String _mode = 'dev';
```
- **Android** : Utilise automatiquement `http://10.0.2.2:8000/api` (Android Emulator)
- **iOS** : Utilise automatiquement `http://localhost:8000/api` (iOS Simulator)

#### 2. **Mode 'android_emulator'** (Android Emulator)
```dart
static const String _mode = 'android_emulator';
```
- URL : `http://10.0.2.2:8000/api`
- Utilisez ce mode si vous testez uniquement sur Android Emulator

#### 3. **Mode 'physical_device'** (Appareil Physique)
```dart
static const String _mode = 'physical_device';
```
- URL : `http://192.168.1.100:8000/api` (⚠️ **Changez cette IP !**)
- **IMPORTANT** : Remplacez `192.168.1.100` par l'IP locale de votre machine

**Comment trouver votre IP locale :**
- **macOS/Linux** : `ifconfig | grep "inet " | grep -v 127.0.0.1`
- **Windows** : `ipconfig` (cherchez "IPv4 Address")
- Assurez-vous que votre téléphone et votre ordinateur sont sur le même réseau WiFi

#### 4. **Mode 'production'** (Production)
```dart
static const String _mode = 'production';
```
- URL : `https://api.terangapass.sn/api` (⚠️ **Changez cette URL !**)
- Remplacez par votre URL de production réelle

---

## 📱 Configuration pour Appareil Physique

### Étape 1 : Trouver votre IP locale

**Sur macOS :**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

**Sur Windows :**
```bash
ipconfig
```

**Sur Linux :**
```bash
hostname -I
```

### Étape 2 : Modifier `api_constants.dart`

```dart
static const String _physicalDeviceUrl = 'http://VOTRE_IP:8000/api';
// Exemple: 'http://192.168.1.50:8000/api'
```

### Étape 3 : Changer le mode

```dart
static const String _mode = 'physical_device';
```

### Étape 4 : Démarrer le serveur Laravel

Assurez-vous que votre serveur Laravel écoute sur toutes les interfaces :

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Cela permet aux appareils sur le même réseau d'accéder au serveur.

---

## 🔔 Configuration des Push Notifications (Device Token)

### Étape 1 : Installer Firebase Messaging

Si ce n'est pas déjà fait, ajoutez dans `pubspec.yaml` :

```yaml
dependencies:
  firebase_messaging: ^14.7.9
  firebase_core: ^2.24.2
```

Puis :
```bash
flutter pub get
```

### Étape 2 : Configurer Firebase

1. Créez un projet Firebase sur [console.firebase.google.com](https://console.firebase.google.com)
2. Ajoutez votre application Android/iOS
3. Téléchargez les fichiers de configuration :
   - Android : `google-services.json` → `android/app/`
   - iOS : `GoogleService-Info.plist` → `ios/Runner/`

### Étape 3 : Activer l'enregistrement automatique

Dans `lib/main.dart`, décommentez le code dans `_registerDeviceToken()` :

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> _registerDeviceToken() async {
  try {
    final apiService = ApiService();
    final fcmToken = await FirebaseMessaging.instance.getToken();
    
    if (fcmToken != null) {
      await apiService.registerDeviceToken(
        token: fcmToken,
        platform: Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web',
      );
      debugPrint('Device token enregistré avec succès');
    }
  } catch (e) {
    debugPrint('Erreur enregistrement device token: $e');
  }
}
```

---

## 🧪 Test de la Configuration

### Test 1 : Vérifier l'URL de base

Ajoutez un print dans votre code pour vérifier :

```dart
print('API Base URL: ${ApiConstants.baseUrl}');
```

### Test 2 : Test de connexion

Dans `LoginScreen`, après une connexion réussie, vérifiez que :
- Le token est sauvegardé
- Les requêtes suivantes incluent le token dans les headers

### Test 3 : Test d'une requête API

Dans n'importe quel écran, testez une requête simple :

```dart
try {
  final apiService = ApiService();
  final profile = await apiService.getUserProfile();
  print('Profil récupéré: $profile');
} catch (e) {
  print('Erreur: $e');
}
```

---

## ⚠️ Problèmes Courants

### Problème 1 : "Connection refused" sur Android Emulator

**Solution :** Utilisez `http://10.0.2.2:8000/api` au lieu de `localhost`

### Problème 2 : "Connection timeout" sur appareil physique

**Solutions :**
1. Vérifiez que votre téléphone et ordinateur sont sur le même WiFi
2. Vérifiez que le firewall n'bloque pas le port 8000
3. Utilisez l'IP locale correcte (pas `localhost` ou `127.0.0.1`)

### Problème 3 : "401 Unauthorized"

**Solution :** Vérifiez que le token d'authentification est bien sauvegardé après la connexion

### Problème 4 : CORS errors (si vous testez sur web)

**Solution :** Configurez CORS dans Laravel (`config/cors.php`) pour autoriser votre domaine

---

## 📝 Checklist de Configuration

- [ ] URL de base configurée selon l'environnement
- [ ] Mode `_mode` défini correctement
- [ ] IP locale configurée pour appareil physique (si nécessaire)
- [ ] Serveur Laravel démarré avec `--host=0.0.0.0`
- [ ] Firebase configuré (pour push notifications)
- [ ] Device token enregistrement activé (si Firebase configuré)
- [ ] Test de connexion réussi
- [ ] Test d'une requête API réussi

---

*Document créé le 20 janvier 2025*
