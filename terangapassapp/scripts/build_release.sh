#!/usr/bin/env bash
# Build release Teranga Pass (AAB + IPA si macOS + Xcode)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> flutter pub get"
flutter pub get

echo "==> Vérification API_MODE (doit être production par défaut)"
grep -q "defaultValue: 'production'" lib/constants/api_constants.dart \
  || { echo "ERREUR: api_constants.dart n'est pas en mode production"; exit 1; }

ANDROID_KEY="$ROOT/android/key.properties"
if [[ ! -f "$ANDROID_KEY" ]]; then
  echo "ATTENTION: android/key.properties absent — le AAB sera signé en DEBUG."
  echo "         Copiez android/key.properties.example avant la soumission Play Store."
fi

echo "==> Build Android App Bundle (release)"
flutter build appbundle --release
echo "OK: build/app/outputs/bundle/release/app-release.aab"

if [[ "$(uname)" == "Darwin" ]]; then
  echo "==> pod install (iOS)"
  (cd ios && pod install)
  echo "==> Build iOS IPA (release)"
  flutter build ipa --release
  echo "OK: voir build/ios/ipa/"
else
  echo "iOS IPA ignoré (macOS + Xcode requis)"
fi

echo ""
echo "Terminé. Consultez docs/PUBLICATION_STORES.md pour Play Console / App Store Connect."
