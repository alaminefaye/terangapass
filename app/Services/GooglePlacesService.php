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

    /** Recherches texte pour types mal couverts en Nearby. */
    public const TEXT_SEARCH_QUERIES = [
        ['query' => 'ambassade Dakar Sénégal', 'category' => 'embassy'],
        ['query' => 'consulat Dakar Sénégal', 'category' => 'consulate'],
        ['query' => 'notaire Dakar Sénégal', 'category' => 'notary'],
        ['query' => 'supermarché Dakar Sénégal', 'category' => 'shop'],
        ['query' => 'station service Dakar Sénégal', 'category' => 'gas_station'],
    ];

    private readonly string $apiKey;

    private readonly float $centerLat;

    private readonly float $centerLng;

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

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int}
     */
    public function syncNearbyType(
        string $googleType,
        string $category,
        int $radiusMeters,
        ?callable $log = null
    ): array {
        $stats = ['created' => 0, 'updated' => 0, 'skipped' => 0, 'errors' => 0];
        $this->syncNearby($googleType, $category, $radiusMeters, $stats, $log);

        return $stats;
    }

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int}
     */
    public function syncTextQuery(string $query, string $category, ?callable $log = null): array
    {
        $stats = ['created' => 0, 'updated' => 0, 'skipped' => 0, 'errors' => 0];
        $this->syncTextSearch($query, $category, $stats, $log);

        return $stats;
    }

    /**
     * @param  callable(string): void|null  $log
     * @return array{created:int,updated:int,skipped:int,errors:int}
     */
    public function syncAll(int $radiusMeters = 50000, ?callable $log = null): array
    {
        if (! $this->isConfigured()) {
            throw new \RuntimeException('GOOGLE_MAPS_API_KEY manquant dans .env');
        }

        $stats = ['created' => 0, 'updated' => 0, 'skipped' => 0, 'errors' => 0];

        foreach (self::NEARBY_TYPE_MAP as $googleType => $category) {
            if ($log) {
                $log("Nearby: {$googleType} → {$category}");
            }
            $this->syncNearby($googleType, $category, $radiusMeters, $stats, $log);
        }

        foreach (self::TEXT_SEARCH_QUERIES as $item) {
            if ($log) {
                $log("Text: {$item['query']}");
            }
            $this->syncTextSearch($item['query'], $item['category'], $stats, $log);
        }

        return $stats;
    }

    /**
     * @param  array{created:int,updated:int,skipped:int,errors:int}  $stats
     */
    private function syncNearby(
        string $googleType,
        string $category,
        int $radiusMeters,
        array &$stats,
        ?callable $log
    ): void {
        $pageToken = null;

        do {
            $params = [
                'location' => "{$this->centerLat},{$this->centerLng}",
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

                return;
            }

            foreach ($payload['results'] ?? [] as $result) {
                $this->upsertFromSearchResult($result, $category, $stats, $log);
            }

            $pageToken = $payload['next_page_token'] ?? null;
        } while ($pageToken !== null && $pageToken !== '');
    }

    /**
     * @param  array{created:int,updated:int,skipped:int,errors:int}  $stats
     */
    private function syncTextSearch(string $query, string $category, array &$stats, ?callable $log): void
    {
        $pageToken = null;

        do {
            $params = [
                'query' => $query,
                'location' => "{$this->centerLat},{$this->centerLng}",
                'radius' => 50000,
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
                    $refs[] = $this->buildPhotoUrl($ref);
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
        $url = rtrim((string) config('google.places_base_url'), '/').'/'.$endpoint;

        try {
            $response = Http::timeout(25)->get($url, $params);
        } catch (\Throwable) {
            return null;
        }

        if (! $response->successful()) {
            return null;
        }

        $data = $response->json();
        if (! is_array($data)) {
            return null;
        }

        $status = $data['status'] ?? 'UNKNOWN';
        if ($status !== 'OK' && $status !== 'ZERO_RESULTS') {
            return null;
        }

        return $data;
    }
}
