<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;

class NearbyController extends Controller
{
    /**
     * Lieux actifs dans un rayon (mètres) autour d'un point WGS84.
     * Les partenaires sponsorisés sont listés en premier, puis par distance croissante.
     */
    public function index(Request $request)
    {
        $validated = $request->validate([
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'radius' => 'sometimes|integer|min:100|max:50000',
            'category' => 'sometimes|nullable|string|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,other',
        ]);

        $lat = (float) $validated['latitude'];
        $lng = (float) $validated['longitude'];
        $radius = (int) ($validated['radius'] ?? 2000);

        $query = Partner::query()
            ->where('is_active', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->when(
                ! empty($validated['category'] ?? null),
                fn ($q) => $q->where('category', $validated['category'])
            )
            ->whereRaw(
                '(6371000 * acos(least(1, greatest(-1, '
                . 'cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) '
                . '+ sin(radians(?)) * sin(radians(latitude))'
                . ')))) <= ?',
                [$lat, $lng, $lat, $radius]
            );

        $partners = $query->get();

        $points = $partners->map(function (Partner $partner) use ($lat, $lng) {
            $distanceMeters = $this->calculateDistanceMeters(
                $lat,
                $lng,
                (float) $partner->latitude,
                (float) $partner->longitude
            );

            $iconUrl = $partner->icon_path ?: $partner->logo_url;
            $iconUrl = $this->normalizeUrl($iconUrl);

            $photos = is_array($partner->photos) ? $partner->photos : [];
            $photos = array_values(array_filter(array_map(function ($u) {
                return $this->normalizeUrl($u);
            }, $photos)));

            return [
                'id' => $partner->id,
                'name' => $partner->name,
                'category' => $this->getCategoryLabel($partner->category),
                'category_key' => $partner->category,
                'distance' => $this->formatDistance($distanceMeters),
                'distance_meters' => $distanceMeters,
                'address' => $partner->address,
                'phone' => $partner->phone,
                'description' => $partner->description,
                'email' => $partner->email,
                'website' => $partner->website,
                'latitude' => $partner->latitude,
                'longitude' => $partner->longitude,
                'icon_url' => $iconUrl,
                'photos' => $photos,
                'is_sponsor' => (bool) $partner->is_sponsor,
            ];
        });

        $sorted = $points->sort(function ($a, $b) {
            $sa = ! empty($a['is_sponsor']);
            $sb = ! empty($b['is_sponsor']);
            if ($sa !== $sb) {
                return $sb <=> $sa;
            }

            return ($a['distance_meters'] ?? 0) <=> ($b['distance_meters'] ?? 0);
        })->values();

        return response()->json([
            'data' => $sorted,
            'meta' => [
                'radius_m' => $radius,
                'latitude' => $lat,
                'longitude' => $lng,
                'category' => $validated['category'] ?? null,
            ],
        ]);
    }

    private function calculateDistanceMeters(float $lat1, float $lon1, float $lat2, float $lon2): float
    {
        $earthRadiusKm = 6371.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2)
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2))
            * sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusKm * $c * 1000;
    }

    private function formatDistance(float $distanceMeters): string
    {
        if ($distanceMeters < 1000) {
            return round($distanceMeters) . ' m';
        }

        return round($distanceMeters / 1000, 1) . ' km';
    }

    private function getCategoryLabel(string $category): string
    {
        return match ($category) {
            'hotel' => 'Hôtels',
            'restaurant' => 'Restaurants',
            'pharmacy' => 'Pharmacies',
            'hospital' => 'Hôpitaux',
            'embassy' => 'Ambassades',
            'consulate' => 'Consulats',
            'bank' => 'Banques & DAB',
            'gas_station' => 'Stations-service',
            'shop' => 'Boutiques',
            default => 'Autres',
        };
    }

    private function normalizeUrl($value): ?string
    {
        if (! $value) {
            return null;
        }

        $value = (string) $value;
        if ($value === '') {
            return null;
        }

        $appUrl = config('app.url');
        $useHttps = is_string($appUrl) && str_starts_with($appUrl, 'https://');

        if (str_starts_with($value, 'http://')) {
            return ($useHttps || request()->isSecure()) ? preg_replace('/^http:\\/\\//', 'https://', $value) : $value;
        }

        if (str_starts_with($value, 'https://')) {
            return $value;
        }

        if (str_starts_with($value, '/')) {
            return ($useHttps || request()->isSecure()) ? secure_url($value) : url($value);
        }

        $value = '/' . ltrim($value, '/');

        return ($useHttps || request()->isSecure()) ? secure_url($value) : url($value);
    }
}
