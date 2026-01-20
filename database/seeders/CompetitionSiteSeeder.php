<?php

namespace Database\Seeders;

use App\Models\CompetitionSite;
use Illuminate\Database\Seeder;

class CompetitionSiteSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $sites = [
            [
                'name' => 'Stade Olympique de Dakar',
                'description' => 'Stade principal des Jeux Olympiques de la Jeunesse 2026. Capacité de 60 000 places.',
                'location' => 'Dakar Centre',
                'latitude' => 14.7167,
                'longitude' => -17.4677,
                'address' => 'Boulevard Général de Gaulle, Dakar',
                'start_date' => '2026-08-16',
                'end_date' => '2026-08-23',
                'sports' => json_encode([
                    'Athlétisme',
                    'Cérémonies d\'ouverture et de clôture',
                ]),
                'access_info' => 'Accès par navettes gratuites depuis le centre-ville. Parking disponible. Métro ligne 1 (arrêt Stade Olympique).',
                'facilities' => json_encode([
                    'Parking',
                    'Restaurants',
                    'Boutiques',
                    'Point médical',
                    'WiFi gratuit',
                ]),
                'capacity' => 60000,
                'is_active' => true,
            ],
            [
                'name' => 'Dakar Arena',
                'description' => 'Arène couverte pour les compétitions d\'escrime, de badminton et de tennis de table.',
                'location' => 'Dakar Centre',
                'latitude' => 14.7014,
                'longitude' => -17.4517,
                'address' => 'Avenue Cheikh Anta Diop, Dakar',
                'start_date' => '2026-08-16',
                'end_date' => '2026-08-23',
                'sports' => json_encode([
                    'Escrime',
                    'Badminton',
                    'Tennis de table',
                ]),
                'access_info' => 'Accès facile depuis le centre-ville. Navettes gratuites disponibles.',
                'facilities' => json_encode([
                    'Parking',
                    'Snack-bar',
                    'Point médical',
                    'WiFi gratuit',
                ]),
                'capacity' => 8000,
                'is_active' => true,
            ],
            [
                'name' => 'Piscine Olympique',
                'description' => 'Piscine olympique pour les compétitions de natation et de water-polo.',
                'location' => 'Ouakam',
                'latitude' => 14.7217,
                'longitude' => -17.4927,
                'address' => 'Avenue Cheikh Anta Diop, Ouakam, Dakar',
                'start_date' => '2026-08-16',
                'end_date' => '2026-08-22',
                'sports' => json_encode([
                    'Natation',
                    'Water-polo',
                ]),
                'access_info' => 'Accès par navettes ou transport en commun. Parking limité.',
                'facilities' => json_encode([
                    'Vestiaires',
                    'Snack-bar',
                    'Point médical',
                    'WiFi gratuit',
                ]),
                'capacity' => 5000,
                'is_active' => true,
            ],
            [
                'name' => 'Complexe Sportif de M\'Bour',
                'description' => 'Complexe sportif pour les compétitions de basketball et de volleyball.',
                'location' => 'M\'Bour',
                'latitude' => 14.4167,
                'longitude' => -16.9677,
                'address' => 'Route de Thiès, M\'Bour',
                'start_date' => '2026-08-16',
                'end_date' => '2026-08-23',
                'sports' => json_encode([
                    'Basketball',
                    'Volleyball',
                ]),
                'access_info' => 'Navettes gratuites depuis Dakar. Durée du trajet : 1h30.',
                'facilities' => json_encode([
                    'Parking',
                    'Restaurant',
                    'Point médical',
                    'WiFi gratuit',
                ]),
                'capacity' => 12000,
                'is_active' => true,
            ],
            [
                'name' => 'Centre Équestre',
                'description' => 'Centre équestre pour les compétitions d\'équitation.',
                'location' => 'Almadies',
                'latitude' => 14.7367,
                'longitude' => -17.5077,
                'address' => 'Route de Ngor, Almadies, Dakar',
                'start_date' => '2026-08-17',
                'end_date' => '2026-08-21',
                'sports' => json_encode([
                    'Équitation',
                ]),
                'access_info' => 'Accès par navettes ou voiture. Parking disponible.',
                'facilities' => json_encode([
                    'Parking',
                    'Point médical vétérinaire',
                    'Snack-bar',
                    'WiFi gratuit',
                ]),
                'capacity' => 3000,
                'is_active' => true,
            ],
            [
                'name' => 'Terrain de Beach Volley',
                'description' => 'Terrain de beach volley sur la plage de Ngor.',
                'location' => 'Ngor',
                'latitude' => 14.7517,
                'longitude' => -17.5177,
                'address' => 'Plage de Ngor, Dakar',
                'start_date' => '2026-08-16',
                'end_date' => '2026-08-23',
                'sports' => json_encode([
                    'Beach Volley',
                ]),
                'access_info' => 'Accès libre depuis la plage. Parking disponible.',
                'facilities' => json_encode([
                    'Vestiaires',
                    'Douches',
                    'Point médical',
                ]),
                'capacity' => 2000,
                'is_active' => true,
            ],
        ];

        foreach ($sites as $site) {
            CompetitionSite::create($site);
        }
    }
}
