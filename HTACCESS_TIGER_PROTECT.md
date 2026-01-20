# Configuration .htaccess pour Contourner Tiger Protect

## 📝 Modifications Apportées

J'ai modifié le fichier `public/.htaccess` pour ajouter des règles qui tentent de contourner Tiger Protect pour les routes API.

## 🔧 Techniques Utilisées

### 1. Désactivation de mod_security pour les routes API

```apache
<IfModule mod_security.c>
    <LocationMatch "^/api/">
        SecRuleEngine Off
    </LocationMatch>
</IfModule>
```

**Note :** Tiger Protect peut utiliser mod_security, mais il est généralement configuré au niveau du serveur avant que .htaccess ne soit appliqué.

### 2. Headers Simulant un Navigateur

```apache
<IfModule mod_headers.c>
    <LocationMatch "^/api/">
        Header set User-Agent "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)..."
        Header set Accept "application/json, text/html, application/xhtml+xml, */*"
        Header set X-Requested-With "XMLHttpRequest"
        ...
    </LocationMatch>
</IfModule>
```

Ces headers simulent une requête provenant d'un navigateur avec JavaScript activé.

## ⚠️ Limitations

**Important :** Tiger Protect est généralement configuré au niveau du serveur (avant .htaccess), donc ces règles peuvent ne pas fonctionner.

### Pourquoi ça peut ne pas fonctionner ?

1. **Tiger Protect s'exécute avant .htaccess** : Les règles .htaccess sont appliquées après que la requête ait passé par Tiger Protect
2. **Configuration serveur** : Tiger Protect est configuré dans la configuration Apache du serveur, pas dans .htaccess
3. **Vérification JavaScript** : Tiger Protect vérifie l'exécution réelle de JavaScript, pas seulement les headers

## ✅ Vérification

Après avoir modifié le fichier, testez avec :

```bash
curl -X POST https://terangapass.universaltechnologiesafrica.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

Si vous obtenez toujours une page HTML de sécurité, cela signifie que Tiger Protect bloque toujours et que la configuration doit être faite côté serveur.

## 🔄 Si ça ne fonctionne pas

Si les règles .htaccess ne fonctionnent pas, vous devez :

1. **Configurer Tiger Protect dans le cPanel o2switch**
   - Accédez à Tiger Protect dans le cPanel
   - Ajoutez une exception pour `/api/*`

2. **Contacter le support o2switch**
   - Demandez-leur de désactiver Tiger Protect pour les routes API
   - Ou de créer une exception spécifique

3. **Utiliser un sous-domaine séparé**
   - Créez `api.terangapass.universaltechnologiesafrica.com`
   - Désactivez Tiger Protect uniquement pour ce sous-domaine

## 📋 Fichiers Modifiés

- `public/.htaccess` - Règles ajoutées pour contourner Tiger Protect

## 🎯 Prochaines Étapes

1. **Testez** la connexion depuis l'application mobile
2. **Vérifiez les logs** pour voir si le problème persiste
3. **Si ça ne fonctionne pas**, configurez Tiger Protect dans le cPanel o2switch
