<?php

namespace Database\Seeders;

use App\Models\AudioAnnouncement;
use App\Models\CompetitionSite;
use App\Models\Notification;
use Illuminate\Database\Seeder;

class JojInfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $competitionSports = [
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

        $demoSports = [
            'Canoë-kayak',
            'Golf',
            'Hockey',
            'Karaté',
            'Pentathlon moderne',
            'Tir',
            'Escalade',
            'Surf',
            'Tennis',
            'Haltérophilie',
        ];

        $calendarLines = [
            'Judo: 1–3 nov (Dakar Expo Center)',
            'Futsal: 1–12 nov (Iba Mar Diop / Dakar Arena)',
            'Natation: 1–6 nov (Tour de l\'Œuf / Dakar Arena)',
            'Rugby à 7: 1–3 nov (Complexe Iba Mar Diop)',
            'Équitation: 3–6 nov (Complexe équestre Diamniadio)',
            'Skateboard: 4–5 nov (Tour de l\'Œuf)',
            'Gymnastique: 5–11 nov (Dakar Expo Center)',
            'Boxe: 7–12 nov (Dakar Expo Center)',
            'Cyclisme: 8 & 10 nov (Corniche Ouest, Dakar)',
            'Escrime: 8–13 nov (Dakar Expo Center)',
            'Handball de plage: 9–13 nov (Saly plage ouest)',
            'Lutte de plage: 7–8 nov (Saly plage ouest)',
        ];

        $sites = [
            [
                'name' => 'Tour de l\'Œuf',
                'description' => 'Site officiel JOJ Dakar 2026 pour les sports urbains et aquatiques.',
                'location' => 'Dakar',
                'latitude' => 14.6937,
                'longitude' => -17.4478,
                'address' => 'Tour de l\'Œuf, Dakar',
                'start_date' => '2026-10-31',
                'end_date' => '2026-11-13',
                'sports' => [
                    'Basketball 3x3',
                    'Baseball5',
                    'Breaking',
                    'Skateboard',
                    'Natation',
                ],
                'access_info' => 'Accès principal à Dakar centre. Billetterie officielle JOJ à venir.',
                'facilities' => ['Billetterie', 'Point info', 'Zone restauration', 'Poste médical'],
                'capacity' => 12000,
                'is_active' => true,
            ],
            [
                'name' => 'Stade Iba Mar Diop',
                'description' => 'Site officiel JOJ Dakar 2026 pour athlétisme, boxe et futsal.',
                'location' => 'Dakar',
                'latitude' => 14.6969,
                'longitude' => -17.4546,
                'address' => 'Complexe Iba Mar Diop, Dakar',
                'start_date' => '2026-10-31',
                'end_date' => '2026-11-13',
                'sports' => ['Athlétisme', 'Boxe', 'Futsal', 'Rugby à 7'],
                'access_info' => 'Navettes et accès urbain via Dakar centre.',
                'facilities' => ['Accès PMR', 'Poste médical', 'Restauration'],
                'capacity' => 18000,
                'is_active' => true,
            ],
            [
                'name' => 'Dakar Expo Center',
                'description' => 'Site majeur JOJ Dakar 2026 pour sports indoor.',
                'location' => 'Dakar',
                'latitude' => 14.7095,
                'longitude' => -17.4588,
                'address' => 'Dakar Expo Center, Dakar',
                'start_date' => '2026-10-31',
                'end_date' => '2026-11-13',
                'sports' => ['Judo', 'Boxe', 'Escrime', 'Gymnastique'],
                'access_info' => 'Point d\'entrée officiel JOJ pour compétitions indoor.',
                'facilities' => ['Billetterie', 'Contrôle sécurité', 'Infirmerie'],
                'capacity' => 20000,
                'is_active' => true,
            ],
            [
                'name' => 'Dakar Arena',
                'description' => 'Site officiel JOJ à Diamniadio.',
                'location' => 'Diamniadio',
                'latitude' => 14.7300,
                'longitude' => -17.2000,
                'address' => 'Dakar Arena, Diamniadio',
                'start_date' => '2026-10-31',
                'end_date' => '2026-11-13',
                'sports' => ['Natation', 'Futsal'],
                'access_info' => 'Accès par navettes JOJ depuis Dakar.',
                'facilities' => ['Parking', 'Poste médical', 'Zone support'],
                'capacity' => 15000,
                'is_active' => true,
            ],
            [
                'name' => 'Complexe équestre Diamniadio',
                'description' => 'Site officiel JOJ pour les épreuves équestres.',
                'location' => 'Diamniadio',
                'latitude' => 14.7360,
                'longitude' => -17.1880,
                'address' => 'Complexe équestre, Diamniadio',
                'start_date' => '2026-11-03',
                'end_date' => '2026-11-06',
                'sports' => ['Équitation'],
                'access_info' => 'Accès contrôlé avec navettes JOJ et parking.',
                'facilities' => ['Parking', 'Zone technique', 'Poste vétérinaire'],
                'capacity' => 5000,
                'is_active' => true,
            ],
            [
                'name' => 'Saly plage ouest',
                'description' => 'Site côtier JOJ pour les disciplines de plage.',
                'location' => 'Saly',
                'latitude' => 14.4394,
                'longitude' => -17.0163,
                'address' => 'Saly plage ouest, Saly',
                'start_date' => '2026-11-07',
                'end_date' => '2026-11-13',
                'sports' => ['Handball de plage', 'Lutte de plage'],
                'access_info' => 'Accès sécurisé JOJ depuis Saly et Dakar.',
                'facilities' => ['Zone spectateurs', 'Poste secours', 'Vestiaires'],
                'capacity' => 7000,
                'is_active' => true,
            ],
        ];

        foreach ($sites as $site) {
            CompetitionSite::updateOrCreate(
                ['name' => $site['name']],
                [
                    'description' => $site['description'],
                    'location' => $site['location'],
                    'latitude' => $site['latitude'],
                    'longitude' => $site['longitude'],
                    'address' => $site['address'],
                    'start_date' => $site['start_date'],
                    'end_date' => $site['end_date'],
                    'sports' => $site['sports'],
                    'access_info' => $site['access_info'],
                    'facilities' => $site['facilities'],
                    'capacity' => $site['capacity'],
                    'is_active' => $site['is_active'],
                ]
            );
        }

        Notification::updateOrCreate(
            ['title' => 'JOJ Dakar 2026: calendrier officiel'],
            [
                'type' => 'consignes_joj',
                'description' => "Du 31 octobre au 13 novembre 2026.\n" . implode("\n", $calendarLines),
                'zone' => 'Toutes les zones',
                'target_locations' => [['latitude' => 14.7167, 'longitude' => -17.4677]],
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ]
        );

        Notification::updateOrCreate(
            ['title' => 'JOJ Dakar 2026: sports en compétition et démonstration'],
            [
                'type' => 'consignes_joj',
                'description' => 'Sports compétition (25): ' . implode(', ', $competitionSports)
                    . '. Sports démonstration (10): ' . implode(', ', $demoSports) . '.',
                'zone' => 'Toutes les zones',
                'target_locations' => [['latitude' => 14.7167, 'longitude' => -17.4677]],
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ]
        );

        AudioAnnouncement::updateOrCreate(
            ['title' => 'JOJ Dakar 2026: informations officielles'],
            [
                'content' => 'JOJ Dakar 2026 du 31 octobre au 13 novembre. Consultez les sites officiels, le calendrier et la section accès dans l\'application. Billetterie officielle: olympics.com/fr/olympic-games/dakar-2026.',
                'language' => 'fr',
                'audio_url' => '/storage/audio/joj_2026_infos_fr.mp3',
                'duration' => 80,
                'target_locations' => [['latitude' => 14.7167, 'longitude' => -17.4677]],
                'play_count' => 0,
                'is_active' => true,
            ]
        );
    }
}
