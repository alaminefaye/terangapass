<?php

namespace App\Console\Commands;

use App\Services\GooglePlacesService;
use Illuminate\Console\Command;

class DiagnoseGooglePlacesCommand extends Command
{
    protected $signature = 'places:diagnose-google';

    protected $description = 'Teste la clé Google Places et affiche l’erreur exacte renvoyée par Google';

    public function handle(GooglePlacesService $places): int
    {
        $this->info('Diagnostic Google Places API');
        $this->line('Clé lue depuis .env : '.$places->maskedApiKey());

        if (! $places->isConfigured()) {
            $this->error('GOOGLE_MAPS_API_KEY est vide. Ajoutez-la dans .env puis : php artisan config:clear');

            return self::FAILURE;
        }

        $probe = $places->probeNearbySearch();

        $this->line('Statut Google : '.($probe['status'] ?? '—'));
        if (! empty($probe['error_message'])) {
            $this->line('Message Google : '.$probe['error_message']);
        }
        $this->line('Résultats trouvés : '.$probe['results_count']);

        foreach ($places->getDiagnosticErrors() as $err) {
            $this->error($err);
        }

        if ($probe['ok']) {
            $this->newLine();
            $this->info('OK — la clé fonctionne côté serveur. Lancez : php artisan places:sync-google --type=restaurant');

            return self::SUCCESS;
        }

        $this->newLine();
        $this->warn('Causes fréquentes :');
        $this->line('  1. Places API non activée (Google Cloud → APIs → Places API)');
        $this->line('  2. Facturation non activée sur le projet Google');
        $this->line('  3. Clé restreinte « Applications Android » uniquement — le serveur dent doit avoir une clé « Aucune restriction » ou « Adresses IP » avec l’IP du serveur');
        $this->line('  4. .env non rechargé : php artisan config:clear');

        return self::FAILURE;
    }
}
