<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

/**
 * Sprint 4 annuaire (PDF Mohamed) : services professionnels & lieux de culte — échantillons.
 * Données de démonstration ; enrichissement terrain et validation éditoriale requis en production.
 */
class DirectoryAnnuaireSprint4Seeder extends Seeder
{
    public function run(): void
    {
        $entries = [
            [
                'name' => 'Services plomberie — démo TerangaPass',
                'category' => 'professional_service',
                'address' => 'Ouakam, Dakar',
                'lat' => 14.7245,
                'lng' => -17.4920,
                'description' => 'Prestataire artisan (exemple sprint 4 — annuaire services pros).',
            ],
            [
                'name' => 'Agence immobilière — démo TerangaPass',
                'category' => 'professional_service',
                'address' => 'Plateau, Dakar',
                'lat' => 14.6930,
                'lng' => -17.4445,
                'description' => 'Agence (exemple sprint 4 — sous-catégories détaillées à prévoir en V2).',
            ],
            [
                'name' => 'Salon de coiffure — démo TerangaPass',
                'category' => 'professional_service',
                'address' => 'Mermoz, Dakar',
                'lat' => 14.7070,
                'lng' => -17.4740,
                'description' => 'Service beauté / coiffure (exemple sprint 4).',
            ],
            [
                'name' => 'Grande Mosquée de Dakar',
                'category' => 'religious_site',
                'address' => 'Plateau, Dakar',
                'lat' => 14.6958,
                'lng' => -17.4395,
                'description' => 'Lieu de culte musulman — données indicatives pour démo ; horaires et contacts à vérifier sur place.',
            ],
            [
                'name' => 'Cathédrale Notre-Dame des Victoires (Cathédrale du Souvenir Africain)',
                'category' => 'religious_site',
                'address' => 'Plateau, Dakar',
                'lat' => 14.6972,
                'lng' => -17.4388,
                'description' => 'Lieu de culte catholique — données indicatives pour démo.',
            ],
            [
                'name' => 'Mosquée de la Divinité (Ouakam)',
                'category' => 'religious_site',
                'address' => 'Ouakam, Dakar',
                'lat' => 14.7225,
                'lng' => -17.5015,
                'description' => 'Lieu de culte musulman — données indicatives pour démo.',
            ],
        ];

        foreach ($entries as $row) {
            Partner::query()->updateOrCreate(
                ['name' => $row['name']],
                [
                    'category' => $row['category'],
                    'description' => $row['description'],
                    'address' => $row['address'],
                    'latitude' => $row['lat'],
                    'longitude' => $row['lng'],
                    'phone' => null,
                    'email' => null,
                    'website' => null,
                    'logo_url' => null,
                    'is_sponsor' => false,
                    'visit_count' => 0,
                    'is_active' => true,
                ]
            );
        }
    }
}
