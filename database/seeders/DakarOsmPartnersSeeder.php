<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

/**
 * Insère des partenaires générés depuis OpenStreetMap (fichier JSON).
 *
 * Génération du fichier :
 *   php artisan partners:export-osm-dakar --per-category=100
 *
 * Données : ODbL — https://www.openstreetmap.org/copyright
 */
class DakarOsmPartnersSeeder extends Seeder
{
    public function run(): void
    {
        $path = database_path('data/dakar_osm_partners.json');
        if (! is_file($path)) {
            if ($this->command) {
                $this->command->warn('Fichier absent : '.$path);
                $this->command->warn('Exécutez : php artisan partners:export-osm-dakar --per-category=100');
            }

            return;
        }

        $raw = file_get_contents($path);
        if ($raw === false) {
            return;
        }

        /** @var list<array<string, mixed>> $rows */
        $rows = json_decode($raw, true);
        if (! is_array($rows)) {
            return;
        }

        foreach ($rows as $row) {
            if (! is_array($row)) {
                continue;
            }

            Partner::query()->updateOrCreate(
                [
                    'name' => (string) ($row['name'] ?? ''),
                    'latitude' => $row['latitude'] ?? null,
                    'longitude' => $row['longitude'] ?? null,
                    'category' => (string) ($row['category'] ?? 'other'),
                ],
                [
                    'description' => $row['description'] ?? null,
                    'address' => (string) ($row['address'] ?? 'Dakar, Sénégal'),
                    'phone' => $row['phone'] ?? null,
                    'email' => $row['email'] ?? null,
                    'website' => $row['website'] ?? null,
                    'logo_url' => $row['logo_url'] ?? null,
                    'is_sponsor' => (bool) ($row['is_sponsor'] ?? false),
                    'visit_count' => (int) ($row['visit_count'] ?? 0),
                    'is_active' => (bool) ($row['is_active'] ?? true),
                ],
            );
        }
    }
}
