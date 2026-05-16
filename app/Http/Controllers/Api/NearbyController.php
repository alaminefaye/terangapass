<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\FormatsPartnerForApi;
use App\Http\Controllers\Controller;
use App\Models\Partner;
use App\Support\GeoQuery;
use Illuminate\Http\Request;

class NearbyController extends Controller
{
    use FormatsPartnerForApi;

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
            'limit' => 'sometimes|integer|min:1|max:100',
            'category' => 'sometimes|nullable|string|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
        ]);

        $lat = (float) $validated['latitude'];
        $lng = (float) $validated['longitude'];
        $radius = (int) ($validated['radius'] ?? 2000);
        $limit = min((int) ($validated['limit'] ?? 60), 100);

        $baseQuery = Partner::query()
            ->where('is_active', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        $inRadiusQuery = GeoQuery::orderByDistance(clone $baseQuery, $lat, $lng)
            ->havingRaw('distance_m <= ?', [$radius]);

        $inRadiusPartners = $inRadiusQuery->get();
        $fallbackUsed = false;
        $partners = $inRadiusPartners;

        if ($partners->isEmpty()) {
            $fallbackUsed = true;
            $partners = GeoQuery::orderByDistance(clone $baseQuery, $lat, $lng)
                ->limit($limit)
                ->get();
        } else {
            $partners = $inRadiusPartners->take($limit);
        }

        $categoryCounts = $this->categoryCountsForPartners($inRadiusPartners->isNotEmpty() ? $inRadiusPartners : $partners);

        $points = $partners->map(function (Partner $partner) use ($lat, $lng) {
            $distanceMeters = $this->partnerDistanceMeters($partner, $lat, $lng);

            return $this->formatPartnerPoint($partner, $distanceMeters);
        });

        $categoryFilter = $validated['category'] ?? null;
        if ($categoryFilter !== null && $categoryFilter !== '') {
            $points = $points->filter(
                fn ($p) => ($p['category_key'] ?? '') === $categoryFilter
            );
        }

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
                'limit' => $limit,
                'latitude' => $lat,
                'longitude' => $lng,
                'category' => $categoryFilter,
                'fallback_out_of_radius' => $fallbackUsed,
                'returned' => $sorted->count(),
                'in_radius_total' => $inRadiusPartners->count(),
                'category_counts' => $categoryCounts,
            ],
        ]);
    }
}
