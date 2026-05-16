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
        if (! $this->assertMultiZoneConfigLoaded()) {
            return self::FAILURE;
        }

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

    /**
     * Refuse l’import si le serveur n’a pas le code « tout le Sénégal » (24 zones).
     */
    private function assertMultiZoneConfigLoaded(): bool
    {
        $zones = config('google.places_sync_zones');
        $path = config_path('google_places_zones.php');

        if (! is_file($path)) {
            $this->error('Fichier manquant : config/google_places_zones.php');
            $this->line('Mettez à jour le code sur le serveur (git pull / déploiement) puis relancez.');

            return false;
        }

        if (! is_array($zones) || count($zones) < 10) {
            $this->error('Configuration zones invalide (attendu ~24 villes/régions du Sénégal).');
            $this->line('Votre serveur utilise encore l’ancienne version « Dakar seule ».');
            $this->line('Commandes après mise à jour : php artisan config:clear && php artisan places:list-zones');

            return false;
        }

        return true;
    }
}
