# Teranga Pass — Étape 6 — Pass QR (pilote billetterie)

**Plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — étape 6.  
**Dernière mise à jour** : 7 mai 2026.

## Périmètre livré (MVP)

- **Sans paiement in-app** (étape 5 reportée) : billet pilote `joj_visitor_pilot`, délivré automatiquement au premier appel API pour l’utilisateur connecté.
- **QR signé** : préfixe `TPASS1.` + payload JSON + signature **HMAC-SHA256** (`TERANGA_PASS_QR_SECRET` ou repli sur dérivation `APP_KEY` en dev via `AppServiceProvider`).
- **Révocation / expiration** : champs `status`, `revoked_at`, `valid_until` sur `pass_tickets` ; le contrôle serveur refuse si billet inactif ou utilisateur suspendu.

## API

| Méthode | Chemin | Auth | Rôle |
|---------|--------|------|------|
| `GET` | `/api/v1/pass/ticket` | Bearer (jeton actuel) | Retourne `qr_payload` + méta (type, validité). Crée un billet s’il n’y en a pas d’actif. |
| `POST` | `/api/v1/pass/validate` | En-tête **`X-Teranga-Pass-Control`** = valeur de `TERANGA_PASS_CONTROL_KEY` | Vérifie un QR scanné. Corps JSON : `{ "qr": "<chaîne TPASS1...>" }`. |

Exemple contrôle (staff) :

```bash
curl -s -X POST "$APP_URL/api/v1/pass/validate" \
  -H "Content-Type: application/json" \
  -H "X-Teranga-Pass-Control: $TERANGA_PASS_CONTROL_KEY" \
  -d '{"qr":"TPASS1...."}'
```

Si `TERANGA_PASS_CONTROL_KEY` est vide : **503** sur `validate` (refus explicite).

## Mobile

- Écran **Mon Pass Teranga** (`PassQrScreen`) — dépendance `qr_flutter`.
- Entrée depuis la carte **INFOS JOJ** sur l’accueil : « Afficher mon Pass (QR) ».

## Variables d’environnement

Voir `.env.example` : `TERANGA_PASS_QR_SECRET`, `TERANGA_PASS_CONTROL_KEY`.

## Suite possible

- Admin : révoquer un billet, liste des `pass_tickets`.
- Passage en **offline** contrôle : export clés publiques / règles (hors scope MVP).
