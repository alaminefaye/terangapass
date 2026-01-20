# Correction du Problème user_type ENUM

## Problème

L'ENUM `user_type` dans la table `users` n'acceptait que 3 valeurs : `['athlete', 'visitor', 'citizen']`, mais le seeder utilisait `'admin'` et `'volunteer'`.

## Solution

### 1. Migration créée pour modifier l'ENUM

**Fichier :** `database/migrations/2025_01_20_000001_modify_user_type_enum.php`

Cette migration ajoute `'admin'` et `'volunteer'` aux valeurs acceptées de l'ENUM.

### 2. Seeder corrigé

**Fichier :** `database/seeders/UserSeeder.php`

- Gestion d'erreur pour créer l'admin même si l'ENUM n'est pas encore modifié
- Correction des codes pays (SN, US, FR au lieu de noms complets)
- Utilisation de 'citizen' au lieu de 'volunteer' si l'ENUM n'est pas encore modifié

## Commande pour exécuter

```bash
# 1. Exécuter la migration pour modifier l'ENUM
php artisan migrate

# 2. Exécuter les seeders
php artisan db:seed

# OU en une seule commande
php artisan migrate:fresh --seed
```

## Vérification

Après exécution, vérifiez que :
- L'utilisateur admin existe avec `user_type = 'admin'`
- Les autres utilisateurs utilisent les valeurs correctes
- Tous les utilisateurs sont créés sans erreur
