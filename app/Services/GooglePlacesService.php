<?php

namespace App\Services;

use App\Models\Partner;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

/**
 * Import des lieux via Google Places API (Legacy).
 *
 * @see https://developers.google.com/maps/documentation/places/web-service/search
 */
class GooglePlacesService
{
    public const PHOTO_REF_PREFIX = 'google_photo:';

    /** Types Google Nearby Search → catégorie Teranga Pass. */
    public const NEARBY_TYPE_MAP = [
        'restaurant' => 'restaurant',
        'lodging' => 'hotel',
        'pharmacy' => 'pharmacy',
        'hospital' => 'hospital',
        'gas_station' => 'gas_station',
        'school' => 'school',
        'university' => 'university',
        'supermarket' => 'shop',
        'bank' => 'bank',
        'doctor' => 'doctor',
        'dentist' => 'clinic',
        'lawyer' => 'lawyer',
        'local_government_office' => 'government',
        'place_of_worship' => 'religious_site',
    ];

    /** Modèles de recherche texte par ville/région (ambassades, notaires…). */
    public const TEXT_SEARCH_TEMPLATES = [
        ['template' => 'ambassade %s Sénégal', 'category' => 'embassy'],
        ['template' => 'consulat %s Sénégal', 'category' => 'consulate'],
        ['template' => 'notaire %s Sénégal', 'category' => 'notary'],
        ['template' => 'supermarché %s Sénégal', 'category' => 'shop'],
        ['template' => 'station service %s Sénégal', 'category' => 'gas_station'],
    ];

    private readonly string $apiKey;

    private readonly float $centerLat;

    private readonly float $centerLng;

    /** @var list<string> */
    private array $diagnosticErrors = [];

    public function __construct()
    {
        $this->apiKey = (string) config('google.maps_api_key');
        $this->centerLat = (float) config('google.places_sync_lat');
        $this->centerLng = (float) config('google.places_sync_lng');
    }

    public function isConfigured(): bool
    {
        return $this->apiKey !== '';
    }

    public function maskedApiKey(): string
    {
        if ($this->apiKey === '') {
            return '(vide)';
        }

        return substr($this->apiKey, 0, 8).'…'.substr($this->apiKey, -4);
    }

    /** @return list<string> */
    public function getDiagnosticErrors(): array
    {
        return $this->diagnosticErrors;
    }

    public function clearDiagnosticErrors(): void
    {
        $this->diagnosticErrors = [];
    }

    /**
     * @return list<array{id:string,name:string,lat:float,lng:float}>
     */
    public function syncZones(?string $regionId = null): array
    {
        $zones = config('google.places_sync_zones', []);
        if (! is_array($zones) || $zones === []) {
            return [[
                'id' => 'dakar',
                'name' => 'Dakar',
                'lat' => $this->centerLat,
                'lng' => $this->centerLng,
            ]];
        }

        if ($regionId === null || $regionId === '') {
            return array_values($zones);
        }

        $id = strtolower($regionId);

        return array_values(array_filter(
            $zones,
            fn (array $z) => strtolower((string) ($z['id'] ?? '')) === $id
        ));
    }

    /**
     * @return list<array{query:string,category:string}>
     */
    public function textQueriesForZone(string $zoneName): array
    {
        $queries = [];
        foreach (self::TEXT_SEARCH_TEMPLATES as $tpl) {
            $queries[] = [
                'query' => sprintf($tpl['template'], $zoneName),
                'category' => $tpl['category'],
            ];
        }

        return $queries;
    }

