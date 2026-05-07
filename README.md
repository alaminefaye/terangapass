# Laravel avec Template Sneat

Projet Laravel avec intégration complète du template Sneat (Bootstrap 5 HTML Admin Template).

## Documentation Teranga Pass (stratégie)

- [Inspirations, partenariats institutionnels et feuille de route produit](docs/TerangaPass_Inspirations_Strategie.md)
- [Plan d’action étape par étape (technique + institutionnel)](docs/TerangaPass_Plan_Etape_par_Etape.md)
- [Carte in-app — choix techniques (étape 4)](docs/TerangaPass_Etape4_Carte_Choix.md)
- [Paiements in-app — prérequis avant code (étape 5)](docs/TerangaPass_Etape5_Paiements_Prerequis.md)
- [Pass QR / billetterie pilote (étape 6)](docs/TerangaPass_Etape6_Pass_QR.md)
- [Démo 15 min / QA](docs/TerangaPass_QA_Demo_15min.md)
- [Checklist sécurité](docs/TerangaPass_Security_Checklist.md)
- [Process contenu / annuaire](docs/TerangaPass_Process_Contenu_Annuaire.md)
- [Opérateur — contrôle Pass (staff)](docs/TerangaPass_Operateur_Pass_Controle.md)
- [Pack hors ligne — étape 7 (manifeste API)](docs/TerangaPass_Etape7_Offline_Pack.md)

## 🚀 Installation

1. **Cloner ou naviguer vers le projet**
   ```bash
   cd sneat-laravel
   ```

2. **Installer les dépendances**
   ```bash
   composer install
   npm install
   ```

3. **Configurer l'environnement**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Configurer la base de données**
   - Modifiez le fichier `.env` avec vos paramètres de base de données
   - Exécutez les migrations et seeders :
   ```bash
   php artisan migrate:fresh --seed
   ```

5. **Démarrer le serveur**
   ```bash
   php artisan serve
   ```

## 👤 Compte par défaut

Après avoir exécuté les seeders, vous pouvez vous connecter avec :
- **Email:** `admin@admin.com`
- **Password:** `password`

## 📁 Structure du projet

```
sneat-laravel/
├── public/
│   └── assets/          # Assets Sneat (CSS, JS, images, fonts)
├── resources/
│   └── views/
│       ├── layouts/
│       │   ├── app.blade.php      # Layout principal avec menu
│       │   └── auth.blade.php     # Layout pour authentification
│       ├── auth/
│       │   └── login.blade.php    # Page de connexion
│       └── dashboard.blade.php    # Page dashboard
└── routes/
    └── web.php          # Routes de l'application
```

## 🎨 Template Sneat

Le template Sneat est complètement intégré dans le projet :
- ✅ Tous les assets (CSS, JS, images, fonts) sont dans `public/assets/`
- ✅ Layouts Blade créés avec la structure Sneat
- ✅ Menu sidebar fonctionnel
- ✅ Dashboard avec graphiques
- ✅ Page de login stylisée
- ✅ Responsive design

## 🔧 Fonctionnalités

- **Authentification** : Système de login/logout
- **Dashboard** : Page d'accueil avec statistiques
- **Layout responsive** : Menu sidebar qui s'adapte aux écrans
- **Template complet** : Tous les composants Sneat disponibles

## 📝 Routes disponibles

- `/login` - Page de connexion
- `/dashboard` - Dashboard (nécessite authentification)
- `/` - Redirige vers dashboard si connecté, sinon vers login

## 🛠️ Développement

Pour ajouter de nouvelles pages avec le template Sneat :

1. Créez une nouvelle vue dans `resources/views/`
2. Étendez le layout `layouts.app`
3. Ajoutez la route dans `routes/web.php`

Exemple :
```php
// routes/web.php
Route::get('/ma-page', [MonController::class, 'index'])->name('ma-page');

// resources/views/ma-page.blade.php
@extends('layouts.app')
@section('title', 'Ma Page')
@section('content')
    <!-- Votre contenu ici -->
@endsection
```

## 📚 Documentation Sneat

Pour plus d'informations sur les composants Sneat disponibles, consultez :
- [Documentation Sneat](https://themeselection.com/demo/sneat-bootstrap-html-admin-template/documentation/)
- [GitHub Sneat](https://github.com/themeselection/sneat-html-admin-template-free)

## ⚠️ Notes importantes

- Les assets Sneat sont déjà copiés dans `public/assets/`
- Le template utilise Bootstrap 5
- Les icônes Boxicons sont incluses
- Les graphiques ApexCharts sont disponibles pour le dashboard

## 🐛 Résolution de problèmes

Si les assets ne se chargent pas :
1. Vérifiez que les fichiers sont bien dans `public/assets/`
2. Videz le cache : `php artisan cache:clear`
3. Vérifiez les permissions des dossiers

## 📄 Licence

Ce projet utilise le template Sneat qui est sous licence MIT.
