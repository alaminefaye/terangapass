# 🔄 Redémarrer l'Application Flutter

## Problème

Les modifications du User-Agent ne sont pas prises en compte car l'application n'a pas été complètement redémarrée.

Un **hot reload** ne suffit pas pour les changements dans :
- Les constructeurs
- Les initialisations statiques
- Les variables globales
- Les configurations de base (comme Dio)

## Solution : Redémarrage Complet

### Option 1 : Hot Restart (Recommandé)

Dans VS Code ou Android Studio :

1. Appuyez sur **`R`** (majuscule) dans le terminal où Flutter s'exécute
2. Ou cliquez sur le bouton **"Hot Restart"** dans la barre d'outils

### Option 2 : Arrêter et Relancer

1. Arrêtez l'application (Ctrl+C dans le terminal)
2. Relancez avec : `flutter run`

### Option 3 : Nettoyer et Recompiler

Si les options précédentes ne fonctionnent pas :

```bash
# Nettoyer le build
flutter clean

# Recompiler
flutter pub get
flutter run
```

## Vérification

Après le redémarrage, vérifiez les logs. Vous devriez voir :

```
=== API SERVICE INITIALIZATION ===
Base URL: https://terangapass.universaltechnologiesafrica.com/api/v1
Base URL for headers: https://terangapass.universaltechnologiesafrica.com
Mode: ApiConstants
==================================

=== API REQUEST ===
URL: POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login
Headers: {Content-Type: application/json, Accept: application/json, User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1, ...}
```

**Important :** Le User-Agent doit être `Mozilla/5.0...` et non `TerangaPass-Mobile/1.0`

## Note

Même avec le nouveau User-Agent, Tiger Protect peut toujours bloquer les requêtes car il vérifie aussi JavaScript et les cookies. **La configuration côté serveur reste nécessaire** (voir `ACTION_REQUISE_TIGER_PROTECT.md`).
