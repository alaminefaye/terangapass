<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CompetitionSite;
use Carbon\Carbon;
use Illuminate\Http\Request;

class CompetitionSiteController extends Controller
{
    public function index()
    {
        $sites = CompetitionSite::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get()
            ->map(function (CompetitionSite $site) {
                $start = $site->start_date ? Carbon::parse($site->start_date) : null;
                $end = $site->end_date ? Carbon::parse($site->end_date) : null;

                $dates = null;
                if ($start && $end) {
                    if ($start->isSameDay($end)) {
                        $dates = $start->format('Y-m-d');
                    } else {
                        $dates = $start->format('Y-m-d') . ' → ' . $end->format('Y-m-d');
                    }
                } elseif ($start) {
                    $dates = $start->format('Y-m-d');
                } elseif ($end) {
                    $dates = $end->format('Y-m-d');
                }

                return [
                    'id' => $site->id,
                    'name' => $site->name,
                    'location' => $site->location,
                    'dates' => $dates,
                    'description' => $site->description,
                    'address' => $site->address,
                    'latitude' => $site->latitude !== null ? (float) $site->latitude : null,
                    'longitude' => $site->longitude !== null ? (float) $site->longitude : null,
                    'sports' => $site->sports,
                    'access_info' => $site->access_info,
                    'facilities' => $site->facilities,
                    'capacity' => $site->capacity,
                ];
            });

        return response()->json(['data' => $sites]);
    }

    public function calendar()
    {
        // Données de démonstration
        $calendar = [];

        return response()->json(['data' => $calendar]);
    }
}
