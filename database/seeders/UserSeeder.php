<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin user
        // Note: La valeur 'admin' sera disponible après exécution de la migration modify_user_type_enum
        // Si la migration n'est pas encore exécutée, utilisez 'visitor' temporairement
        $adminExists = User::where('email', 'admin@terangapass.com')->exists();
        if (!$adminExists) {
            // Vérifier si l'ENUM supporte 'admin'
            try {
                User::create([
                    'name' => 'Admin Teranga Pass',
                    'email' => 'admin@terangapass.com',
                    'password' => Hash::make('password'),
                    'user_type' => 'admin',
                    'country' => 'SN',
                    'phone' => '+221771234567',
                    'language' => 'fr',
                ]);
            } catch (\Exception $e) {
                // Si 'admin' n'est pas disponible, créer en tant que 'visitor' temporairement
                User::create([
                    'name' => 'Admin Teranga Pass',
                    'email' => 'admin@terangapass.com',
                    'password' => Hash::make('password'),
                    'user_type' => 'visitor',
                    'country' => 'SN',
                    'phone' => '+221771234567',
                    'language' => 'fr',
                ]);
            }
        }

        // Utilisateurs mobiles de test
        $mobileUsers = [
            [
                'name' => 'Amadou Diallo',
                'email' => 'amadou.diallo@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'visitor',
                'country' => 'SN',
                'phone' => '+221771111111',
                'language' => 'fr',
            ],
            [
                'name' => 'Mariama Sarr',
                'email' => 'mariama.sarr@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'athlete',
                'country' => 'SN',
                'phone' => '+221772222222',
                'language' => 'fr',
            ],
            [
                'name' => 'John Smith',
                'email' => 'john.smith@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'visitor',
                'country' => 'US',
                'phone' => '+1234567890',
                'language' => 'en',
            ],
            [
                'name' => 'Sophie Martin',
                'email' => 'sophie.martin@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'citizen', // Utilise 'citizen' au lieu de 'volunteer'
                'country' => 'FR',
                'phone' => '+33123456789',
                'language' => 'fr',
            ],
            [
                'name' => 'Ibrahima Fall',
                'email' => 'ibrahima.fall@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'citizen',
                'country' => 'SN',
                'phone' => '+221773333333',
                'language' => 'fr',
            ],
            [
                'name' => 'Aissatou Ndiaye',
                'email' => 'aissatou.ndiaye@example.com',
                'password' => Hash::make('password'),
                'user_type' => 'athlete',
                'country' => 'SN',
                'phone' => '+221774444444',
                'language' => 'fr',
            ],
        ];

        foreach ($mobileUsers as $user) {
            User::create($user);
        }
    }
}
