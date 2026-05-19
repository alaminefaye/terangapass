# URLs légales — publication stores

Après déploiement sur **https://www.terangapass.com**, utilisez ces URLs dans App Store Connect et Google Play Console.

## Conditions d'utilisation (obligatoire selon les stores)

| Langue | URL |
|--------|-----|
| Français (recommandé) | **https://www.terangapass.com/conditions-utilisation** |
| English | https://www.terangapass.com/terms-of-use |

Alias : `https://www.terangapass.com/cgu` ou `/terms` → redirige vers la version française.

## Politique de confidentialité (souvent requise en plus)

| Langue | URL |
|--------|-----|
| Français | **https://www.terangapass.com/politique-confidentialite** |
| English | https://www.terangapass.com/privacy-policy |

## Configuration serveur

Dans `.env` de production :

```env
APP_URL=https://www.terangapass.com
APP_NAME="Teranga Pass"
LEGAL_CONTACT_EMAIL=contact@terangapass.com
LEGAL_PUBLISHER=Teranga Pass
LEGAL_LAST_UPDATED=2026-05-18
```

Puis déployer le code Laravel et vider le cache des routes si besoin : `php artisan route:cache`.

## Vérification locale

```bash
php artisan serve
# Ouvrir http://127.0.0.1:8000/conditions-utilisation
```

Les pages sont **publiques** (aucune connexion admin requise).
