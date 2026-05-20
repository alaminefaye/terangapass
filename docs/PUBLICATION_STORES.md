# Publication App Store & Google Play — Teranga Pass

Guide pour soumettre **Teranga Pass** (`com.terangapass.app`) en production.

---

## État actuel du projet

| Élément | Valeur |
|---------|--------|
| Version | `1.0.0+1` (`pubspec.yaml`) |
| Android `applicationId` | `com.terangapass.app` |
| iOS Bundle ID | `com.terangapass.app` |
| API production | `https://www.terangapass.com/api/v1` |
| Mode API par défaut | `production` (`--dart-define=API_MODE=…` pour override) |

---

## 1. Backend Laravel (avant les stores)

- [ ] Déployer la dernière version sur `https://www.terangapass.com`
- [ ] `.env` production : `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL=https://www.terangapass.com`
- [ ] HTTPS actif, certificat valide
- [ ] Pages légales accessibles (voir [LEGAL_URLS.md](./LEGAL_URLS.md))
- [ ] Routes API critiques testées (auth, SOS, notifications, tourisme)
- [ ] `php artisan config:cache` et `route:cache` sur le serveur

---

## 2. Android — Google Play

### 2.1 Keystore de publication (obligatoire)

```bash
cd terangapassapp/android
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Copier le modèle et remplir :

```bash
cp key.properties.example key.properties
# Éditer key.properties (storeFile=upload-keystore.jks, mots de passe, alias)
```

**Conserver le fichier `.jks` et les mots de passe** — impossible de mettre à jour l’app sur le Play Store sans eux.

### 2.2 Build AAB (format requis par Google)

```bash
cd terangapassapp
flutter pub get
flutter build appbundle --release
```

Fichier généré :  
`build/app/outputs/bundle/release/app-release.aab`

### 2.3 Play Console — à préparer

- [ ] Compte développeur Google Play (frais unique)
- [ ] Fiche : titre, description courte/longue, captures d’écran (téléphone)
- [ ] Icône 512×512, bannière feature graphic si besoin
- [ ] **URL politique de confidentialité** : https://www.terangapass.com/politique-confidentialite
- [ ] Déclaration **localisation** (carte, SOS, signalements)
- [ ] Déclaration **notifications** (Firebase Cloud Messaging)
- [ ] Classification du contenu (questionnaire)
- [ ] Compte de test pour la revue Google (login + parcours invité)

### 2.4 Empreintes SHA pour Firebase / Google Maps

Après création du keystore release :

```bash
keytool -list -v -keystore android/upload-keystore.jks -alias upload
```

Ajouter **SHA-1** et **SHA-256** dans :
- Firebase Console → Paramètres du projet → App Android
- Google Cloud Console → clés API (restriction par package + empreinte)

---

## 3. iOS — App Store

### 3.1 Configuration Xcode

- **Team** : `89W2344QW3` (déjà dans le projet)
- **Debug** : `RunnerDebug.entitlements` → push `development`
- **Release / Archive** : `Runner.entitlements` → push `production`

Ouvrir le workspace :

```bash
open terangapassapp/ios/Runner.xcworkspace
```

Vérifier **Signing & Capabilities** : Push Notifications, Background Modes → Remote notifications.

### 3.2 Firebase / APNs

- [ ] Clé APNs (.p8) uploadée dans Firebase Console (projet `terangapass-74033`)
- [ ] Certificats / clés alignés avec le Bundle ID `com.terangapass.app`

### 3.3 Build IPA

```bash
cd terangapassapp
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

Ou **Product → Archive** dans Xcode, puis **Distribute App** → App Store Connect.

### 3.4 App Store Connect — à préparer

- [ ] Compte Apple Developer Program
- [ ] App créée avec Bundle ID `com.terangapass.app`
- [ ] Captures iPhone (6,7" obligatoires selon guidelines actuelles)
- [ ] **URL confidentialité** : https://www.terangapass.com/politique-confidentialite
- [ ] **URL support** : https://www.terangapass.com/assistance (e-mail : contact@terangapass.com)
- [ ] Export compliance : app utilise uniquement HTTPS standard → **ITSAppUsesNonExemptEncryption = false** (déjà dans Info.plist)
- [ ] Notes pour l’équipe de revue (compte démo, SOS, localisation)

---

## 4. URLs légales (stores)

| Usage | URL |
|-------|-----|
| CGU | https://www.terangapass.com/conditions-utilisation |
| Confidentialité | https://www.terangapass.com/politique-confidentialite |

---

## 5. Script de build rapide

```bash
./terangapassapp/scripts/build_release.sh
```

---

## 6. Checklist finale avant soumission

- [ ] Tester **release** sur un vrai iPhone et un Android physique
- [ ] Connexion / inscription / SOS / carte / notifications
- [ ] Mode invité fonctionnel sans crash
- [ ] Pas de `API_MODE=dev` dans la commande de build store
- [ ] Version incrémentée dans `pubspec.yaml` à chaque nouvelle soumission (`1.0.1+2`, etc.)
- [ ] Clés API Google Maps restreintes (package + empreintes)
- [ ] Firebase en mode production pour les builds store

---

## 7. Incrémenter la version

Dans `terangapassapp/pubspec.yaml` :

```yaml
version: 1.0.1+2   # 1.0.1 = nom affiché, 2 = build number (Play + App Store)
```

Puis rebuild AAB / IPA.

---

## Fichiers modifiés pour la production

- `android/app/build.gradle.kts` — signature release via `key.properties`
- `android/key.properties.example` — modèle keystore
- `ios/Runner/Runner.entitlements` — APNs production
- `ios/Runner/RunnerDebug.entitlements` — APNs développement
- `ios/Runner/PrivacyInfo.xcprivacy` — manifeste confidentialité Apple
- `ios/Runner/Info.plist` — export encryption
- `lib/constants/api_constants.dart` — API production + dart-define
- `lib/utils/app_log.dart` — logs désactivés en release
