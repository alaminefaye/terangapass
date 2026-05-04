<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;

/**
 * Exporte des partenaires depuis OpenStreetMap (Overpass) pour la zone de Dakar.
 * Licence données : ODbL (https://www.openstreetmap.org/copyright).
 *
 * Les numéros de téléphone sont souvent absents dans OSM (tags phone / contact:phone).
 */
class ExportDakarOsmPartnersCommand extends Command
{
    protected $signature = 'partners:export-osm-dakar
        {--per-category=100 : Nombre maximum d’éléments par catégorie}
        {--output=database/data/dakar_osm_partners.json : Chemin du fichier JSON généré (relatif à la racine du projet)}';

    protected $description = 'Télécharge des POIs OpenStreetMap (Dakar) et génère un JSON pour seeders (jusqu’à N par catégorie).';

    /** Bbox Dakar (sud, ouest, nord, est) — zone métropolitaine approximative. */
    private const BBOX = '14.62,-17.55,14.78,-17.38';

    /** Instances publiques (rotation si quota / 429). */
    private const OVERPASS_URLS = [
        'https://overpass-api.de/api/interpreter',
        'https://overpass.kumi.systems/api/interpreter',
    ];

    /**
     * @return array<string, list<array{overpass:string, category:string}>>
     */
    private function categoryQueries(): array
    {
        $b = self::BBOX;

        return [
            'restaurant' => [
                ['category' => 'restaurant', 'overpass' => "(node[\"amenity\"=\"restaurant\"]($b);way[\"amenity\"=\"restaurant\"]($b);relation[\"amenity\"=\"restaurant\"]($b););out center;"],
            ],
            'bank' => [
                ['category' => 'bank', 'overpass' => "(node[\"amenity\"=\"bank\"]($b);way[\"amenity\"=\"bank\"]($b);relation[\"amenity\"=\"bank\"]($b););out center;"],
            ],
            'gas_station' => [
                ['category' => 'gas_station', 'overpass' => "(node[\"amenity\"=\"fuel\"]($b);way[\"amenity\"=\"fuel\"]($b);relation[\"amenity\"=\"fuel\"]($b););out center;"],
            ],
            'hotel' => [
                ['category' => 'hotel', 'overpass' => "(node[\"tourism\"=\"hotel\"]($b);way[\"tourism\"=\"hotel\"]($b);relation[\"tourism\"=\"hotel\"]($b););out center;"],
            ],
            'pharmacy' => [
                ['category' => 'pharmacy', 'overpass' => "(node[\"amenity\"=\"pharmacy\"]($b);way[\"amenity\"=\"pharmacy\"]($b);relation[\"amenity\"=\"pharmacy\"]($b););out center;"],
            ],
            'hospital' => [
                ['category' => 'hospital', 'overpass' => "(node[\"amenity\"=\"hospital\"]($b);way[\"amenity\"=\"hospital\"]($b);relation[\"amenity\"=\"hospital\"]($b););out center;"],
            ],
            'clinic' => [
                ['category' => 'clinic', 'overpass' => "(node[\"amenity\"=\"clinic\"]($b);way[\"amenity\"=\"clinic\"]($b);relation[\"amenity\"=\"clinic\"]($b);node[\"healthcare\"=\"clinic\"]($b);way[\"healthcare\"=\"clinic\"]($b);relation[\"healthcare\"=\"clinic\"]($b););out center;"],
            ],
            'notary' => [
                ['category' => 'notary', 'overpass' => "(node[\"office\"=\"notary\"]($b);way[\"office\"=\"notary\"]($b);relation[\"office\"=\"notary\"]($b););out center;"],
            ],
            'lawyer' => [
                ['category' => 'lawyer', 'overpass' => "(node[\"office\"=\"lawyer\"]($b);way[\"office\"=\"lawyer\"]($b);relation[\"office\"=\"lawyer\"]($b););out center;"],
            ],
            'doctor' => [
                ['category' => 'doctor', 'overpass' => "(node[\"amenity\"=\"doctors\"]($b);way[\"amenity\"=\"doctors\"]($b);relation[\"amenity\"=\"doctors\"]($b);node[\"healthcare\"=\"doctor\"]($b);way[\"healthcare\"=\"doctor\"]($b);relation[\"healthcare\"=\"doctor\"]($b););out center;"],
            ],
            'government' => [
                ['category' => 'government', 'overpass' => "(node[\"amenity\"=\"townhall\"]($b);way[\"amenity\"=\"townhall\"]($b);relation[\"amenity\"=\"townhall\"]($b);node[\"office\"=\"government\"]($b);way[\"office\"=\"government\"]($b);relation[\"office\"=\"government\"]($b);node[\"amenity\"=\"courthouse\"]($b);way[\"amenity\"=\"courthouse\"]($b);relation[\"amenity\"=\"courthouse\"]($b););out center;"],
            ],
            'school' => [
                ['category' => 'school', 'overpass' => "(node[\"amenity\"=\"school\"]($b);way[\"amenity\"=\"school\"]($b);relation[\"amenity\"=\"school\"]($b););out center;"],
            ],
            'university' => [
                ['category' => 'university', 'overpass' => "(node[\"amenity\"=\"university\"]($b);way[\"amenity\"=\"university\"]($b);relation[\"amenity\"=\"university\"]($b);node[\"amenity\"=\"college\"]($b);way[\"amenity\"=\"college\"]($b);relation[\"amenity\"=\"college\"]($b););out center;"],
            ],
            'media' => [
                ['category' => 'media', 'overpass' => "(node[\"office\"=\"newspaper\"]($b);way[\"office\"=\"newspaper\"]($b);relation[\"office\"=\"newspaper\"]($b);node[\"amenity\"=\"studio\"]($b);way[\"amenity\"=\"studio\"]($b);relation[\"amenity\"=\"studio\"]($b);node[\"amenity\"=\"radio_station\"]($b);way[\"amenity\"=\"radio_station\"]($b);relation[\"amenity\"=\"radio_station\"]($b););out center;"],
            ],
            'professional_service' => [
                ['category' => 'professional_service', 'overpass' => "(node[\"office\"=\"accountant\"]($b);way[\"office\"=\"accountant\"]($b);relation[\"office\"=\"accountant\"]($b);node[\"office\"=\"consulting\"]($b);way[\"office\"=\"consulting\"]($b);relation[\"office\"=\"consulting\"]($b);node[\"office\"=\"insurance\"]($b);way[\"office\"=\"insurance\"]($b);relation[\"office\"=\"insurance\"]($b););out center;"],
            ],
            'religious_site' => [
                ['category' => 'religious_site', 'overpass' => "(node[\"amenity\"=\"place_of_worship\"]($b);way[\"amenity\"=\"place_of_worship\"]($b);relation[\"amenity\"=\"place_of_worship\"]($b););out center;"],
            ],
            'shop' => [
                ['category' => 'shop', 'overpass' => "(node[\"shop\"=\"supermarket\"]($b);way[\"shop\"=\"supermarket\"]($b);relation[\"shop\"=\"supermarket\"]($b);node[\"shop\"=\"convenience\"]($b);way[\"shop\"=\"convenience\"]($b);relation[\"shop\"=\"convenience\"]($b);node[\"shop\"=\"mall\"]($b);way[\"shop\"=\"mall\"]($b);relation[\"shop\"=\"mall\"]($b);node[\"shop\"=\"department_store\"]($b);way[\"shop\"=\"department_store\"]($b);relation[\"shop\"=\"department_store\"]($b););out center;"],
            ],
        ];
    }

