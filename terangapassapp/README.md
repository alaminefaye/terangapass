# Teranga Pass - Application Mobile

Application mobile de sécurité, d'assistance et de tourisme pour les Jeux Olympiques de la Jeunesse (JOJ) Dakar 2026.

## 🚀 Technologies

- **Framework**: Flutter
- **Backend**: Laravel (API REST)
- **State Management**: Provider
- **Navigation**: Go Router
- **Maps**: Google Maps Flutter
- **Location**: Geolocator

## 📋 Prérequis

- Flutter SDK (version 3.10.4 ou supérieure)
- Dart SDK
- Android Studio / Xcode (pour iOS)
- Un émulateur ou un appareil physique

## 🛠️ Installation

1. Installer les dépendances :
```bash
flutter pub get
```

2. Vérifier la configuration :
```bash
flutter doctor
```

3. Lancer l'application :
```bash
flutter run
```

## 📱 Structure du Projet

```
lib/
├── constants/       # Constantes de l'application
├── models/          # Modèles de données
├── screens/         # Écrans de l'application
├── services/        # Services (API, location, etc.)
├── theme/           # Thème et styles
├── utils/           # Utilitaires
├── widgets/         # Widgets réutilisables
└── main.dart        # Point d'entrée
```

## 🎨 Design

L'application utilise les couleurs du drapeau sénégalais :
- **Vert** (#00853F) : Couleur principale
- **Jaune** (#FCD116) : Couleur secondaire
- **Rouge** (#CE1126) : Couleur d'accent

## 📝 Fonctionnalités

### Phase 1 - MVP (En développement)
- ✅ Écran d'accueil avec design
- ✅ Boutons SOS et Alerte Médicale (UI)
- ⏳ Signalement d'incidents
- ⏳ Carte interactive de base
- ⏳ Authentification utilisateur

### Phase 2 - Fonctionnalités Core
- ⏳ Notifications en temps réel
- ⏳ Annonces audio officielles
- ⏳ Infos JOJ & Sites de compétitions
- ⏳ Profil utilisateur

### Phase 3 - Services Complémentaires
- ⏳ Transport & Navettes
- ⏳ Tourisme & Services Utiles
- ⏳ Multilingue complet
- ⏳ Centre Opérationnel (Backend)

## 🔗 API Backend

L'application se connectera à l'API Laravel située dans le projet parent.

**URL de base** : `http://localhost:8000/api` (à configurer)

## 📦 Dépendances Principales

- `go_router`: Navigation
- `provider`: Gestion d'état
- `dio`: Client HTTP
- `geolocator`: Géolocalisation
- `google_maps_flutter`: Cartes
- `permission_handler`: Gestion des permissions
- `shared_preferences`: Stockage local

## 🚧 Prochaines Étapes

1. Créer les écrans SOS et Alerte Médicale
2. Implémenter la géolocalisation
3. Créer les APIs Laravel
4. Connecter l'application mobile aux APIs
5. Implémenter l'authentification

## 📄 Licence

Propriétaire - Universal Technologies Africa
