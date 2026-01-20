<?php

namespace Database\Seeders;

use App\Models\Alert;
use App\Models\User;
use Illuminate\Database\Seeder;

class AlertSeeder extends Seeder
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

        $alerts = [
            [
                'type' => 'sos',
                'emergency_type' => null,
                'latitude' => 14.7167,
                'longitude' => -17.4677,
                'accuracy' => 10.5,
                'address' => 'Stade Olympique, Dakar, Sénégal',
                'status' => 'resolved',
                'notes' => 'Alerte résolue rapidement par les services de sécurité.',
                'resolved_at' => now()->subHours(2),
            ],
            [
                'type' => 'medical',
                'emergency_type' => 'accident',
                'latitude' => 14.6914,
                'longitude' => -17.4467,
                'accuracy' => 15.0,
                'address' => 'Plateau, Dakar, Sénégal',
                'status' => 'in_progress',
                'notes' => 'Intervention en cours par les équipes médicales.',
                'resolved_at' => null,
            ],
            [
                'type' => 'sos',
                'emergency_type' => null,
                'latitude' => 14.7014,
                'longitude' => -17.4517,
                'accuracy' => 8.3,
                'address' => 'Dakar Arena, Dakar, Sénégal',
                'status' => 'pending',
                'notes' => null,
                'resolved_at' => null,
            ],
            [
                'type' => 'medical',
                'emergency_type' => 'malaise',
                'latitude' => 14.7367,
                'longitude' => -17.5077,
                'accuracy' => 12.7,
                'address' => 'Almadies, Dakar, Sénégal',
                'status' => 'resolved',
                'notes' => 'Personne prise en charge et transportée à l\'hôpital.',
                'resolved_at' => now()->subDays(1),
            ],
        ];

        $index = 0;
        foreach ($alerts as $alert) {
            $user = $users[$index % $users->count()];
            
            Alert::create([
                'user_id' => $user->id,
                'type' => $alert['type'],
                'emergency_type' => $alert['emergency_type'],
                'latitude' => $alert['latitude'],
                'longitude' => $alert['longitude'],
                'accuracy' => $alert['accuracy'],
                'address' => $alert['address'],
                'status' => $alert['status'],
                'notes' => $alert['notes'],
                'resolved_at' => $alert['resolved_at'],
                'created_at' => now()->subDays(rand(1, 5))->subHours(rand(1, 12)),
                'updated_at' => $alert['resolved_at'] ?? now(),
            ]);

            $index++;
        }
    }
}
