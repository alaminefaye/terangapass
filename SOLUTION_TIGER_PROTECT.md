# Solution au Problème Tiger Protect (o2switch)

## 🔍 Problème Identifié

Le serveur retourne un code HTTP **503** avec une page HTML de sécurité "Test de sécurité / Security check..." qui demande d'activer JavaScript.

**Cause :** Tiger Protect (système de sécurité de l'hébergeur o2switch) bloque les requêtes qui ne viennent pas d'un navigateur avec JavaScript activé. Les applications mobiles Flutter font des requêtes HTTP directes sans passer par un navigateur, donc elles sont bloquées.

## ✅ Solution Appliquée (Côté Application)

### Modification du User-Agent

Le User-Agent a été modifié pour simuler un navigateur mobile (Safari iOS) :

```dart
'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1'
```

### Headers Ajoutés

Des headers supplémentaires ont été ajoutés pour mieux simuler un navigateur :

- `Accept-Language`: `fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7`
- `Accept-Encoding`: `gzip, deflate, br`
- `Origin`: URL de base du site
- `Referer`: URL de base du site

### ⚠️ Limitation

**Cette solution peut ne pas suffire** car Tiger Protect vérifie également :
- L'exécution de JavaScript (impossible depuis une app mobile)
- Les cookies de session
- D'autres mécanismes de sécurité

**La solution définitive nécessite une configuration côté serveur.**

## 🔧 Solutions Supplémentaires (Côté Serveur)

### Option 1 : Désactiver Tiger Protect pour les Routes API (Recommandé)

Dans le panneau de contrôle o2switch (cPanel), vous pouvez :

1. Accéder à **Tiger Protect** ou **Sécurité**
2. Ajouter une exception pour les routes `/api/*`
3. Ou désactiver complètement Tiger Protect pour le domaine (non recommandé)

### Option 2 : Configuration .htaccess (Si supporté)

Ajoutez dans le fichier `.htaccess` à la racine du site :

```apache
# Exclure les routes API de Tiger Protect (si supporté)
<IfModule mod_security.c>
    SecRuleRemoveById 123456  # Remplacez par l'ID de la règle Tiger Protect
</IfModule>
```

**Note :** Cette option peut ne pas fonctionner car Tiger Protect est généralement configuré au niveau du serveur, avant même que la requête n'arrive à Laravel.

### Option 3 : Contacter le Support o2switch

Contactez le support o2switch pour :
- Désactiver Tiger Protect pour les routes `/api/*`
- Ajouter une exception pour votre application mobile
- Configurer une whitelist d'IP (si vous avez une IP fixe)

## 📋 Vérification

### Test avec curl

Testez si la modification fonctionne :

```bash
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1" \
  -H "Accept-Language: fr-FR,fr;q=0.9" \
  -H "Origin: https://terangapass.universaltechnologiesafrica.com" \
  -H "Referer: https://terangapass.universaltechnologiesafrica.com/" \
  -d '{"email":"test@example.com","password":"test"}'
```

Si vous obtenez toujours une page HTML de sécurité, il faudra configurer Tiger Protect côté serveur.

## 🎯 Solution Recommandée

**La meilleure solution est de contacter le support o2switch** pour :
1. Désactiver Tiger Protect pour toutes les routes `/api/*`
2. Ou ajouter une exception pour les requêtes API

Cela garantira que toutes les applications (mobile, web, etc.) peuvent accéder à l'API sans problème.

## 📝 Fichiers Modifiés

- `terangapassapp/lib/services/api_service.dart` - User-Agent et headers modifiés

## ⚠️ Note Importante

Si la modification du User-Agent ne fonctionne pas, **il faudra absolument configurer Tiger Protect côté serveur**. C'est la seule solution permanente et fiable.
