# Erreur 500 - Résolution

## 🔧 Problème

Après modification du fichier `.htaccess`, une erreur **500 Internal Server Error** est apparue.

## ✅ Solution Appliquée

Le fichier `.htaccess` a été restauré à sa version de base Laravel standard (sans les règles Tiger Protect qui causaient l'erreur).

### Fichier .htaccess Actuel

Le fichier contient maintenant uniquement les règles Laravel standard :
- Configuration mod_rewrite
- Gestion des headers Authorization et X-XSRF-Token
- Redirection des trailing slashes
- Routage vers index.php

## ⚠️ Pourquoi les Règles Tiger Protect Causaient une Erreur ?

Les règles ajoutées utilisaient des directives qui ne sont pas supportées dans `.htaccess` :

1. **`<LocationMatch>`** : Cette directive ne fonctionne que dans les fichiers de configuration Apache (httpd.conf), pas dans `.htaccess`
2. **`SecRuleEngine Off`** : Les directives mod_security peuvent ne pas être autorisées dans `.htaccess` selon la configuration du serveur
3. **Syntaxe complexe** : Certaines syntaxes peuvent ne pas être supportées par la version d'Apache utilisée

## 📋 État Actuel

- ✅ Fichier `.htaccess` restauré et fonctionnel
- ⚠️ Tiger Protect bloque toujours les requêtes API
- ⚠️ La solution doit être configurée côté serveur (cPanel o2switch)

## 🎯 Prochaines Étapes

Puisque les règles `.htaccess` ne peuvent pas contourner Tiger Protect (car Tiger Protect s'exécute avant `.htaccess`), vous devez :

1. **Configurer Tiger Protect dans le cPanel o2switch**
   - Accédez à Tiger Protect dans le cPanel
   - Ajoutez une exception pour `/api/*` ou `/api/v1/*`

2. **Ou contacter le support o2switch**
   - Demandez-leur de désactiver Tiger Protect pour les routes API
   - Ou de créer une exception spécifique

## 📝 Fichiers Modifiés

- `public/.htaccess` - Restauré à la version de base Laravel

## 💡 Note

Les règles `.htaccess` ne peuvent pas contourner Tiger Protect car :
- Tiger Protect s'exécute au niveau du serveur **avant** que `.htaccess` ne soit appliqué
- Tiger Protect vérifie l'exécution réelle de JavaScript, pas seulement les headers
- La configuration doit être faite dans le cPanel o2switch ou via le support
