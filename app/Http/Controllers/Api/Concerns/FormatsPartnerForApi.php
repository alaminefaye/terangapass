<?php

namespace App\Http\Controllers\Api\Concerns;

use App\Models\Partner;

trait FormatsPartnerForApi
{
    protected function formatPartnerPoint(
        Partner $partner,
        ?float $distanceMeters = null,
        bool $includeExtendedFields = false
    ): array {
        $distance = $distanceMeters !== null ? $this->formatDistance($distanceMeters) : 'N/A';

        $iconUrl = $this->normalizeUrl($partner->resolvedLogoUrl());

        $photos = array_values(array_filter(array_map(
            fn ($u) => $this->normalizeUrl($u),
            $partner->resolvedPhotoUrls()
        )));

        $point = [
            'id' => $partner->id,
            'name' => $partner->name,
            'category' => $this->getCategoryLabel($partner->category),
            'category_key' => $partner->category,
            'is_sponsor' => (bool) $partner->is_sponsor,
            'is_recommended' => (bool) $partner->is_recommended,
            'recommendation_pitch' => $partner->recommendation_pitch,
            'distance' => $distance,
            'distance_meters' => $distanceMeters,
            'address' => $partner->address,
            'phone' => $partner->phone,
            'rating' => $partner->rating,
            'opening_hours' => $partner->opening_hours,
            'latitude' => $partner->latitude,
            'longitude' => $partner->longitude,
            'icon_url' => $iconUrl,
            'photos' => $photos,
        ];

        if ($includeExtendedFields) {
            $point['google_place_id'] = $partner->google_place_id;
            $point['description'] = $partner->description;
            $point['email'] = $partner->email;
            $point['website'] = $partner->website;
        } else {
            $point['description'] = $partner->description;
            $point['email'] = $partner->email;
            $point['website'] = $partner->website;
            $point['is_open_now'] = $partner->is_open_now;
            $point['opening_status'] = $partner->opening_status_label;
        }

        return $point;
    }

    protected function partnerDistanceMeters(Partner $partner, ?float $lat, ?float $lng): ?float
    {
        if (isset($partner->distance_m)) {
            return (float) $partner->distance_m;
        }

        if ($lat === null || $lng === null || ! $partner->latitude || ! $partner->longitude) {
            return null;
        }

        return $this->calculateDistanceMeters(
            $lat,
            $lng,
            (float) $partner->latitude,
            (float) $partner->longitude
        );
    }

    protected function calculateDistanceMeters(float $lat1, float $lon1, float $lat2, float $lon2): float
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

    protected function formatDistance(float $distanceMeters): string
    {
        if ($distanceMeters < 1000) {
            return round($distanceMeters).' m';
        }

        return round($distanceMeters / 1000, 1).' km';
    }

    protected function getCategoryLabel(string $category): string
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
            'notary' => 'Notaires',
            'lawyer' => 'Avocats',
            'doctor' => 'Médecins',
            'clinic' => 'Cliniques',
            'government' => 'Services publics',
            'school' => 'Écoles',
            'university' => 'Universités',
            'media' => 'Médias & culture',
            'professional_service' => 'Services professionnels',
            'religious_site' => 'Lieux de culte',
            default => 'Autres',
        };
    }

    protected function normalizeUrl($value): ?string
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

        $value = '/'.ltrim($value, '/');

        return ($useHttps || request()->isSecure()) ? secure_url($value) : url($value);
    }

    /**
     * @return array<string, int>
     */
    protected function categoryCountsForPartners(iterable $partners): array
    {
        $counts = [];
        foreach ($partners as $partner) {
            $key = $partner instanceof Partner ? $partner->category : (string) ($partner['category_key'] ?? '');
            if ($key === '') {
                continue;
            }
            $counts[$key] = ($counts[$key] ?? 0) + 1;
        }

        return $counts;
    }
}