    public function handle(): int
    {
        $perCategory = max(1, (int) $this->option('per-category'));
        $outputPath = base_path($this->option('output'));

        $this->info('Export OSM Dakar — max '.$perCategory.' / catégorie (bbox '.self::BBOX.').');
        $this->warn('Données : OpenStreetMap (ODbL). Les téléphones sont souvent absents dans OSM.');

        $all = [];
        $seenIds = [];

        foreach ($this->categoryQueries() as $queries) {
            $bucket = [];

            foreach ($queries as $q) {
                $body = '[out:json][timeout:120];'.$q['overpass'];
                $this->line('Requête : '.$q['category'].' …');

                // Overpass refuse souvent les clients qui envoient Accept: application/json (406).
                $response = $this->postOverpassWithRetry($body);
                if ($response === null) {
                    return self::FAILURE;
                }

                usleep(4_000_000);

                $json = $response->json();
                $elements = $json['elements'] ?? [];

                foreach ($elements as $el) {
                    $osmId = ($el['type'] ?? '').':'.($el['id'] ?? '');
                    if ($osmId === ':' || isset($seenIds[$osmId])) {
                        continue;
                    }

                    $tags = $el['tags'] ?? [];
                    $lat = null;
                    $lon = null;
                    if (($el['type'] ?? '') === 'node') {
                        $lat = $el['lat'] ?? null;
                        $lon = $el['lon'] ?? null;
                    } else {
                        $lat = $el['center']['lat'] ?? null;
                        $lon = $el['center']['lon'] ?? null;
                    }
                    if ($lat === null || $lon === null) {
                        continue;
                    }

                    $name = $tags['name'] ?? $tags['name:fr'] ?? $tags['name:wo'] ?? null;
                    if ($name === null || trim((string) $name) === '') {
                        $name = 'Lieu OSM ('.$q['category'].') #'.$el['id'];
                    }

                    $address = $this->buildAddress($tags);
                    if ($address === '') {
                        $address = 'Dakar, Sénégal';
                    }

                    $phone = $tags['phone'] ?? $tags['contact:phone'] ?? $tags['contact:mobile'] ?? null;
                    if (is_string($phone)) {
                        $phone = trim($phone);
                        if ($phone === '') {
                            $phone = null;
                        }
                    }

                    $website = $tags['website'] ?? $tags['contact:website'] ?? null;
                    if (is_string($website)) {
                        $website = trim($website);
                        if ($website === '') {
                            $website = null;
                        }
                    }

                    $bucket[] = [
                        'category' => $q['category'],
                        'name' => (string) $name,
                        'description' => 'Source : OpenStreetMap (ODbL). OSM '.$osmId.'.',
                        'address' => $address,
                        'latitude' => round((float) $lat, 8),
                        'longitude' => round((float) $lon, 8),
                        'phone' => $phone,
                        'email' => null,
                        'website' => $website,
                        'logo_url' => null,
                        'is_sponsor' => false,
                        'visit_count' => 0,
                        'is_active' => true,
                    ];
                    $seenIds[$osmId] = true;
                }
            }

            $bucket = array_slice($bucket, 0, $perCategory);
            $all = array_merge($all, $bucket);
        }

        $dir = dirname($outputPath);
        if (! is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        file_put_contents($outputPath, json_encode($all, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

        $this->info('Écrit : '.$outputPath.' ('.count($all).' lignes).');
        $counts = [];
        foreach ($all as $row) {
            $c = $row['category'];
            $counts[$c] = ($counts[$c] ?? 0) + 1;
        }
        ksort($counts);
        foreach ($counts as $c => $n) {
            $this->line(sprintf('  %-22s %d', $c, $n));
        }

        return self::SUCCESS;
    }

    /**
     * @param  array<string, string>  $tags
     */
    private function buildAddress(array $tags): string
    {
        $parts = array_filter([
            $tags['addr:housenumber'] ?? null,
            $tags['addr:street'] ?? null,
            $tags['addr:suburb'] ?? null,
            $tags['addr:city'] ?? null,
            $tags['addr:postcode'] ?? null,
        ], fn ($v) => is_string($v) && trim($v) !== '');

        return implode(', ', array_map('trim', $parts));
    }

    private function postOverpassWithRetry(string $body): ?Response
    {
        $attempts = 0;
        $maxAttempts = 8;

        while ($attempts < $maxAttempts) {
            $attempts++;
            $url = self::OVERPASS_URLS[($attempts - 1) % count(self::OVERPASS_URLS)];

            $response = Http::timeout(180)
                ->withHeaders([
                    'Accept' => '*/*',
                    'User-Agent' => 'TerangaPassOSMExport/1.0',
                ])
                ->asForm()
                ->post($url, ['data' => $body]);

            if ($response->successful()) {
                return $response;
            }

            $code = $response->status();
            if (in_array($code, [429, 502, 503, 504], true)) {
                $wait = min(60, 5 * $attempts);
                $this->warn("Overpass HTTP {$code} sur {$url} — nouvel essai dans {$wait}s …");
                sleep($wait);

                continue;
            }

            $this->error("Overpass HTTP {$code} sur {$url}");

            return null;
        }

        $this->error('Overpass : trop de tentatives échouées.');

        return null;
    }
}
