# ⚠️ ACTION REQUISE - Configuration Tiger Protect

## Problème

L'application mobile ne peut pas se connecter à l'API car **Tiger Protect** (système de sécurité o2switch) bloque les requêtes qui ne viennent pas d'un navigateur avec JavaScript.

## Solution Définitive

**Vous devez configurer Tiger Protect côté serveur** pour autoriser les requêtes API.

## Étapes à Suivre

### Option 1 : Désactiver Tiger Protect pour les Routes API (Recommandé)

1. Connectez-vous au **cPanel** de votre hébergement o2switch
2. Recherchez **Tiger Protect** ou **Sécurité** dans le menu
3. Ajoutez une exception pour les routes `/api/*` ou `/api/v1/*`
4. Sauvegardez la configuration

### Option 2 : Contacter le Support o2switch

Si vous ne trouvez pas l'option dans le cPanel, contactez le support o2switch :

**Email :** support@o2switch.fr  
**Téléphone :** Voir sur https://www.o2switch.fr/contact/

**Message type à envoyer :**

```
Bonjour,

Je souhaite désactiver Tiger Protect pour les routes API de mon site 
terangapass.universaltechnologiesafrica.com.

Mon application mobile Flutter ne peut pas accéder à l'API car Tiger Protect 
bloque les requêtes qui ne viennent pas d'un navigateur avec JavaScript.

Pouvez-vous :
1. Désactiver Tiger Protect pour toutes les routes /api/* ou /api/v1/*
2. Ou ajouter une exception pour les requêtes API

Merci pour votre aide.
```

### Option 3 : Utiliser un Sous-domaine pour l'API

Si les options précédentes ne fonctionnent pas, vous pouvez :

1. Créer un sous-domaine : `api.terangapass.universaltechnologiesafrica.com`
2. Configurer ce sous-domaine pour pointer vers le même répertoire
3. Désactiver Tiger Protect uniquement pour ce sous-domaine
4. Modifier l'URL dans `api_constants.dart` :

```dart
static const String _productionUrl = 
    'https://api.terangapass.universaltechnologiesafrica.com/api/v1';
```

## Vérification

Une fois la configuration effectuée, testez avec :

```bash
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

Vous devriez obtenir une réponse JSON (même si c'est une erreur 401 ou 422), et non une page HTML de sécurité.

## Solution Temporaire (Développement)

En attendant la configuration côté serveur, vous pouvez :

1. Utiliser un serveur local pour le développement
2. Utiliser un tunnel (ngrok, localtunnel, etc.) pour exposer votre serveur local
3. Modifier temporairement `api_constants.dart` pour pointer vers votre serveur local

## Fichiers à Modifier Après Configuration

Une fois Tiger Protect configuré, vous pouvez :
- Garder les modifications du User-Agent (elles ne font pas de mal)
- Ou revenir au User-Agent original si vous préférez

## Important

**Cette configuration est obligatoire pour que l'application mobile fonctionne en production.** Sans cela, toutes les requêtes API seront bloquées par Tiger Protect.
