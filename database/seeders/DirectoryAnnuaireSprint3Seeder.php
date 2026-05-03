<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

/**
 * Sprint 3 annuaire (PDF Mohamed) : administrations, éducation, médias & culture — échantillons Dakar.
 */
class DirectoryAnnuaireSprint3Seeder extends Seeder
{
    public function run(): void
    {
        $entries = [
            // Administrations & services publics
            ['name' => 'Mairie de Dakar', 'category' => 'government', 'address' => 'Avenue Georges Pompidou, Plateau, Dakar', 'lat' => 14.6905, 'lng' => -17.4302],
            ['name' => 'Préfecture de Dakar', 'category' => 'government', 'address' => 'Plateau, Dakar', 'lat' => 14.6920, 'lng' => -17.4315],
            ['name' => 'Direction Générale des Impôts (DGID) — Dakar', 'category' => 'government', 'address' => 'Plateau, Dakar', 'lat' => 14.6910, 'lng' => -17.4325],
            ['name' => 'Caisse de Sécurité Sociale (CSS) — Dakar', 'category' => 'government', 'address' => 'Dakar', 'lat' => 14.6950, 'lng' => -17.4480],
            // Éducation
            ['name' => 'Université Cheikh Anta Diop (UCAD)', 'category' => 'university', 'address' => 'Dakar', 'lat' => 14.6848, 'lng' => -17.4665],
            ['name' => 'ISM — Institut Supérieur de Management', 'category' => 'university', 'address' => 'Mermoz, Dakar', 'lat' => 14.7055, 'lng' => -17.4750],
            ['name' => 'Lycée Kennedy', 'category' => 'school', 'address' => 'Plateau, Dakar', 'lat' => 14.6935, 'lng' => -17.4440],
            ['name' => 'Lycée John Fitzgerald Kennedy', 'category' => 'school', 'address' => 'Hann Maristes, Dakar', 'lat' => 14.7200, 'lng' => -17.4150],
            // Médias & culture
            ['name' => 'RTS — Radiodiffusion Télévision Sénégalaise', 'category' => 'media', 'address' => 'Dakar', 'lat' => 14.7240, 'lng' => -17.4580],
            ['name' => 'Le Soleil (siège)', 'category' => 'media', 'address' => 'Plateau, Dakar', 'lat' => 14.6922, 'lng' => -17.4438],
            ['name' => 'Grand Théâtre National Doudou Ndiaye Coumba Rose', 'category' => 'media', 'address' => 'Plateau, Dakar', 'lat' => 14.6945, 'lng' => -17.4420],
            ['name' => 'Musée des Civilisations Noires (MCN)', 'category' => 'media', 'address' => 'Plateau, Dakar', 'lat' => 14.6968, 'lng' => -17.4395],
        ];

        foreach ($entries as $i => $row) {
            Partner::query()->updateOrCreate(
                ['name' => $row['name']],
                [
                    'category' => $row['category'],
                    'description' => 'Annuaire professionnel TerangaPass (sprint 3 — démonstration, à enrichir avec sources officielles).',
                    'address' => $row['address'],
                    'latitude' => $row['lat'],
                    'longitude' => $row['lng'],
                    'phone' => null,
                    'email' => null,
                    'website' => null,
                    'logo_url' => null,
                    'is_sponsor' => $i < 2,
                    'visit_count' => 0,
                    'is_active' => true,
                ]
            );
        }
    }
}
