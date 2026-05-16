<?php

namespace App\Console\Commands;

use App\Services\GooglePlacesService;
use Illuminate\Console\Command;

class ListGooglePlacesZonesCommand extends Command
{
    protected $signature = 'places:list-zones';

    protected $description = 'Liste les régions/villes Sénégal utilisées pour l’import Google Places';

    public function handle(GooglePlacesService $places): int
    {
        $zones = $places->syncZones();
        $this->info(count($zones).' zone(s) — import avec : php artisan places:sync-google [--region=ID]');
        $this->newLine();

        $rows = array_map(fn (array $z) => [
            $z['id'] ?? '',
            $z['name'] ?? '',
            $z['lat'] ?? '',
            $z['lng'] ?? '',
        ], $zones);

        $this->table(['ID (--region=)', 'Nom', 'Latitude', 'Longitude'], $rows);

        $this->newLine();
        $this->line('Exemples :');
        $this->line('  php artisan places:sync-google                    # tout le Sénégal');
        $this->line('  php artisan places:sync-google --region=thies     # une région');
        $this->line('  php artisan places:sync-google --type=restaurant  # un type, toutes les zones');

        return self::SUCCESS;
    }
}
