<?php

namespace App\Console\Commands;

use App\Services\GooglePlacesService;
use Illuminate\Console\Command;

class SyncGooglePlacesCommand extends Command
{
    protected $signature = 'places:sync-google
                            {--radius= : Rayon en mètres par zone (max 50000)}
                            {--region= : Une seule zone (ID : dakar, thies, saint_louis… — places:list-zones)}
                            {--type= : Un seul type Google Nearby (ex. restaurant)}
                            {--query= : Une seule recherche texte (ex. "notaire Thiès")}';

    protected $description = 'Importe les lieux Google Places dans partners (tout le Sénégal par défaut)';

    public function handle(GooglePlacesService $places): int
    {
        if (! $places->isConfigured()) {
            $this->error('Définissez GOOGLE_MAPS_API_KEY dans .env (Places API activée sur Google Cloud).');

            return self::FAILURE;
        }

        $radius = (int) ($this->option('radius') ?: config('google.places_sync_radius', 50000));
        $radius = min(max($radius, 1000), 50000);
        $region = $this->option('region');
        $regionLabel = $region ? (string) $region : 'tout le Sénégal ('.count($places->syncZones()).' zones)';
        $log = fn (string $line) => $this->line($line);

        $this->info("Synchronisation Google Places — {$regionLabel}, rayon {$radius} m/zone");

        if ($region && $places->syncZones((string) $region) === []) {
            $this->error("Région « {$region} » inconnue. Voir : php artisan places:list-zones");

            return self::FAILURE;
        }

        if ($type = $this->option('type')) {
            $category = GooglePlacesService::NEARBY_TYPE_MAP[$type] ?? 'other';
            $stats = $places->syncNearbyType((string) $type, $category, $radius, $region ? (string) $region : null, $log);
        } elseif ($query = $this->option('query')) {
            $stats = $places->syncTextQuery(
                (string) $query,
                'other',
                $region ? (string) $region : null,
                $log
            );
        } else {
            $stats = $places->syncAll($radius, $region ? (string) $region : null, $log);
        }

        $this->newLine();
        $this->table(
            ['Créés', 'Mis à jour', 'Ignorés', 'Erreurs'],
            [[$stats['created'], $stats['updated'], $stats['skipped'], $stats['errors']]]
        );

        $messages = $stats['error_messages'] ?? [];
        if ($messages !== []) {
            $this->newLine();
            $this->error('Erreurs Google (détail) :');
            foreach (array_unique($messages) as $msg) {
                $this->line('  • '.$msg);
            }
            $this->newLine();
            $this->warn('Diagnostic : php artisan places:diagnose-google');
        } elseif ((int) $stats['errors'] > 0) {
            $this->warn('Erreurs sans détail — lancez : php artisan places:diagnose-google');
        }

        if ((int) $stats['errors'] > 0 && (int) $stats['created'] === 0 && (int) $stats['updated'] === 0) {
            return self::FAILURE;
        }

        $this->info('Terminé. Les apps lisent /api/v1/tourism/points-of-interest et /api/v1/nearby.');

        return self::SUCCESS;
    }
}