    /**
     * Un appel test Nearby Search (diagnostic).
     *
     * @return array{ok:bool,status:?string,error_message:?string,results_count:int,raw:?array}
     */
    public function probeNearbySearch(): array
    {
        $this->clearDiagnosticErrors();

        $raw = $this->requestRaw('nearbysearch/json', [
            'location' => "{$this->centerLat},{$this->centerLng}",
            'radius' => 1500,
            'type' => 'restaurant',
            'key' => $this->apiKey,
            'language' => 'fr',
        ]);

        if ($raw === null) {
            return [
                'ok' => false,
                'status' => null,
                'error_message' => $this->diagnosticErrors[0] ?? 'Réponse vide',
                'results_count' => 0,
                'raw' => null,
            ];
        }

        $status = (string) ($raw['status'] ?? 'UNKNOWN');

        return [
            'ok' => $status === 'OK' || $status === 'ZERO_RESULTS',
            'status' => $status,
            'error_message' => $raw['error_message'] ?? null,
            'results_count' => count($raw['results'] ?? []),
            'raw' => $raw,
        ];
    }

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}
     */
    public function syncNearbyType(
        string $googleType,
        string $category,
        int $radiusMeters,
        ?string $regionId = null,
        ?callable $log = null
    ): array {
        $this->clearDiagnosticErrors();
        $stats = $this->emptyStats();

        foreach ($this->syncZones($regionId) as $zone) {
            if ($log) {
                $log("Zone {$zone['name']} — Nearby {$googleType}");
            }
            $this->syncNearby(
                $googleType,
                $category,
                $radiusMeters,
                (float) $zone['lat'],
                (float) $zone['lng'],
                $stats,
                $log
            );
        }

        return $this->finalizeStats($stats);
    }

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}
     */
    public function syncTextQuery(
        string $query,
        string $category,
        ?string $regionId = null,
        ?callable $log = null
    ): array {
        $this->clearDiagnosticErrors();
        $stats = $this->emptyStats();
        $zones = $this->syncZones($regionId);
        if ($zones === []) {
            $this->recordError("Région inconnue : {$regionId}");

            return $this->finalizeStats($stats);
        }

        $radius = min(50000, (int) config('google.places_sync_radius', 50000));
        foreach ($zones as $zone) {
            if ($log) {
                $log("Zone {$zone['name']} — Text: {$query}");
            }
            $this->syncTextSearch(
                $query,
                $category,
                (float) $zone['lat'],
                (float) $zone['lng'],
                $radius,
                $stats,
                $log
            );
        }

        return $this->finalizeStats($stats);
    }

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}
     */
    public function syncAll(int $radiusMeters = 50000, ?string $regionId = null, ?callable $log = null): array
    {
        if (! $this->isConfigured()) {
            throw new \RuntimeException('GOOGLE_MAPS_API_KEY manquant dans .env');
        }

        $zones = $this->syncZones($regionId);
        if ($zones === []) {
            throw new \RuntimeException(
                $regionId
                    ? "Région « {$regionId} » introuvable. Lancez : php artisan places:list-zones"
                    : 'Aucune zone configurée dans config/google_places_zones.php'
            );
        }

        $this->clearDiagnosticErrors();
        $stats = $this->emptyStats();

        foreach ($zones as $zone) {
            $zoneName = (string) $zone['name'];
            if ($log) {
                $log('');
                $log("════ Zone : {$zoneName} ════");
            }

            foreach (self::NEARBY_TYPE_MAP as $googleType => $category) {
                if ($log) {
                    $log("  Nearby: {$googleType} → {$category}");
                }
                $this->syncNearby(
                    $googleType,
                    $category,
                    $radiusMeters,
                    (float) $zone['lat'],
                    (float) $zone['lng'],
                    $stats,
                    $log
                );
            }

            foreach ($this->textQueriesForZone($zoneName) as $item) {
                if ($log) {
                    $log("  Text: {$item['query']}");
                }
                $this->syncTextSearch(
                    $item['query'],
                    $item['category'],
                    (float) $zone['lat'],
                    (float) $zone['lng'],
                    $radiusMeters,
                    $stats,
                    $log
                );
            }
        }

        return $this->finalizeStats($stats);
    }

    /**
     * @return array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}
     */
    private function emptyStats(): array
    {
        return ['created' => 0, 'updated' => 0, 'skipped' => 0, 'errors' => 0, 'error_messages' => []];
    }

    /**
     * @param  array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}  $stats
     * @return array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}
     */
    private function finalizeStats(array $stats): array
    {
        $stats['error_messages'] = array_values(array_unique([
            ...$stats['error_messages'],
            ...$this->diagnosticErrors,
        ]));

        return $stats;
    }

    private function recordError(string $message): void
    {
        $this->diagnosticErrors[] = $message;
    }

    /**
     * @param  array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}  $stats
     */
    private function syncNearby(
        string $googleType,
        string $category,
        int $radiusMeters,
        float $centerLat,
        float $centerLng,
        array &$stats,
        ?callable $log
    ): void {
        $pageToken = null;

        do {
            $params = [
                'location' => "{$centerLat},{$centerLng}",
                'radius' => min($radiusMeters, 50000),
                'type' => $googleType,
                'key' => $this->apiKey,
                'language' => 'fr',
            ];
            if ($pageToken) {
                $params = [
                    'pagetoken' => $pageToken,
                    'key' => $this->apiKey,
                ];
                sleep(2);
            }

            $payload = $this->request('nearbysearch/json', $params);
            if ($payload === null) {
                $stats['errors']++;
                $stats['error_messages'] = array_merge(
                    $stats['error_messages'],
                    $this->diagnosticErrors
                );

                return;
            }

            foreach ($payload['results'] ?? [] as $result) {
                $this->upsertFromSearchResult($result, $category, $stats, $log);
            }

            $pageToken = $payload['next_page_token'] ?? null;
        } while ($pageToken !== null && $pageToken !== '');
    }

    /**
     * @param  array{created:int,updated:int,skipped:int,errors:int,error_messages:list<string>}  $stats
     */
    private function syncTextSearch(
        string $query,
        string $category,
        float $centerLat,
        float $centerLng,
        int $radiusMeters,
        array &$stats,
        ?callable $log
    ): void {
        $pageToken = null;

        do {
            $params = [
                'query' => $query,
                'location' => "{$centerLat},{$centerLng}",
                'radius' => min($radiusMeters, 50000),
                'key' => $this->apiKey,
                'language' => 'fr',
            ];
            if ($pageToken) {
                $params = [
                    'pagetoken' => $pageToken,
                    'key' => $this->apiKey,
                ];
                sleep(2);
            }

            $payload = $this->request('textsearch/json', $params);
            if ($payload === null) {
                $stats['errors']++;
                $stats['error_messages'] = array_merge(
                    $stats['error_messages'],
                    $this->diagnosticErrors
                );

                return;
            }

            foreach ($payload['results'] ?? [] as $result) {
                $this->upsertFromSearchResult($result, $category, $stats, $log);
            }

            $pageToken = $payload['next_page_token'] ?? null;
        } while ($pageToken !== null && $pageToken !== '');
    }

    /**
     * @param  array<string, mixed>  $result
     * @param  array{created:int,updated:int,skipped:int,errors:int}  $stats
     */
    private function upsertFromSearchResult(
        array $result,
        string $defaultCategory,
        array &$stats,
        ?callable $log
    ): void {
        $placeId = $result['place_id'] ?? null;
        if (! is_string($placeId) || $placeId === '') {
            $stats['skipped']++;

            return;
        }

        $existing = Partner::query()->where('google_place_id', $placeId)->first();
        $googleTypes = array_values(array_filter(
            is_array($result['types'] ?? null) ? $result['types'] : [],
            'is_string'
        ));
        $category = $this->resolveCategory($googleTypes, $defaultCategory);

        $lat = $result['geometry']['location']['lat'] ?? null;
        $lng = $result['geometry']['location']['lng'] ?? null;
        if (! is_numeric($lat) || ! is_numeric($lng)) {
            $stats['skipped']++;

            return;
        }

        $name = trim((string) ($result['name'] ?? ''));
        if ($name === '') {
            $stats['skipped']++;

            return;
        }

        $address = trim((string) ($result['vicinity'] ?? $result['formatted_address'] ?? ''));
        $rating = isset($result['rating']) ? round((float) $result['rating'], 1) : null;
        $isActive = ($result['business_status'] ?? 'OPERATIONAL') !== 'CLOSED_PERMANENTLY';

        $data = [
            'name' => $name,
            'category' => $category,
            'address' => $address !== '' ? $address : 'Dakar, Sénégal',
            'latitude' => $lat,
            'longitude' => $lng,
            'rating' => $rating,
            'google_types' => $googleTypes,
            'google_synced_at' => now(),
            'is_active' => $isActive,
        ];

        $needsDetails = ! $existing
            || empty($existing->phone)
            || empty($existing->opening_hours)
            || empty($existing->website);

        if ($needsDetails) {
            $details = $this->fetchPlaceDetails($placeId);
            if ($details !== null) {
                $data = array_merge($data, $details);
            }
            usleep(200_000);
        }

        if ($existing) {
            $existing->fill($data);
            $existing->google_place_id = $placeId;
            $existing->save();
            $stats['updated']++;
            if ($log) {
                $log("  ↻ {$name}");
            }
        } else {
            Partner::query()->create(array_merge($data, [
                'google_place_id' => $placeId,
                'description' => 'Importé depuis Google Places',
                'is_sponsor' => false,
                'visit_count' => 0,
            ]));
            $stats['created']++;
            if ($log) {
                $log("  + {$name}");
            }
        }
    }

    /**
     * @return array<string, mixed>|null
     */
    private function fetchPlaceDetails(string $placeId): ?array
    {
        $payload = $this->request('details/json', [
            'place_id' => $placeId,
            'fields' => implode(',', [
                'formatted_address',
                'formatted_phone_number',
                'international_phone_number',
                'website',
                'opening_hours',
                'rating',
                'photos',
                'url',
            ]),
            'key' => $this->apiKey,
            'language' => 'fr',
        ]);

        if ($payload === null) {
            return null;
        }

        $r = $payload['result'] ?? null;
        if (! is_array($r)) {
            return null;
        }

        $out = [];

        if (! empty($r['formatted_address'])) {
            $out['address'] = (string) $r['formatted_address'];
        }

        $phone = $r['formatted_phone_number'] ?? $r['international_phone_number'] ?? null;
        if (is_string($phone) && $phone !== '') {
            $out['phone'] = $phone;
        }

        if (! empty($r['website'])) {
            $out['website'] = (string) $r['website'];
        }

        if (isset($r['rating'])) {
            $out['rating'] = round((float) $r['rating'], 1);
        }

        $weekday = $r['opening_hours']['weekday_text'] ?? null;
        if (is_array($weekday) && $weekday !== []) {
            $out['opening_hours'] = implode(' + ', array_map('strval', $weekday));
        }

        $photos = $r['photos'] ?? [];
        if (is_array($photos) && $photos !== []) {
            $refs = [];
            foreach (array_slice($photos, 0, 5) as $photo) {
                $ref = is_array($photo) ? ($photo['photo_reference'] ?? null) : null;
                if (is_string($ref) && $ref !== '') {
                    $refs[] = self::PHOTO_REF_PREFIX.$ref;
                }
            }
            if ($refs !== []) {
                $out['photos'] = $refs;
                $out['logo_url'] = $refs[0];
            }
        }

        $mapsUrl = $r['url'] ?? null;
        if (is_string($mapsUrl) && $mapsUrl !== '') {
            $desc = 'Importé depuis Google Places';
            $out['description'] = $desc.' · '.Str::limit($mapsUrl, 200);
        }

        return $out;
    }

    public function buildPhotoUrl(string $photoReference, int $maxWidth = 800): string
    {
        return config('google.places_base_url').'/photo?'.http_build_query([
            'maxwidth' => $maxWidth,
            'photo_reference' => $photoReference,
            'key' => $this->apiKey,
        ]);
    }

    /**
     * Convertit une valeur stockée (URL absolue ou référence google_photo:…) en URL affichable.
     */
    public function resolveMediaUrl(?string $stored): ?string
    {
        if ($stored === null || trim($stored) === '') {
            return null;
        }

        $stored = trim($stored);
        if (str_starts_with($stored, 'http://') || str_starts_with($stored, 'https://')) {
            return $stored;
        }

        $ref = str_starts_with($stored, self::PHOTO_REF_PREFIX)
            ? substr($stored, strlen(self::PHOTO_REF_PREFIX))
            : $stored;

        if ($ref === '' || ! $this->isConfigured()) {
            return null;
        }

        return $this->buildPhotoUrl($ref);
    }

    /**
     * @return list<string>
     */
    public function resolvePhotoList(?array $photos): array
    {
        if ($photos === null || $photos === []) {
            return [];
        }

        $urls = [];
        foreach ($photos as $item) {
            if (! is_string($item)) {
                continue;
            }
            $url = $this->resolveMediaUrl($item);
            if ($url !== null) {
                $urls[] = $url;
            }
        }

        return $urls;
    }

    /**
     * @param  list<string>  $googleTypes
     */
    private function resolveCategory(array $googleTypes, string $fallback): string
    {
        $map = [
            'embassy' => 'embassy',
            'lodging' => 'hotel',
            'restaurant' => 'restaurant',
            'cafe' => 'restaurant',
            'meal_takeaway' => 'restaurant',
            'pharmacy' => 'pharmacy',
            'hospital' => 'hospital',
            'doctor' => 'doctor',
            'dentist' => 'clinic',
            'school' => 'school',
            'university' => 'university',
            'gas_station' => 'gas_station',
            'supermarket' => 'shop',
            'grocery_or_supermarket' => 'shop',
            'shopping_mall' => 'shop',
            'convenience_store' => 'shop',
            'bank' => 'bank',
            'atm' => 'bank',
            'lawyer' => 'lawyer',
            'courthouse' => 'government',
            'local_government_office' => 'government',
            'city_hall' => 'government',
            'place_of_worship' => 'religious_site',
            'church' => 'religious_site',
            'mosque' => 'religious_site',
        ];

        foreach ($googleTypes as $type) {
            if (isset($map[$type])) {
                return $map[$type];
            }
        }

        return $fallback;
    }

    /**
     * @param  array<string, string|int|float>  $params
     * @return array<string, mixed>|null
     */
    private function request(string $endpoint, array $params): ?array
    {
        $data = $this->requestRaw($endpoint, $params);
        if ($data === null) {
            return null;
        }

        $status = (string) ($data['status'] ?? 'UNKNOWN');
        if ($status === 'OK' || $status === 'ZERO_RESULTS') {
            return $data;
        }

        return null;
    }

    /**
     * @param  array<string, string|int|float>  $params
     * @return array<string, mixed>|null
     */
    private function requestRaw(string $endpoint, array $params): ?array
    {
        $url = rtrim((string) config('google.places_base_url'), '/').'/'.$endpoint;

        try {
            $response = Http::timeout(25)->get($url, $params);
        } catch (\Throwable $e) {
            $this->recordError("{$endpoint} : connexion impossible — ".$e->getMessage());

            return null;
        }

        $body = $response->json();
        if (! is_array($body)) {
            $this->recordError("{$endpoint} : HTTP {$response->status()} — réponse non JSON");

            return null;
        }

        $status = (string) ($body['status'] ?? 'UNKNOWN');
        $googleMessage = trim((string) ($body['error_message'] ?? ''));

        if ($status === 'OK' || $status === 'ZERO_RESULTS') {
            return $body;
        }

        $hint = match ($status) {
            'REQUEST_DENIED' => ' → Activez « Places API » sur Google Cloud, vérifiez la facturation, et autorisez cette clé pour le serveur (pas seulement Android/iOS).',
            'INVALID_REQUEST' => ' → Paramètres de requête invalides.',
            'OVER_QUERY_LIMIT' => ' → Quota dépassé ou facturation inactive.',
            'UNKNOWN_ERROR' => ' → Réessayez dans quelques secondes.',
            default => '',
        };

        $this->recordError(
            "{$endpoint} : {$status}"
            .($googleMessage !== '' ? " — {$googleMessage}" : '')
            .$hint
        );

        return $body;
    }
}
