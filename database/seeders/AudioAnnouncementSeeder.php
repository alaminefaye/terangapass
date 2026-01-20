<?php

namespace Database\Seeders;

use App\Models\AudioAnnouncement;
use Illuminate\Database\Seeder;

class AudioAnnouncementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $announcements = [
            [
                'title' => 'Consignes de sécurité JOJ 2026',
                'content' => 'Suivez les consignes de sécurité pour les Jeux Olympiques de la Jeunesse. En cas d\'urgence, composez le 17 pour la police, le 18 pour les pompiers ou le 15 pour le SAMU.',
                'language' => 'fr',
                'audio_url' => '/storage/audio/securite_joj_fr.mp3',
                'duration' => 120,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
            [
                'title' => 'Navettes gratuites disponibles',
                'content' => 'Les navettes gratuites sont disponibles tous les jours de 08:30 à 19:30. Fréquence : toutes les 20 minutes. Navettes sécurisées entre les sites de compétition.',
                'language' => 'fr',
                'audio_url' => '/storage/audio/navettes_gratuites_fr.mp3',
                'duration' => 90,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
            [
                'title' => 'JOJ 2026 Safety Guidelines',
                'content' => 'Follow safety guidelines for the Youth Olympic Games. In case of emergency, call 17 for police, 18 for firefighters, or 15 for medical assistance.',
                'language' => 'en',
                'audio_url' => '/storage/audio/securite_joj_en.mp3',
                'duration' => 115,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
            [
                'title' => 'Free shuttles available',
                'content' => 'Free shuttles are available every day from 8:30 AM to 7:30 PM. Frequency: every 20 minutes. Secure shuttles between competition venues.',
                'language' => 'en',
                'audio_url' => '/storage/audio/navettes_gratuites_en.mp3',
                'duration' => 85,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
            [
                'title' => 'Météo du jour - JOJ 2026',
                'content' => 'Aujourd\'hui, température maximale de 35°C. Pensez à vous hydrater régulièrement et à porter une protection solaire. Évitez les expositions prolongées au soleil.',
                'language' => 'fr',
                'audio_url' => '/storage/audio/meteo_joj_fr.mp3',
                'duration' => 60,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
            [
                'title' => 'Horaires des compétitions',
                'content' => 'Les compétitions débutent à 09:00 chaque jour. Consultez l\'application pour les horaires détaillés de chaque sport. Les portes ouvrent 1 heure avant le début des compétitions.',
                'language' => 'fr',
                'audio_url' => '/storage/audio/horaires_competitions_fr.mp3',
                'duration' => 75,
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'play_count' => 0,
                'is_active' => true,
            ],
        ];

        foreach ($announcements as $announcement) {
            AudioAnnouncement::create($announcement);
        }
    }
}
