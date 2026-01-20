# Configuration Tiger Protect - Guide Complet

## 📋 Ce qu'il faut désactiver dans Tiger Protect

D'après la capture d'écran, vous avez accès à l'interface Tiger Protect avec plusieurs onglets. Voici ce qu'il faut vérifier :

### 1. Onglet "ModSecurity" (Actuellement visible)

**Action requise :**
- ✅ **Désactiver le toggle** ModSecurity (le mettre à gauche/off)
- ModSecurity est un pare-feu applicatif qui peut bloquer les requêtes API

### 2. Onglet "Générique" (À vérifier)

**Action requise :**
- Vérifier s'il y a des règles actives
- Désactiver les règles qui pourraient bloquer les requêtes API
- Chercher une option pour exclure `/api/*` ou `/api/v1/*`

### 3. Onglet "Robots" (À vérifier)

**Action requise :**
- Vérifier si les robots/bots sont bloqués
- Ajouter une exception pour les requêtes API si nécessaire

### 4. Onglet "Addresses IP" (À vérifier)

**Action requise :**
- Vérifier si votre IP ou certaines IPs sont bloquées
- Ajouter votre IP à la whitelist si nécessaire

## 🔧 Étapes Détaillées

### Étape 1 : Désactiver ModSecurity

1. Dans l'onglet **"ModSecurity"**
2. **Désactiver le toggle** (le mettre à gauche/off)
3. Cliquer sur **"Sauvegarder"** ou **"Appliquer"**

### Étape 2 : Vérifier l'onglet "Générique"

1. Cliquer sur l'onglet **"Générique"**
2. Chercher des options comme :
   - "Exclure des chemins" ou "Exclude paths"
   - "Whitelist" ou "Liste blanche"
   - Ajouter `/api/*` ou `/api/v1/*` à la liste d'exclusion

### Étape 3 : Vérifier les autres onglets

1. **WordPress** : Si vous n'utilisez pas WordPress, désactiver
2. **Robots** : Vérifier les règles de blocage
3. **Addresses IP** : Vérifier qu'aucune IP n'est bloquée

### Étape 4 : Mode Bulk (Si disponible)

Si vous voyez un bouton **"Mode bulk"**, vous pouvez :
- Désactiver Tiger Protect pour tous les domaines
- Ou configurer en masse les exceptions

## ✅ Vérification

Après avoir désactivé ModSecurity et configuré les exceptions, testez :

```bash
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

**Résultat attendu :**
- ✅ HTTP 401 ou 422 (erreur d'authentification normale)
- ✅ Réponse JSON (pas de page HTML de sécurité)
- ❌ Plus de HTTP 503 avec page HTML

## ⚠️ Important

1. **ModSecurity** : C'est probablement la cause principale, désactivez-le
2. **Sauvegardez** : N'oubliez pas de sauvegarder après chaque modification
3. **Testez** : Testez immédiatement après chaque modification
4. **Sécurité** : Désactiver ModSecurity réduit la sécurité, mais c'est nécessaire pour l'API

## 🎯 Si ça ne fonctionne toujours pas

Si après avoir désactivé ModSecurity, l'API est toujours bloquée :

1. **Vérifiez l'onglet "Générique"** pour des règles supplémentaires
2. **Contactez le support o2switch** pour désactiver complètement Tiger Protect pour `/api/*`
3. **Utilisez un sous-domaine** séparé pour l'API (ex: `api.terangapass.universaltechnologiesafrica.com`)
