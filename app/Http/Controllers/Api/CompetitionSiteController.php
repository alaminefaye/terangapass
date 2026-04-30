<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CompetitionSite;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

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
        $calendar = [
            [
                'id' => 1,
                'sport' => 'Judo',
                'title' => 'Judo',
                'date' => '2026-11-01 → 2026-11-03',
                'start_date' => '2026-11-01',
                'end_date' => '2026-11-03',
                'location' => 'Dakar Expo Center',
            ],
            [
                'id' => 2,
                'sport' => 'Futsal',
                'title' => 'Futsal',
                'date' => '2026-11-01 → 2026-11-12',
                'start_date' => '2026-11-01',
                'end_date' => '2026-11-12',
                'location' => 'Iba Mar Diop / Dakar Arena',
            ],
            [
                'id' => 3,
                'sport' => 'Natation',
                'title' => 'Natation',
                'date' => '2026-11-01 → 2026-11-06',
                'start_date' => '2026-11-01',
                'end_date' => '2026-11-06',
                'location' => 'Tour de l\'Oeuf / Dakar Arena',
            ],
            [
                'id' => 4,
                'sport' => 'Rugby à 7',
                'title' => 'Rugby à 7',
                'date' => '2026-11-01 → 2026-11-03',
                'start_date' => '2026-11-01',
                'end_date' => '2026-11-03',
                'location' => 'Complexe Iba Mar Diop',
            ],
            [
                'id' => 5,
                'sport' => 'Équitation',
                'title' => 'Équitation',
                'date' => '2026-11-03 → 2026-11-06',
                'start_date' => '2026-11-03',
                'end_date' => '2026-11-06',
                'location' => 'Complexe équestre Diamniadio',
            ],
            [
                'id' => 6,
                'sport' => 'Skateboard',
                'title' => 'Skateboard',
                'date' => '2026-11-04 → 2026-11-05',
                'start_date' => '2026-11-04',
                'end_date' => '2026-11-05',
                'location' => 'Tour de l\'Oeuf',
            ],
            [
                'id' => 7,
                'sport' => 'Gymnastique',
                'title' => 'Gymnastique',
                'date' => '2026-11-05 → 2026-11-11',
                'start_date' => '2026-11-05',
                'end_date' => '2026-11-11',
                'location' => 'Dakar Expo Center',
            ],
            [
                'id' => 8,
                'sport' => 'Boxe',
                'title' => 'Boxe',
                'date' => '2026-11-07 → 2026-11-12',
                'start_date' => '2026-11-07',
                'end_date' => '2026-11-12',
                'location' => 'Dakar Expo Center',
            ],
            [
                'id' => 9,
                'sport' => 'Cyclisme',
                'title' => 'Cyclisme',
                'date' => '2026-11-08 et 2026-11-10',
                'start_date' => '2026-11-08',
                'end_date' => '2026-11-10',
                'location' => 'Corniche Ouest, Dakar',
            ],
            [
                'id' => 10,
                'sport' => 'Escrime',
                'title' => 'Escrime',
                'date' => '2026-11-08 → 2026-11-13',
                'start_date' => '2026-11-08',
                'end_date' => '2026-11-13',
                'location' => 'Dakar Expo Center',
            ],
            [
                'id' => 11,
                'sport' => 'Handball de plage',
                'title' => 'Handball de plage',
                'date' => '2026-11-09 → 2026-11-13',
                'start_date' => '2026-11-09',
                'end_date' => '2026-11-13',
                'location' => 'Saly plage ouest',
            ],
            [
                'id' => 12,
                'sport' => 'Lutte de plage',
                'title' => 'Lutte de plage',
                'date' => '2026-11-07 → 2026-11-08',
                'start_date' => '2026-11-07',
                'end_date' => '2026-11-08',
                'location' => 'Saly plage ouest',
            ],
        ];

        $allCompetitionSports = [
            'Athlétisme',
            'Natation',
            'Tir à l\'arc',
            'Badminton',
            'Baseball5',
            'Basketball 3x3',
            'Boxe',
            'Breaking (breakdance)',
            'Cyclisme sur route',
            'Équitation (saut d\'obstacles)',
            'Escrime',
            'Futsal',
            'Gymnastique artistique',
            'Handball de plage',
            'Judo',
            'Aviron côtier',
            'Rugby à 7',
            'Voile',
            'Skateboard street',
            'Tennis de table',
            'Taekwondo',
            'Triathlon',
            'Volleyball de plage',
            'Lutte de plage',
            'Wushu',
        ];

        $alreadyListed = collect($calendar)
            ->pluck('sport')
            ->map(fn ($sport) => Str::lower((string) $sport))
            ->all();

        $nextId = count($calendar) + 1;
        foreach ($allCompetitionSports as $sport) {
            if (in_array(Str::lower($sport), $alreadyListed, true)) {
                continue;
            }

            $calendar[] = [
                'id' => $nextId++,
                'sport' => $sport,
                'title' => $sport,
                'date' => '2026-10-31 → 2026-11-13',
                'start_date' => '2026-10-31',
                'end_date' => '2026-11-13',
                'location' => 'Site JOJ à confirmer',
            ];
        }

        return response()->json(['data' => $calendar]);
    }
}
