<?php

namespace Database\Seeders;

use App\Models\Zone;
use Illuminate\Database\Seeder;

class ZoneSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $zones = [
            [
                'name' => 'Dakar Centre',
                'description' => 'Zone centrale de Dakar incluant le Plateau et les environs',
                'polygon_coordinates' => json_encode([
                    ['lat' => 14.7167, 'lng' => -17.4677],
                    ['lat' => 14.7267, 'lng' => -17.4577],
                    ['lat' => 14.7067, 'lng' => -17.4777],
                ]),
                'center_latitude' => 14.7167,
                'center_longitude' => -17.4677,
                'is_active' => true,
                'population_estimate' => 150000,
            ],
            [
                'name' => 'M\'Bour 4 Stadium',
                'description' => 'Zone autour du stade M\'Bour 4',
                'polygon_coordinates' => json_encode([
                    ['lat' => 14.4167, 'lng' => -16.9677],
                    ['lat' => 14.4267, 'lng' => -16.9577],
                    ['lat' => 14.4067, 'lng' => -16.9777],
                ]),
                'center_latitude' => 14.4167,
                'center_longitude' => -16.9677,
                'is_active' => true,
                'population_estimate' => 50000,
            ],
            [
                'name' => 'Plateau',
                'description' => 'Quartier administratif et commercial du Plateau',
                'polygon_coordinates' => json_encode([
                    ['lat' => 14.6914, 'lng' => -17.4467],
                    ['lat' => 14.7014, 'lng' => -17.4367],
                    ['lat' => 14.6814, 'lng' => -17.4567],
                ]),
                'center_latitude' => 14.6914,
                'center_longitude' => -17.4467,
                'is_active' => true,
                'population_estimate' => 80000,
            ],
            [
                'name' => 'Ouakam',
                'description' => 'Quartier Ouakam près du Monument de la Renaissance',
                'polygon_coordinates' => json_encode([
                    ['lat' => 14.7167, 'lng' => -17.4977],
                    ['lat' => 14.7267, 'lng' => -17.4877],
                    ['lat' => 14.7067, 'lng' => -17.5077],
                ]),
                'center_latitude' => 14.7167,
                'center_longitude' => -17.4977,
                'is_active' => true,
                'population_estimate' => 60000,
            ],
            [
                'name' => 'Almadies',
                'description' => 'Zone Almadies - Corniche Ouest',
                'polygon_coordinates' => json_encode([
                    ['lat' => 14.7367, 'lng' => -17.5077],
                    ['lat' => 14.7467, 'lng' => -17.4977],
                    ['lat' => 14.7267, 'lng' => -17.5177],
                ]),
                'center_latitude' => 14.7367,
                'center_longitude' => -17.5077,
                'is_active' => true,
                'population_estimate' => 40000,
            ],
        ];

        foreach ($zones as $zone) {
            Zone::create($zone);
        }
    }
}
