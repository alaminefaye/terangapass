<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Api\Concerns\FormatsPartnerForApi;
use App\Http\Controllers\Controller;
use App\Models\Partner;
use App\Models\PoiReview;
use App\Models\User;
use App\Support\GeoQuery;
use Illuminate\Http\Request;

class TourismController extends Controller
{
    use FormatsPartnerForApi;

    /**
     * Même convention que AuthController (/auth/login) : Bearer base64(userId|timestamp|email).
     */
    private function userFromBearer(Request $request): ?User
    {
        $token = $request->bearerToken();
        if ($token === null || $token === '') {
            return null;
        }

        $decoded = base64_decode($token, true);
        if ($decoded === false || $decoded === '') {
            return null;
        }

        $parts = explode('|', $decoded);
        if (count($parts) < 3) {
            return null;
        }

        return User::query()->find((int) $parts[0]);
    }

    public function pointsOfInterest(Request $request)
    {
        $request->validate([
            'category' => 'sometimes|nullable|string|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
            'latitude' => 'sometimes|nullable|numeric|between:-90,90',
            'longitude' => 'sometimes|nullable|numeric|between:-180,180',
            'limit' => 'sometimes|integer|min:1|max:200',
            'radius' => 'sometimes|integer|min:100|max:500000',
        ]);

        $limit = min((int) $request->input('limit', 80), 200);
        $hasCoordinates = $request->filled('latitude') && $request->filled('longitude');
        $lat = $hasCoordinates ? (float) $request->latitude : null;
        $lng = $hasCoordinates ? (float) $request->longitude : null;
        $radius = (int) $request->input('radius', 100_000);

        $baseQuery = Partner::query()
            ->where('is_active', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude');

        if ($request->filled('category')) {
            $baseQuery->where('category', $request->category);
        }

        $totalActive = (clone $baseQuery)->count();

        $categoryCountsRaw = Partner::query()
            ->where('is_active', true)
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->selectRaw('category, COUNT(*) as aggregate')
            ->groupBy('category')
            ->pluck('aggregate', 'category');

        $categoryCounts = [];
        foreach ($categoryCountsRaw as $key => $count) {
            $label = $this->getCategoryLabel((string) $key);
            $categoryCounts[$label] = ($categoryCounts[$label] ?? 0) + (int) $count;
        }

        if ($hasCoordinates) {
            $query = GeoQuery::orderByDistance(clone $baseQuery, $lat, $lng);
            if ($request->has('radius')) {
                $query->havingRaw('distance_m <= ?', [$radius]);
            }
            $partners = $query->limit($limit)->get();
        } else {
            $partners = (clone $baseQuery)->orderBy('name')->limit($limit)->get();
        }

        $points = $partners->map(function (Partner $partner) use ($lat, $lng) {
            $distanceMeters = $this->partnerDistanceMeters($partner, $lat, $lng);

            return $this->formatPartnerPoint($partner, $distanceMeters, includeExtendedFields: true);
        })->values();

        return response()->json([
            'data' => $points,
            'meta' => [
                'total' => $totalActive,
                'returned' => $points->count(),
                'limit' => $limit,
                'sorted_by_distance' => $hasCoordinates,
                'category_counts' => $categoryCounts,
            ],
        ]);
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
                'icon_url' => $this->normalizeUrl($partner->resolvedLogoUrl()),
            ];
        });

        return response()->json(['data' => $embassies]);
    }

    /** GET /tourism/points-of-interest/{id}/reviews */
    public function getReviews(int $id)
    {
        $partner = Partner::findOrFail($id);

        $reviews = $partner->reviews()
            ->with('user:id,name')
            ->latest()
            ->get()
            ->map(fn ($r) => [
                'id'         => $r->id,
                'rating'     => $r->rating,
                'comment'    => $r->comment,
                'author'     => $r->user->name ?? 'Anonyme',
                'created_at' => $r->created_at->toISOString(),
            ]);

        $average = $reviews->isNotEmpty()
            ? round($reviews->avg('rating'), 1)
            : null;

        return response()->json([
            'data'    => $reviews,
            'average' => $average,
            'count'   => $reviews->count(),
        ]);
    }

    /** POST /tourism/points-of-interest/{id}/reviews */
    public function addReview(int $id, Request $request)
    {
        $request->validate([
            'rating'  => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $partner = Partner::findOrFail($id);
        $user    = $this->userFromBearer($request);

        if ($user === null) {
            return response()->json([
                'success' => false,
                'message' => 'Connectez-vous pour laisser un avis.',
            ], 401);
        }

        if ($user->isBlockedAccount()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte est suspendu.',
            ], 403);
        }

        // Upsert : remplace l'avis existant si l'utilisateur en a déjà un
        $review = PoiReview::updateOrCreate(
            ['partner_id' => $partner->id, 'user_id' => $user->id],
            ['rating' => $request->rating, 'comment' => $request->comment]
        );

        // Recalcule la note moyenne du partenaire
        $partner->refreshRating();

        return response()->json([
            'data' => [
                'id'         => $review->id,
                'rating'     => $review->rating,
                'comment'    => $review->comment,
                'author'     => $user->name,
                'created_at' => $review->created_at->toISOString(),
            ],
            'average' => $partner->rating,
            'count'   => $partner->reviews()->count(),
        ], 201);
    }

}
