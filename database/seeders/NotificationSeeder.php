<?php

namespace Database\Seeders;

use App\Models\Notification;
use Illuminate\Database\Seeder;

class NotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $notifications = [
            [
                'type' => 'sécurité',
                'title' => 'Alerte Sécurité: Stade Olympique - Vigilance requise!',
                'description' => 'Renforcement de la sécurité autour du Stade Olympique. Soyez vigilant et suivez les consignes des agents de sécurité.',
                'zone' => 'Dakar Centre',
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
            [
                'type' => 'transport',
                'title' => 'Navettes Gratuites JOJ 2026',
                'description' => 'Les navettes gratuites sont disponibles tous les jours de 08:30 à 19:30. Fréquence : toutes les 20 minutes. Navettes sécurisées entre les sites de compétition.',
                'zone' => 'Dakar Centre',
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
            [
                'type' => 'météo',
                'title' => 'Météo: Chaleur importante ce midi',
                'description' => 'Température maximale prévue : 35°C. Pensez à vous hydrater régulièrement et à porter une protection solaire. Évitez les expositions prolongées au soleil.',
                'zone' => 'Toutes les zones',
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
            [
                'type' => 'consignes_joj',
                'title' => 'Rappel: Horaires des compétitions',
                'description' => 'Les compétitions débutent à 09:00 chaque jour. Les portes ouvrent 1 heure avant le début. Consultez l\'application pour les horaires détaillés.',
                'zone' => 'Toutes les zones',
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
            [
                'type' => 'sécurité routière',
                'title' => 'Sécurité routière: Pose de dispositifs de sécurité',
                'description' => 'Travaux en cours sur la route principale menant au Stade Olympique. Ralentissez et suivez les panneaux de signalisation.',
                'zone' => 'Plateau',
                'target_locations' => json_encode([
                    ['latitude' => 14.6914, 'longitude' => -17.4467],
                ]),
                'is_active' => true,
                'scheduled_at' => now(),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
            [
                'type' => 'circulation',
                'title' => 'Trafic dense prévu cet après-midi',
                'description' => 'Trafic dense attendu sur les axes principaux entre 17h00 et 19h00. Prévoyez plus de temps pour vos déplacements ou utilisez les navettes gratuites.',
                'zone' => 'Dakar Centre',
                'target_locations' => json_encode([
                    ['latitude' => 14.7167, 'longitude' => -17.4677],
                ]),
                'is_active' => true,
                'scheduled_at' => now()->addHours(2),
                'sent_count' => 0,
                'viewed_count' => 0,
            ],
        ];

        foreach ($notifications as $notification) {
            Notification::create($notification);
        }
    }
}
