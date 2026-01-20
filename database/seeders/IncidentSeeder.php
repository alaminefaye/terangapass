<?php

namespace Database\Seeders;

use App\Models\Incident;
use App\Models\User;
use Illuminate\Database\Seeder;

class IncidentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Récupérer quelques utilisateurs mobiles
        $users = User::where('user_type', '!=', 'admin')->take(5)->get();

        if ($users->isEmpty()) {
            return; // Pas d'utilisateurs disponibles
        }

        $incidents = [
            [
                'type' => 'perte',
                'description' => 'Perte de portefeuille contenant des pièces d\'identité et des cartes bancaires. Portefeuille marron en cuir.',
                'latitude' => 14.6914,
                'longitude' => -17.4467,
                'accuracy' => 10.5,
                'address' => 'Plateau, Dakar, Sénégal',
                'photos' => null,
                'audio_url' => null,
                'status' => 'pending',
                'admin_notes' => null,
                'resolved_at' => null,
            ],
            [
                'type' => 'accident',
                'description' => 'Accident de circulation mineur entre deux véhicules. Aucun blessé. Dommages matériels uniquement.',
                'latitude' => 14.7167,
                'longitude' => -17.4677,
                'accuracy' => 15.0,
                'address' => 'Boulevard Général de Gaulle, près du Stade Olympique, Dakar',
                'photos' => null,
                'audio_url' => null,
                'status' => 'validated',
                'admin_notes' => 'Signalement validé. Police sur place.',
                'resolved_at' => null,
            ],
            [
                'type' => 'suspect',
                'description' => 'Comportement suspect observé près de l\'entrée principale du Stade Olympique. Personne semblant errer sans but précis.',
                'latitude' => 14.7167,
                'longitude' => -17.4677,
                'accuracy' => 8.3,
                'address' => 'Stade Olympique, entrée principale, Dakar',
                'photos' => null,
                'audio_url' => null,
                'status' => 'in_progress',
                'admin_notes' => 'Vérification en cours par les services de sécurité.',
                'resolved_at' => null,
            ],
            [
                'type' => 'perte',
                'description' => 'Perte d\'un téléphone portable. Modèle iPhone 13 Pro, coque noire. Dernière localisation connue : Dakar Arena.',
                'latitude' => 14.7014,
                'longitude' => -17.4517,
                'accuracy' => 12.7,
                'address' => 'Dakar Arena, Dakar, Sénégal',
                'photos' => null,
                'audio_url' => null,
                'status' => 'resolved',
                'admin_notes' => 'Téléphone retrouvé et rendu au propriétaire.',
                'resolved_at' => now()->subDays(1),
            ],
        ];

        $index = 0;
        foreach ($incidents as $incident) {
            $user = $users[$index % $users->count()];
            
            Incident::create([
                'user_id' => $user->id,
                'type' => $incident['type'],
                'description' => $incident['description'],
                'latitude' => $incident['latitude'],
                'longitude' => $incident['longitude'],
                'accuracy' => $incident['accuracy'],
                'address' => $incident['address'],
                'photos' => $incident['photos'],
                'audio_url' => $incident['audio_url'],
                'status' => $incident['status'],
                'admin_notes' => $incident['admin_notes'],
                'resolved_at' => $incident['resolved_at'],
                'created_at' => now()->subDays(rand(1, 7))->subHours(rand(1, 12)),
                'updated_at' => $incident['resolved_at'] ?? now(),
            ]);

            $index++;
        }
    }
}
