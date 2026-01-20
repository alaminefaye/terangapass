<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            // 1. Zones en premier (nécessaires pour les notifications)
            ZoneSeeder::class,
            
            // 2. Utilisateurs (nécessaires pour alertes et incidents)
            UserSeeder::class,
            
            // 3. Partenaires (hôtels, restaurants, etc.)
            PartnerSeeder::class,
            
            // 4. Sites de compétition
            CompetitionSiteSeeder::class,
            
            // 5. Navettes et transports
            ShuttleSeeder::class,
            
            // 6. Annonces audio
            AudioAnnouncementSeeder::class,
            
            // 7. Notifications
            NotificationSeeder::class,
            
            // 8. Alertes (nécessite des utilisateurs)
            AlertSeeder::class,
            
            // 9. Incidents (nécessite des utilisateurs)
            IncidentSeeder::class,
        ]);
    }
}
