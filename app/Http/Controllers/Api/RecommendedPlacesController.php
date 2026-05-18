<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\FormatsPartnerForApi;
use App\Http\Controllers\Controller;
use App\Models\Partner;
use App\Support\GeoQuery;
use Illuminate\Http\Request;

class RecommendedPlacesController extends Controller
{
    use FormatsPartnerForApi;

    public function index(Request $request)
    {
        $request->validate([
            'category' => 'sometimes|nullable|string|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
            'latitude' => 'sometimes|nullable|numeric|between:-90,90',
            'longitude' => 'sometimes|nullable|numeric|between:-180,180',
            'limit' => 'sometimes|integer|min:1|max:40',
        ]);

        $limit = min((int) $request->input('limit', 20), 40);
        $hasCoordinates = $request->filled('latitude') && $request->filled('longitude');
        $lat = $hasCoordinates ? (float) $request->latitude : null;
        $lng = $hasCoordinates ? (float) $request->longitude : null;

        $query = Partner::query()
            ->where('is_active', true)
            ->where('is_recommended', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($hasCoordinates) {
            $query = GeoQuery::orderByDistance($query, $lat, $lng);
        }

        $partners = $query->limit(120)->get();

        $partners = $partners->sort(function (Partner $a, Partner $b) {
            $prio = $b->recommendation_priority <=> $a->recommendation_priority;
            if ($prio !== 0) {
                return $prio;
            }
            if (isset($a->distance_m, $b->distance_m)) {
                return ($a->distance_m <=> $b->distance_m);
            }

            return strcmp($a->name, $b->name);
        })->values()->take($limit);

        $places = $partners->map(function (Partner $partner) use ($lat, $lng) {
            $distanceMeters = $this->partnerDistanceMeters($partner, $lat, $lng);
            $point = $this->formatPartnerPoint($partner, $distanceMeters, includeExtendedFields: true);
            $point['is_recommended'] = true;
            $point['recommendation_pitch'] = $partner->recommendation_pitch;

            return $point;
        })->values();

        return response()->json([
            'success' => true,
            'data' => $places,
            'meta' => [
                'returned' => $places->count(),
                'limit' => $limit,
            ],
        ]);
    }
}
