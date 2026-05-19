<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

class UtilityController extends Controller
{
    /**
     * Manifeste du pack hors ligne — bundles POI + sites JOJ (étape 7).
     */
    public function offlineManifest(): JsonResponse
    {
        $poiRequest = Request::create('/api/v1/tourism/points-of-interest', 'GET');
        $poiResponse = app(TourismController::class)->pointsOfInterest($poiRequest);
        $poiRaw = $poiResponse->getContent();

        $sitesResponse = app(CompetitionSiteController::class)->index();
        $sitesRaw = $sitesResponse->getContent();

        $embassiesRequest = Request::create('/api/v1/tourism/embassies', 'GET');
        $embassiesResponse = app(TourismController::class)->embassies($embassiesRequest);
        $embassiesRaw = $embassiesResponse->getContent();

        $calendarResponse = app(CompetitionSiteController::class)->calendar();
        $calendarRaw = $calendarResponse->getContent();

        $audioRequest = Request::create('/api/v1/announcements/audio', 'GET');
        $audioResponse = app(AudioAnnouncementController::class)->index($audioRequest);
        $audioRaw = $audioResponse->getContent();

        $bundles = [
            [
                'id' => 'poi',
                'kind' => 'json',
                'url' => url('api/v1/utility/offline-bundle/poi'),
                'sha256' => hash('sha256', $poiRaw),
                'byte_size' => strlen($poiRaw),
            ],
            [
                'id' => 'competition_sites',
                'kind' => 'json',
                'url' => url('api/v1/utility/offline-bundle/competition-sites'),
                'sha256' => hash('sha256', $sitesRaw),
                'byte_size' => strlen($sitesRaw),
            ],
            [
                'id' => 'embassies',
                'kind' => 'json',
                'url' => url('api/v1/utility/offline-bundle/embassies'),
                'sha256' => hash('sha256', $embassiesRaw),
                'byte_size' => strlen($embassiesRaw),
            ],
            [
                'id' => 'competition_calendar',
                'kind' => 'json',
                'url' => url('api/v1/utility/offline-bundle/competition-calendar'),
                'sha256' => hash('sha256', $calendarRaw),
                'byte_size' => strlen($calendarRaw),
            ],
            [
                'id' => 'audio_announcements',
                'kind' => 'json',
                'url' => url('api/v1/utility/offline-bundle/audio-announcements'),
                'sha256' => hash('sha256', $audioRaw),
                'byte_size' => strlen($audioRaw),
            ],
        ];

        return response()->json([
            'data' => [
                'schema_version' => 1,
                'pack_version' => config('terangapass.offline_catalog_version'),
                'generated_at' => now()->toIso8601String(),
                'min_app_semver' => null,
                'bundles' => $bundles,
            ],
        ]);
    }

    /**
     * Météo locale via Open-Meteo (gratuit) — cache 20 min par position arrondie.
     */
    public function weather(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'lat' => ['required', 'numeric', 'between:-90,90'],
            'lng' => ['required', 'numeric', 'between:-180,180'],
        ]);

        $lat = round((float) $validated['lat'], 2);
        $lng = round((float) $validated['lng'], 2);
        $cacheKey = "weather:v1:{$lat}:{$lng}";

        $payload = Cache::remember($cacheKey, now()->addMinutes(20), function () use ($lat, $lng) {
            $response = Http::timeout(10)->get('https://api.open-meteo.com/v1/forecast', [
                'latitude' => $lat,
                'longitude' => $lng,
                'current' => 'temperature_2m,weather_code',
                'timezone' => 'auto',
            ]);

            if (! $response->successful()) {
                return null;
            }

            $json = $response->json();
            $current = $json['current'] ?? [];
            $code = (int) ($current['weather_code'] ?? -1);
            $temp = $current['temperature_2m'] ?? null;

            if ($temp === null) {
                return null;
            }

            return [
                'latitude' => $lat,
                'longitude' => $lng,
                'temperature_c' => round((float) $temp),
                'weather_code' => $code,
                'label' => $this->weatherLabelFr($code),
                'icon' => $this->weatherIconKey($code),
                'timezone' => $json['timezone'] ?? 'Africa/Dakar',
                'source' => 'open-meteo',
                'fetched_at' => now()->toIso8601String(),
            ];
        });

        if ($payload === null) {
            return response()->json([
                'message' => 'Météo indisponible pour le moment.',
            ], 503);
        }

        return response()->json(['data' => $payload]);
    }

    private function weatherLabelFr(int $code): string
    {
        return match (true) {
            $code === 0 => 'Ensoleillé',
            in_array($code, [1, 2, 3], true) => 'Partiellement nuageux',
            in_array($code, [45, 48], true) => 'Brume',
            in_array($code, [51, 53, 55, 56, 57], true) => 'Bruine',
            in_array($code, [61, 63, 65, 66, 67, 80, 81, 82], true) => 'Pluie',
            in_array($code, [71, 73, 75, 77, 85, 86], true) => 'Neige',
            in_array($code, [95, 96, 99], true) => 'Orage',
            default => 'Nuageux',
        };
    }

    private function weatherIconKey(int $code): string
    {
        return match (true) {
            $code === 0 => 'sunny',
            in_array($code, [1, 2, 3], true) => 'partly_cloudy',
            in_array($code, [45, 48], true) => 'fog',
            in_array($code, [51, 53, 55, 61, 63, 65, 80, 81, 82], true) => 'rain',
            in_array($code, [95, 96, 99], true) => 'thunderstorm',
            default => 'cloudy',
        };
    }

    public function jojCountdown()
    {
        // Date d'ouverture JOJ Dakar 2026 (référence cahier des charges).
        $startDate = Carbon::create(2026, 10, 31, 0, 0, 0, 'Africa/Dakar');
        $today = Carbon::now('Africa/Dakar')->startOfDay();

        $days = $today->diffInDays($startDate, false);

        return response()->json([
            'data' => [
                'target_date' => $startDate->toDateString(),
                'days_remaining' => max(0, $days),
                'status' => $days < 0 ? 'started' : 'upcoming',
                'label' => 'Dakar 2026 - 31 oct -> 13 nov',
            ],
        ]);
    }

    public function convertCurrency(Request $request)
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0'],
            'from' => ['required', 'string', 'size:3'],
            'to' => ['required', 'string', 'size:3'],
        ]);

        $from = strtoupper($validated['from']);
        $to = strtoupper($validated['to']);
        $amount = (float) $validated['amount'];

        // MVP: taux fixes robustes pour XOF/EUR/USD.
        $baseRates = [
            'XOF' => 1.0,
            'EUR' => 655.957,
            'USD' => 600.0,
        ];

        if (! isset($baseRates[$from]) || ! isset($baseRates[$to])) {
            return response()->json([
                'message' => 'Devise non supportée. Utiliser XOF, EUR ou USD.',
            ], 422);
        }

        // Conversion via base XOF.
        $amountInXof = $from === 'XOF' ? $amount : $amount * $baseRates[$from];
        $converted = $to === 'XOF' ? $amountInXof : $amountInXof / $baseRates[$to];

        return response()->json([
            'data' => [
                'from' => $from,
                'to' => $to,
                'amount' => $amount,
                'converted_amount' => round($converted, 2),
                'rate' => $from === $to
                    ? 1.0
                    : round(
                        ($to === 'XOF' ? 1.0 : 1.0 / $baseRates[$to]) /
                        ($from === 'XOF' ? 1.0 : 1.0 / $baseRates[$from]),
                        6
                    ),
                'source' => 'internal_fallback_rates',
            ],
        ]);
    }
}
