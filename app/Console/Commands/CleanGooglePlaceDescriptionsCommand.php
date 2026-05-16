<?php

namespace App\Console\Commands;

use App\Models\Partner;
use Illuminate\Console\Command;

class CleanGooglePlaceDescriptionsCommand extends Command
{
    protected $signature = 'places:clean-descriptions';

    protected $description = 'Supprime les descriptions techniques « Importé depuis Google Places » des partenaires';

    public function handle(): int
    {
        $partners = Partner::query()
            ->whereNotNull('description')
            ->get();

        $cleaned = 0;
        foreach ($partners as $partner) {
            $desc = trim((string) $partner->description);
            if ($desc === '') {
                continue;
            }
            if (str_starts_with($desc, 'Importé depuis Google Places')
                || str_contains($desc, 'maps.google.com/?cid=')
                || str_contains($desc, 'google.com/maps')) {
                $partner->description = null;
                $partner->saveQuietly();
                $cleaned++;
            }
        }

        $this->info("{$cleaned} description(s) nettoyée(s) en base.");

        return self::SUCCESS;
    }
}
