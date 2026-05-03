<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

/**
 * Échantillon annuaire pro — sprint 2 (PDF Mohamed) : notaires, avocats, cliniques, médecins.
 * Coordonnées indicative Dakar pour « À deux pas » ; données à enrichir avec sources officielles.
 */
class DirectoryAnnuaireSprint2Seeder extends Seeder
{
    public function run(): void
    {
        $entries = [
            // Notaires (noms issus du document de référence)
            ['name' => 'Maître Tafsir Aly TOUNKARA', 'category' => 'notary', 'address' => 'Plateau, Dakar', 'lat' => 14.6935, 'lng' => -17.4448],
            ['name' => 'Maître Aïssatou Tamba GUEYE', 'category' => 'notary', 'address' => 'Plateau, Dakar', 'lat' => 14.6928, 'lng' => -17.4435],
            ['name' => 'Maître Patricia Lake DIOP', 'category' => 'notary', 'address' => 'Almadies, Dakar', 'lat' => 14.7380, 'lng' => -17.5080],
            ['name' => 'Maître Mamadou DIENG', 'category' => 'notary', 'address' => 'Sacré-Cœur, Dakar', 'lat' => 14.7120, 'lng' => -17.4680],
            ['name' => 'Maître Mame Adama GUEYE', 'category' => 'notary', 'address' => 'Mermoz, Dakar', 'lat' => 14.7075, 'lng' => -17.4735],
            // Avocats (cabinets cités dans le document)
            ['name' => 'Houda Avocats', 'category' => 'lawyer', 'address' => 'Plateau, Dakar', 'lat' => 14.6942, 'lng' => -17.4455],
            ['name' => 'Geni & Kebe', 'category' => 'lawyer', 'address' => 'Plateau, Dakar', 'lat' => 14.6930, 'lng' => -17.4462],
            ['name' => 'AnnGo Avocats', 'category' => 'lawyer', 'address' => 'Sacré-Cœur, Dakar', 'lat' => 14.7110, 'lng' => -17.4695],
            ['name' => 'BLB Avocats', 'category' => 'lawyer', 'address' => 'Mermoz, Dakar', 'lat' => 14.7065, 'lng' => -17.4745],
            ['name' => 'Cabinet Khaled Houda', 'category' => 'lawyer', 'address' => 'Almadies, Dakar', 'lat' => 14.7370, 'lng' => -17.5070],
            // Cliniques
            ['name' => 'Clinique de la Madeleine', 'category' => 'clinic', 'address' => 'Médina, Dakar', 'lat' => 14.6820, 'lng' => -17.4370],
            ['name' => 'Clinique du Cap', 'category' => 'clinic', 'address' => 'Almadies, Dakar', 'lat' => 14.7395, 'lng' => -17.5095],
            ['name' => 'Clinique Croix Bleue', 'category' => 'clinic', 'address' => 'Plateau, Dakar', 'lat' => 14.6915, 'lng' => -17.4470],
            // Médecins (cabinet / titre)
            ['name' => 'Dr Aminata SECK — Médecine générale', 'category' => 'doctor', 'address' => 'Plateau, Dakar', 'lat' => 14.6925, 'lng' => -17.4440],
            ['name' => 'Dr Ibrahima DIAGNE — Cardiologie', 'category' => 'doctor', 'address' => 'Plateau, Dakar', 'lat' => 14.6938, 'lng' => -17.4450],
            ['name' => 'Dr Marie NDIAYE — Pédiatrie', 'category' => 'doctor', 'address' => 'Fann, Dakar', 'lat' => 14.7010, 'lng' => -17.4520],
        ];

        foreach ($entries as $i => $row) {
            Partner::query()->updateOrCreate(
                ['name' => $row['name']],
                [
                    'category' => $row['category'],
                    'description' => 'Annuaire professionnel TerangaPass (sprint 2 — données de démonstration à enrichir).',
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
