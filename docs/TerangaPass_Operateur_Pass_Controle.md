# Teranga Pass — Opérateur : contrôle QR et synchro révocations

**Public** : équipes d’accès / contrôle d’entrée utilisant un outil staff (scanner + appels HTTP).  
**Référence technique** : [TerangaPass_Etape6_Pass_QR.md](TerangaPass_Etape6_Pass_QR.md).

---

## Secret partagé

Toutes les requêtes staff ci-dessous exigent l’en-tête :

`X-Teranga-Pass-Control: <valeur de TERANGA_PASS_CONTROL_KEY>`

- Si la clé n’est pas configurée côté serveur : réponse **503**.
- Si l’en-tête est absent ou incorrect : **403**.

---

## Valider un QR scanné

`POST /api/v1/pass/validate` — corps JSON :

```json
{ "qr": "TPASS1...." }
```

Réponse **200** si le billet est actif et l’utilisateur non suspendu ; sinon message d’erreur en **422** (QR invalide, expiré, révoqué, etc.).

---

## Liste des billets révoqués (synchro)

`GET /api/v1/pass/revocations`

- Option **`since`** (ISO 8601) : uniquement les révocations **strictement après** cette date (delta pour rafraîchir un cache local).
- Réponse : `data.revoked[]` avec `public_id` et `revoked_at`, plus `count` et `generated_at`.

```bash
curl -s -G "$APP_URL/api/v1/pass/revocations" \
  -H "X-Teranga-Pass-Control: $TERANGA_PASS_CONTROL_KEY" \
  --data-urlencode "since=2026-05-01T00:00:00Z"
```

La validation d’un QR reste **autoritaire en ligne** via `POST /pass/validate` ; le flux révocations sert à tenir à jour une liste de passes invalides pour une détection rapide ou un mode dégradé documenté.
