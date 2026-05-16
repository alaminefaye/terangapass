<?php

namespace App\Support;

use Illuminate\Database\Eloquent\Builder;

class GeoQuery
{
    /**
     * Expression SQL Haversine (mètres) — alias distance_m.
     */
    public static function distanceMetersSelect(float $latitude, float $longitude): string
    {
        return '(6371000 * acos(LEAST(1.0, GREATEST(-1.0,
            cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?))
            + sin(radians(?)) * sin(radians(latitude))
        )))) as distance_m';
    }

    /**
     * @param  array<int, float>  $bindings  [$lat, $lng, $lat]
     */
    public static function orderByDistance(Builder $query, float $latitude, float $longitude): Builder
    {
        return $query
            ->selectRaw('*, '.self::distanceMetersSelect($latitude, $longitude), [
                $latitude,
                $longitude,
                $latitude,
            ])
            ->orderBy('distance_m');
    }
}
