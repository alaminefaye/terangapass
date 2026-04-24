<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TransportController extends Controller
{
    public function shuttles()
    {
        try {
            // Essayer d'utiliser les données de la base de données
            $shuttlesFromDb = \App\Models\Shuttle::where('is_active', true)
                ->with(['stops', 'schedules'])
                ->get()
                ->map(function ($shuttle) {
                    return [
                        'id' => $shuttle->id,
                        'name' => $shuttle->name,
                        'description' => $shuttle->description,
                        'type' => $shuttle->type,
                        'start_location' => $shuttle->start_location,
                        'end_location' => $shuttle->end_location,
                        'start_date' => $shuttle->start_date?->format('Y-m-d'),
                        'end_date' => $shuttle->end_date?->format('Y-m-d'),
                        'first_departure' => $shuttle->first_departure?->format('H:i'),
                        'last_departure' => $shuttle->last_departure?->format('H:i'),
                        'frequency_minutes' => $shuttle->frequency_minutes,
                        'operating_days' => $shuttle->operating_days,
                        'is_secure' => $shuttle->is_secure_route,
                        'stops' => $shuttle->stops->map(function ($stop) {
                            return [
                                'id' => $stop->id,
                                'name' => $stop->name,
                                'order' => $stop->order,
                                'latitude' => $stop->latitude,
                                'longitude' => $stop->longitude,
                            ];
                        }),
                    ];
                })
                ->toArray();

            // Si on a des données en base, les utiliser
            if (!empty($shuttlesFromDb)) {
                return response()->json([
                    'success' => true,
                    'data' => $shuttlesFromDb,
                ]);
            }

            // Sinon, utiliser les données de démonstration
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

            return response()->json([
                'success' => true,
                'data' => $shuttles,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la récupération des navettes',
                'data' => [],
            ], 500);
        }
    }
}
