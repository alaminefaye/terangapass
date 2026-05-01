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

        if ($request->has('latitude') && $request->has('longitude')) {
            // Calculer la distance et trier par proximité
            // Pour l'instant, on retourne juste les résultats
        }

        $partners = $query->get();

        // Formater les données
        $points = $partners->map(function ($partner) use ($request) {
            $distance = 'N/A';
            if ($request->has('latitude') && $request->has('longitude') && $partner->latitude && $partner->longitude) {
                $distance = $this->calculateDistance(
                    $request->latitude,
                    $request->longitude,
                    $partner->latitude,
                    $partner->longitude
                );
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
                'icon_url' => $iconUrl,
                'photos' => $photos,
            ];
        });

        return response()->json(['data' => $points]);
    }

    public function embassies(Request $request)
    {
        $query = Partner::where('is_active', true)
            ->where('category', 'embassy')
            ->orderBy('name');

        $embassies = $query->get()->map(function ($partner) {
            return [
                'id' => $partner->id,
                'name' => $partner->name,
                'address' => $partner->address,
                'phone' => $partner->phone,
                'email' => $partner->email,
                'website' => $partner->website,
                'latitude' => $partner->latitude,
                'longitude' => $partner->longitude,
                'icon_url' => $this->normalizeUrl($partner->icon_path ?: $partner->logo_url),
            ];
        });

        return response()->json(['data' => $embassies]);
    }

    private function calculateDistance($lat1, $lon1, $lat2, $lon2)
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);

        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLon/2) * sin($dLon/2);

        $c = 2 * atan2(sqrt($a), sqrt(1-$a));
        $distance = $earthRadius * $c;

        if ($distance < 1) {
            return round($distance * 1000) . ' m';
        }
        return round($distance, 1) . ' km';
    }

    private function getCategoryName($category)
    {
        $categories = [
            'hotel' => 'Hôtels',
            'restaurant' => 'Restaurants',
            'pharmacy' => 'Pharmacies',
            'hospital' => 'Hôpitaux',
            'embassy' => 'Ambassades',
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
