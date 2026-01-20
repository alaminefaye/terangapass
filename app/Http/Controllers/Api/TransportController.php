<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TransportController extends Controller
{
    public function shuttles()
    {
        // Données de démonstration - à remplacer par une vraie table
        $shuttles = [
            [
                'id' => 1,
                'name' => 'Navettes Gratuites JOJ 2026',
                'period' => '16-23 AOÛT',
                'schedule' => 'Aujourd\'hui (tous les 20min): 08:30 à 19:30',
                'days' => 'Navettes gratuites lundi au dimanche',
                'location' => 'Dakar Centre',
                'next_departure' => '08:30',
                'is_secure' => true,
                'type' => 'bus',
            ],
            [
                'id' => 2,
                'name' => 'Ligne Express-JOJ',
                'period' => '16-18 AOÛT',
                'route' => 'Gare des Baux Maraîchers - Blaise Diagne',
                'terminus' => 'Acapes DK-13',
                'schedule' => 'Aujourd\'hui: 07:00 - 20:00',
                'is_secure' => true,
                'type' => 'train',
            ],
        ];

        return response()->json(['data' => $shuttles]);
    }
}
