-- Marquer la migration en doublon comme déjà exécutée
-- Exécutez cette commande SQL dans votre base de données si la migration est déjà dans la table migrations

-- Option 1: Si la migration est déjà dans la table migrations, ne rien faire
-- Option 2: Si vous voulez la supprimer de la table migrations:
-- DELETE FROM migrations WHERE migration = '2026_01_20_015341_create_personal_access_tokens_table';

-- Option 3: Si elle n'est pas dans la table, insérez-la pour marquer comme exécutée:
INSERT IGNORE INTO migrations (migration, batch) 
VALUES ('2026_01_20_015341_create_personal_access_tokens_table', 
        (SELECT COALESCE(MAX(batch), 0) FROM migrations m WHERE m.migration != '2026_01_20_015341_create_personal_access_tokens_table'));
