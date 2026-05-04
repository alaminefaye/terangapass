# Analyse — Document « 200 types de boîtes / Wi‑Fi communautaire »

## Source

Fichier Word fourni par l’utilisateur : **« Document – 200 Types De Boîtes, Espaces Publics Et Lieux Propices À L’implémentation D’un Wi‑fi Communautaire Ou Clientèle (3).docx »** (liste commerciale / prospect Wi‑Fi : typologie de lieux puis inventaire détaillé avec téléphones `+221`).

## Contenu utile pour TerangaPass

- **Partie structurante** : taxonomie (hôtellerie, commerce, santé, transport, etc.) — utile **produit / prospection**, pas importée telle quelle en base.
- **Partie exploitable en annuaire** : blocs **hôtels / résidences / lodges** et **restaurants / cafés** au format répété  
  `Nom — Adresse — +221 … — Sous-type — Usage Wi‑Fi`  
  (dans le fichier, les entrées sont **concaténées** sans saut de ligne entre la fin d’une ligne et le nom suivant).

## Traitement dans le dépôt

| Élément | Rôle |
|--------|------|
| `scripts/extract_wifi_200_docx.py` | Lit le `.docx`, découpe la liste à partir de « Hôtel Faidherbe », tronque avant la section « (781–840) » (lieux religieux / autre gabarit), retire le titre de section collé aux restos, nettoie les morceaux de texte collés après une note Wi‑Fi, filtre les lignes corrompues, déduit `hotel` / `restaurant`, pose des **coordonnées approximatives** par zone (démo). |
| `database/data/wifi_venues_from_docx.json` | Export versionné des lignes retenues (régénérable en relançant le script si le Word change). |
| `DirectoryWifiProspectsDocxSeeder` | Crée ou met à jour des **`partners`** (`updateOrCreate` par **nom**), avec téléphone, adresse, description (sous-type + note Wi‑Fi), catégorie, lat/lng. |

## Limites (à lire avant prod)

- **Exactitude** : le document mélange référence commerciale et données non vérifiées ici ; téléphones et noms doivent être **validés** avant usage public.
- **Géolocalisation** : positions = **centroïdes par quartier / ville** + léger décalage, pas du géocodage adresse par adresse.
- **Doublons téléphone** : quelques numéros apparaissent plusieurs fois dans le source ; le seeder **clé sur le nom** pour éviter d’écraser des fiches distinctes à tort.
- **Périmètre import** : les sections après `(781–840)` (religieux, industrie, etc.) ne suivent pas le même motif ; elles sont **hors JSON** pour l’instant (sinon parses invalides).

## Commande utile

```bash
python3 scripts/extract_wifi_200_docx.py "/chemin/vers/le.docx"
php artisan db:seed --class=DirectoryWifiProspectsDocxSeeder
```

Si le `.docx` est sur le Bureau et contient `200` et `Types` dans le nom, le script peut être lancé **sans argument**.
