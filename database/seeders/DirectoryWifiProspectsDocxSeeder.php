<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;
use JsonException;

/**
 * Partenaires issus du document « 200 types de boîtes / Wi‑Fi communautaire » (liste hôtels & restos Sénégal).
 * Données : database/data/wifi_venues_from_docx.json (généré par scripts/extract_wifi_200_docx.py).
 */
class DirectoryWifiProspectsDocxSeeder extends Seeder
{
    public function run(): void
    {
        $path = database_path('data/wifi_venues_from_docx.json');
        if (! File::isReadable($path)) {
            if ($this->command !== null) {
                $this->command->warn('Fichier manquant : database/data/wifi_venues_from_docx.json — exécuter scripts/extract_wifi_200_docx.py');
            }

            return;
        }

        try {
            /** @var array{rows: array<int, array<string, mixed>>} $payload */
            $payload = json_decode(File::get($path), true, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            if ($this->command !== null) {
                $this->command->error('JSON invalide : '.$e->getMessage());
            }

            return;
        }

        foreach ($payload['rows'] as $row) {
            $name = (string) ($row['name'] ?? '');
            if ($name === '') {
                continue;
            }

            $phone = isset($row['phone']) ? (string) $row['phone'] : null;
            $subtype = isset($row['subtype']) ? trim((string) $row['subtype']) : '';
            $wifi = isset($row['wifi_note']) ? trim((string) $row['wifi_note']) : '';
            $parts = array_filter([$subtype, $wifi]);
            $description = $parts === [] ? null : implode(' — ', $parts);

            Partner::query()->updateOrCreate(
                ['name' => $name],
                [
                    'category' => (string) ($row['category'] ?? 'hotel'),
                    'description' => $description,
                    'address' => (string) ($row['address'] ?? ''),
                    'latitude' => $row['latitude'] ?? null,
                    'longitude' => $row['longitude'] ?? null,
                    'phone' => $phone ?: null,
                    'email' => null,
                    'website' => null,
                    'logo_url' => null,
                    'is_sponsor' => false,
                    'visit_count' => 0,
                    'is_active' => true,
                ]
            );
        }
    }
}
