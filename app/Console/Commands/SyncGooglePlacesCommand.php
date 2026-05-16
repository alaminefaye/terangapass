<?php

namespace App\Console\Commands;

use App\Services\GooglePlacesService;
use Illuminate\Console\Command;

class SyncGooglePlacesCommand extends Command
{
    protected $signature = 'places:sync-google
                            {--radius= : Rayon en mètres (max 50000, défaut config)}
                            {--type= : Un seul type Google Nearby (ex. restaurant)}
                            {--query= : Une seule recherche texte (ex. "notaire Dakar")}';

    protected $description = 'Importe les lieux Google Places (restaurants, hôtels, écoles…) dans la table partners';

    public function handle(GooglePlacesService $places): int
    {
        if (! $places->isConfigured()) {
            $this->error('Définissez GOOGLE_MAPS_API_KEY dans .env (Places API activée sur Google Cloud).');

            return self::FAILURE;
        }

        $radius = (int) ($this->option('radius') ?: config('google.places_sync_radius', 50000));
        $radius = min(max($radius, 1000), 50000);
        $log = fn (string $line) => $this->line($line);

        $this->info("Synchronisation Google Places — Dakar, rayon {$radius} m");

        if ($type = $this->option('type')) {
            $category = GooglePlacesService::NEARBY_TYPE_MAP[$type] ?? 'other';
            $stats = $places->syncNearbyType((string) $type, $category, $radius, $log);
        } elseif ($query = $this->option('query')) {
            $stats = $places->syncTextQuery((string) $query, 'other', $log);
        } else {
            $stats = $places->syncAll($radius, $log);
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

        if ((int) $stats['errors'] > 0 && (int) $stats['created'] === 0) {
            return self::FAILURE;
        }

        $this->info('Terminé. Les apps lisent /api/v1/tourism/points-of-interest et /api/v1/nearby.');

        return self::SUCCESS;
    }
}
