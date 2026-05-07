# Teranga Pass — Étape 6 — Pass QR (pilote billetterie)

**Plan** : [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — étape 6.  
**Opérateur (staff)** : [TerangaPass_Operateur_Pass_Controle.md](TerangaPass_Operateur_Pass_Controle.md).  
**Dernière mise à jour** : 7 mai 2026.

## Périmètre livré (MVP)

- **Sans paiement in-app** (étape 5 reportée) : billet pilote `joj_visitor_pilot`, délivré automatiquement au **premier** appel API si l’utilisateur n’a **aucun** billet passé ou si ses anciens billets sont **uniquement expirés** (sans révocation).
- **Révocation admin** : si l’utilisateur a au moins une ligne `pass_tickets` révoquée, `GET /pass/ticket` renvoie **403** et **ne recrée pas** de billet (évite de contourner une désactivation).
- **QR signé** : préfixe `TPASS1.` + payload JSON + signature **HMAC-SHA256** (`TERANGA_PASS_QR_SECRET` ou repli sur dérivation `APP_KEY` en dev via `AppServiceProvider`).
- **Révocation / expiration** : champs `status`, `revoked_at`, `valid_until` sur `pass_tickets` ; le contrôle serveur refuse si billet inactif ou utilisateur suspendu.

## API

| Méthode | Chemin | Auth | Rôle |
|---------|--------|------|------|
| `GET` | `/api/v1/pass/ticket` | Bearer (jeton actuel) | Retourne `qr_payload` + méta (type, validité). Crée un billet s’il n’y en a pas d’actif. |
| `POST` | `/api/v1/pass/validate` | En-tête **`X-Teranga-Pass-Control`** = valeur de `TERANGA_PASS_CONTROL_KEY` | Vérifie un QR scanné. Corps JSON : `{ "qr": "<chaîne TPASS1...>" }`. |
| `GET` | `/api/v1/pass/revocations` | Même en-tête que `validate` | Liste des billets **révoqués** (`public_id`, `revoked_at`). Query optionnelle : `since=ISO8601` pour ne récupérer que les révocations strictement **après** cette date (synchro staff / base d’un futur contrôle partiellement hors ligne). |

Exemple contrôle (staff) :

```bash
curl -s -X POST "$APP_URL/api/v1/pass/validate" \
  -H "Content-Type: application/json" \
  -H "X-Teranga-Pass-Control: $TERANGA_PASS_CONTROL_KEY" \
  -d '{"qr":"TPASS1...."}'
```

Si `TERANGA_PASS_CONTROL_KEY` est vide : **503** sur `validate` et `revocations` (refus explicite).

Exemple flux révocations (delta) :

```bash
curl -s -G "$APP_URL/api/v1/pass/revocations" \
  -H "X-Teranga-Pass-Control: $TERANGA_PASS_CONTROL_KEY" \
  --data-urlencode "since=2026-05-01T00:00:00Z"
```

## Mobile

- Écran **Mon Pass Teranga** (`PassQrScreen`) — dépendance `qr_flutter`.
- Entrée depuis la carte **INFOS JOJ** sur l’accueil : « Afficher mon Pass (QR) ».

## Variables d’environnement

Voir `.env.example` : `TERANGA_PASS_QR_SECRET`, `TERANGA_PASS_CONTROL_KEY`.

## Administration (Laravel)

- Menu **Pass QR** : `/admin/pass-tickets` — liste, filtres, bouton **Révoquer** (statut + `revoked_at`).
- **Redélivrer** : pour une ligne sans pass actif (révoqué ou expiré), émet un **nouveau** billet (`public_id` neuf, validité +1 an pilote). Refus si l’utilisateur a déjà un pass actif ou si c’est un compte `admin`.
- Routes : `admin.pass-tickets.index`, `admin.pass-tickets.revoke`, `admin.pass-tickets.reissue`.

## API — message pass désactivé

- Si l’utilisateur a un historique révoqué et aucun pass actif, `GET /pass/ticket` renvoie **403** avec un texte **FR ou EN** selon l’en-tête **`Accept-Language`** (préfixe `en` ou variantes `en-us` / `en-gb`).

## Suite possible

- Contrôle **partiellement hors ligne** : l’app staff peut périodiquement appeler `GET /pass/revocations` et maintenir un **set** de `public_id` invalides en cache ; la validation reste autoritaire côté serveur en ligne.
