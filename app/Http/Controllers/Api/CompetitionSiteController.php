<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class CompetitionSiteController extends Controller
{
    public function index()
    {
        // Données de démonstration - à remplacer par une vraie table
        $sites = [
            [
                'id' => 1,
                'name' => 'Stade Olympique',
                'location' => 'Dakar Centre',
                'dates' => '16-23 AOÛT',
                'description' => 'Stade principal des compétitions',
            ],
            [
                'id' => 2,
                'name' => 'Dakar Arena',
                'location' => 'Dakar Centre',
                'dates' => '16-18 AOÛT',
                'description' => 'Arène pour les compétitions intérieures',
            ],
        ];

        return response()->json(['data' => $sites]);
    }

    public function calendar()
    {
        // Données de démonstration
        $calendar = [];

        return response()->json(['data' => $calendar]);
    }
}
