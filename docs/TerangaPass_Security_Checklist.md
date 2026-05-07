# Teranga Pass — Recommandations sécurité (rappel 2.3)

Aligné au plan [TerangaPass_Plan_Etape_par_Etape.md](TerangaPass_Plan_Etape_par_Etape.md) — étape 2.3.

---

## Transport et exposition

- **HTTPS** uniquement en production pour `APP_URL` et les appels API depuis l’app.
- Ne pas commiter de **secrets** : `.env` hors dépôt ; `TERANGA_PASS_QR_SECRET`, `TERANGA_PASS_CONTROL_KEY` uniquement en configuration serveur / CI secrets.

## Contrôle Pass (staff)

- `POST /api/v1/pass/validate` et `GET /api/v1/pass/revocations` exigent **`X-Teranga-Pass-Control`** égal à `TERANGA_PASS_CONTROL_KEY`.
- Si la clé n’est pas configurée : réponse **503** (refus explicite).
- Réutiliser la même clé pour les deux routes ; rotation = mise à jour `.env` + redéploiement des terminaux staff.

## QR utilisateur

- Le payload `TPASS1` est **signé** (HMAC) ; ne pas exposer `TERANGA_PASS_QR_SECRET` côté client.
- La **révocation** côté admin doit précéder tout accès : un utilisateur avec historique révoqué ne reçoit pas de nouveau billet automatique via `GET /pass/ticket`.

## Tokens et comptes

- Jetons API : durée de vie et révocation à définir avec la stratégie auth (Sanctum / équivalent).
- Comptes **suspendus** : réponses **403** cohérentes sur les routes protégées.

## Tuiles carte (OSM)

- Respecter la **politique d’usage** des tuiles publiques ([OSMF](https://operations.osmfoundation.org/policies/tiles/)) : user-agent identifiant l’app, pas de surcharge abusive.
