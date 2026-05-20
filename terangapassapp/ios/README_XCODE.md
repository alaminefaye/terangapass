# Build iOS avec Xcode

## Important

1. Toujours ouvrir **`Runner.xcworkspace`** (pas `Runner.xcodeproj`).
2. Après `flutter pub get` ou changement de plugins :

```bash
cd terangapassapp
flutter pub get
cd ios
pod install --repo-update
cd ..
```

3. Puis ouvrir :

```bash
open ios/Runner.xcworkspace
```

## Erreurs « Unable to resolve module FirebaseCore / GoogleMaps »

- Cause : Pods non installés, mauvais fichier Xcode ouvert, ou linkage dynamique.
- Correctif projet : `Podfile` utilise `use_frameworks! :linkage => :static` et `AppDelegate` n'importe plus ces modules en Swift (Google Maps via bridging header).

Si l'erreur persiste : supprimer `ios/Pods`, `ios/Podfile.lock`, puis relancer `pod install`.
