<?php

namespace Database\Seeders;

use App\Models\Shuttle;
use App\Models\ShuttleStop;
use App\Models\ShuttleSchedule;
use Illuminate\Database\Seeder;

class ShuttleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Navette principale gratuite JOJ
        $shuttle1 = Shuttle::create([
            'name' => 'Navettes Gratuites JOJ 2026',
            'description' => 'Navettes gratuites entre les sites de compétition et le centre-ville. Fréquence toutes les 20 minutes.',
            'type' => 'regular',
            'start_date' => '2026-08-16',
            'end_date' => '2026-08-23',
            'start_location' => 'Place de l\'Indépendance',
            'end_location' => 'Stade Olympique',
            'start_latitude' => 14.6914,
            'start_longitude' => -17.4467,
            'end_latitude' => 14.7167,
            'end_longitude' => -17.4677,
            'frequency_minutes' => 20,
            'first_departure' => '08:30',
            'last_departure' => '19:30',
            'operating_days' => json_encode(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
            'is_secure_route' => true,
            'is_active' => true,
        ]);

        // Arrêts pour la navette 1
        $stops1 = [
            ['name' => 'Place de l\'Indépendance', 'latitude' => 14.6914, 'longitude' => -17.4467, 'order' => 1],
            ['name' => 'Hôpital Principal', 'latitude' => 14.7024, 'longitude' => -17.4527, 'order' => 2],
            ['name' => 'Dakar Arena', 'latitude' => 14.7014, 'longitude' => -17.4517, 'order' => 3],
            ['name' => 'Stade Olympique', 'latitude' => 14.7167, 'longitude' => -17.4677, 'order' => 4],
        ];

        foreach ($stops1 as $stop) {
            ShuttleStop::create([
                'shuttle_id' => $shuttle1->id,
                'name' => $stop['name'],
                'latitude' => $stop['latitude'],
                'longitude' => $stop['longitude'],
                'address' => null,
                'order' => $stop['order'],
            ]);
        }

        // Horaires pour la navette 1 (exemple pour lundi)
        for ($hour = 8; $hour <= 19; $hour++) {
            for ($minute = 0; $minute < 60; $minute += 20) {
                if ($hour == 8 && $minute < 30) continue;
                if ($hour == 19 && $minute > 30) break;
                
                ShuttleSchedule::create([
                    'shuttle_id' => $shuttle1->id,
                    'departure_time' => sprintf('%02d:%02d:00', $hour, $minute),
                    'day_of_week' => 1, // Lundi
                    'is_active' => true,
                ]);
            }
        }

        // Navette Express vers M'Bour
        $shuttle2 = Shuttle::create([
            'name' => 'Ligne Express-JOJ',
            'description' => 'Navette express entre Dakar et le Complexe Sportif de M\'Bour.',
            'type' => 'express',
            'start_date' => '2026-08-16',
            'end_date' => '2026-08-23',
            'start_location' => 'Gare Routière de Dakar',
            'end_location' => 'Complexe Sportif de M\'Bour',
            'start_latitude' => 14.6944,
            'start_longitude' => -17.4477,
            'end_latitude' => 14.4167,
            'end_longitude' => -16.9677,
            'frequency_minutes' => 60,
            'first_departure' => '07:00',
            'last_departure' => '20:00',
            'operating_days' => json_encode(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
            'is_secure_route' => true,
            'is_active' => true,
        ]);

        // Arrêts pour la navette 2
        $stops2 = [
            ['name' => 'Gare Routière de Dakar', 'latitude' => 14.6944, 'longitude' => -17.4477, 'order' => 1],
            ['name' => 'Complexe Sportif de M\'Bour', 'latitude' => 14.4167, 'longitude' => -16.9677, 'order' => 2],
        ];

        foreach ($stops2 as $stop) {
            ShuttleStop::create([
                'shuttle_id' => $shuttle2->id,
                'name' => $stop['name'],
                'latitude' => $stop['latitude'],
                'longitude' => $stop['longitude'],
                'address' => null,
                'order' => $stop['order'],
            ]);
        }

        // Horaires pour la navette 2
        for ($hour = 7; $hour <= 20; $hour++) {
            ShuttleSchedule::create([
                'shuttle_id' => $shuttle2->id,
                'departure_time' => sprintf('%02d:00:00', $hour),
                'day_of_week' => 1, // Lundi
                'is_active' => true,
            ]);
        }

        // Navette Almadies - Centre-ville
        $shuttle3 = Shuttle::create([
            'name' => 'Navette Almadies - Centre',
            'description' => 'Navette entre les hôtels d\'Almadies et le centre-ville de Dakar.',
            'type' => 'regular',
            'start_date' => '2026-08-16',
            'end_date' => '2026-08-23',
            'start_location' => 'Almadies',
            'end_location' => 'Plateau',
            'start_latitude' => 14.7367,
            'start_longitude' => -17.5077,
            'end_latitude' => 14.6914,
            'end_longitude' => -17.4467,
            'frequency_minutes' => 30,
            'first_departure' => '08:00',
            'last_departure' => '22:00',
            'operating_days' => json_encode(['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']),
            'is_secure_route' => true,
            'is_active' => true,
        ]);

        // Arrêts pour la navette 3
        $stops3 = [
            ['name' => 'Hôtel Radisson', 'latitude' => 14.7367, 'longitude' => -17.5077, 'order' => 1],
            ['name' => 'Plage de Ngor', 'latitude' => 14.7517, 'longitude' => -17.5177, 'order' => 2],
            ['name' => 'Ouakam', 'latitude' => 14.7217, 'longitude' => -17.4927, 'order' => 3],
            ['name' => 'Plateau', 'latitude' => 14.6914, 'longitude' => -17.4467, 'order' => 4],
        ];

        foreach ($stops3 as $stop) {
            ShuttleStop::create([
                'shuttle_id' => $shuttle3->id,
                'name' => $stop['name'],
                'latitude' => $stop['latitude'],
                'longitude' => $stop['longitude'],
                'address' => null,
                'order' => $stop['order'],
            ]);
        }
    }
}
