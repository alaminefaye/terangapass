<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;

class TourismController extends Controller
{
    public function pointsOfInterest(Request $request)
    {
        $query = Partner::where('is_active', true);

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        $hasCoordinates = $request->filled('latitude') && $request->filled('longitude');

        $partners = $query->get();

        // Formater les données
        $points = $partners->map(function ($partner) use ($request, $hasCoordinates) {
            $distance = 'N/A';
            $distanceMeters = null;
            if ($hasCoordinates && $partner->latitude && $partner->longitude) {
                $distanceMeters = $this->calculateDistanceMeters(
                    $request->latitude,
                    $request->longitude,
                    $partner->latitude,
                    $partner->longitude
                );
                $distance = $this->formatDistance($distanceMeters);
            }

            $iconUrl = $partner->icon_path ?: $partner->logo_url;
            $iconUrl = $this->normalizeUrl($iconUrl);

            $photos = is_array($partner->photos) ? $partner->photos : [];
            $photos = array_values(array_filter(array_map(function ($u) {
                return $this->normalizeUrl($u);
            }, $photos)));

            return [
                'id' => $partner->id,
                'name' => $partner->name,
                'category' => $this->getCategoryName($partner->category),
                'distance' => $distance,
                'address' => $partner->address,
                'phone' => $partner->phone,
                'rating' => null, // À ajouter si nécessaire
                'description' => $partner->description,
                'email' => $partner->email,
                'website' => $partner->website,
                'latitude' => $partner->latitude,
                'longitude' => $partner->longitude,
                'distance_meters' => $distanceMeters,
                'icon_url' => $iconUrl,
                'photos' => $photos,
            ];
        });

        if ($hasCoordinates) {
            $points = $points
                ->sortBy(fn ($point) => $point['distance_meters'] ?? INF)
                ->values();
        }

        return response()->json(['data' => $points]);
    }

    public function embassies(Request $request)
    {
        $query = Partner::where('is_active', true)
            ->whereIn('category', ['embassy', 'consulate'])
            ->orderBy('name');

        $embassies = $query->get()->map(function ($partner) {
            return [
                'id' => $partner->id,
                'name' => $partner->name,
                'address' => $partner->address,
                'phone' => $partner->phone,
                'email' => $partner->email,
                'website' => $partner->website,
                'rating' => $partner->rating,
                'opening_hours' => $partner->opening_hours,
                'latitude' => $partner->latitude,
                'longitude' => $partner->longitude,
                'mission_type' => $partner->category,
                'icon_url' => $this->normalizeUrl($partner->icon_path ?: $partner->logo_url),
            ];
        });

        return response()->json(['data' => $embassies]);
    }

    private function calculateDistanceMeters($lat1, $lon1, $lat2, $lon2): float
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon/2) * sin($dLon/2);

        $c = 2 * atan2(sqrt($a), sqrt(1-$a));
        $distanceKm = $earthRadius * $c;

        return $distanceKm * 1000;
    }

    private function formatDistance(float $distanceMeters): string
    {
        if ($distanceMeters < 1000) {
            return round($distanceMeters) . ' m';
        }
        return round($distanceMeters / 1000, 1) . ' km';
    }

    private function getCategoryName($category)
    {
        $categories = [
            'hotel' => 'Hôtels',
            'restaurant' => 'Restaurants',
            'pharmacy' => 'Pharmacies',
            'hospital' => 'Hôpitaux',
            'embassy' => 'Ambassades',
            'consulate' => 'Consulats',
            'bank' => 'Banques & DAB',
            'gas_station' => 'Stations-service',
            'shop' => 'Boutiques',
            'notary' => 'Notaires',
            'lawyer' => 'Avocats',
            'doctor' => 'Médecins',
            'clinic' => 'Cliniques',
            'government' => 'Services publics',
            'school' => 'Écoles',
            'university' => 'Universités',
            'media' => 'Médias & culture',
            'other' => 'Autres',
        ];

        return $categories[$category] ?? 'Autres';
    }

    private function normalizeUrl($value): ?string
    {
        if (!$value) {
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
