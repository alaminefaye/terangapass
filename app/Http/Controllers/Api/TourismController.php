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

            return [
                'id' => $partner->id,
                'name' => $partner->name,
                'category' => $this->getCategoryName($partner->category),
                'distance' => $distance,
                'address' => $partner->address,
                'phone' => $partner->phone,
                'rating' => null, // À ajouter si nécessaire
            ];
        });

        return response()->json(['data' => $points]);
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
}
