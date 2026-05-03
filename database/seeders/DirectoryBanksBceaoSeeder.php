<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

/**
 * Liste des 28 banques agréées BCEAO (UMOA) citées dans TerangaPass_AnnuairePro_Mohamed.pdf.
 * Coordonnées : répartition légère autour du centre de Dakar pour démo « À deux pas » uniquement.
 * En production : remplacer par géoloc agences / sièges réels ou import officiel.
 */
class DirectoryBanksBceaoSeeder extends Seeder
{
    public function run(): void
    {
        $banks = [
            ['name' => 'CBAO Groupe Attijariwafa Bank', 'type' => 'Banque universelle'],
            ['name' => 'Société Générale Sénégal (SGSN)', 'type' => 'Banque universelle'],
            ['name' => 'Bank of Africa Sénégal (BOA Sénégal)', 'type' => 'Banque universelle'],
            ['name' => 'Ecobank Sénégal', 'type' => 'Banque universelle'],
            ['name' => "Banque de l'Habitat du Sénégal (BHS)", 'type' => 'Crédit immobilier'],
            ['name' => 'Banque Islamique du Sénégal (BIS)', 'type' => 'Banque islamique'],
            ['name' => 'BICIS (BNP Paribas)', 'type' => 'Banque universelle'],
            ['name' => 'Crédit du Sénégal (Crédit Mutuel)', 'type' => 'Banque universelle'],
            ['name' => 'United Bank for Africa Sénégal (UBA)', 'type' => 'Banque universelle'],
            ['name' => 'FBNBank Sénégal', 'type' => 'Banque commerciale'],
            ['name' => 'BNDE — Banque Nationale Développement Économique', 'type' => 'Banque publique'],
            ['name' => 'La Banque Agricole (LBA)', 'type' => 'Crédit agricole'],
            ['name' => 'La Banque Outarde (LBO)', 'type' => 'Banque commerciale'],
            ['name' => 'Banque Atlantique Sénégal', 'type' => 'Banque universelle'],
            ['name' => 'Banque de Dakar', 'type' => 'Banque commerciale'],
            ['name' => 'Citibank Sénégal', 'type' => 'Banque internationale'],
            ['name' => 'Algerian Bank of Senegal (ABS)', 'type' => 'Banque internationale'],
            ['name' => 'Coris Bank International Sénégal', 'type' => 'Banque universelle'],
            ['name' => 'Diamond Bank Sénégal', 'type' => 'Banque commerciale'],
            ['name' => 'Orange Bank Africa (succursale)', 'type' => 'Banque digitale'],
            ['name' => 'BDM Sénégal (Banque Développement Mali)', 'type' => 'Succursale'],
            ['name' => 'BCI-Mali Sénégal', 'type' => 'Succursale'],
            ['name' => 'BBG-CI Sénégal (Bridge Bank)', 'type' => 'Succursale'],
            ['name' => 'NSIA Banque Bénin Sénégal', 'type' => 'Succursale'],
            ["name" => "Orabank Côte d'Ivoire Sénégal", 'type' => 'Succursale'],
            ['name' => 'Banque Sahélo-Saharienne (BSIC)', 'type' => 'Banque régionale'],
            ['name' => 'Banque Régionale de Marchés (BRM)', 'type' => "Banque d'investissement"],
            ["name" => "Banque de Développement de l'Afrique de l'Ouest (BOAD)", 'type' => 'Banque de développement'],
        ];

        $baseLat = 14.6937;
        $baseLng = -17.4441;
        $n = count($banks);

        foreach ($banks as $i => $row) {
            $t = $n > 1 ? ($i / ($n - 1)) : 0.5;
            $lat = $baseLat + (($t - 0.5) * 0.08);
            $lng = $baseLng + (($t - 0.5) * 0.08);

            Partner::query()->updateOrCreate(
                ['name' => $row['name']],
                [
                    'category' => 'bank',
                    'description' => 'Banque agréée BCEAO UMOA — '.$row['type'].'. (Données annuaire pro TerangaPass, coordonnées de démonstration.)',
                    'address' => 'Dakar, Sénégal',
                    'latitude' => round($lat, 6),
                    'longitude' => round($lng, 6),
                    'phone' => null,
                    'email' => null,
                    'website' => null,
                    'logo_url' => null,
                    'is_sponsor' => $i < 3,
                    'visit_count' => 0,
                    'is_active' => true,
                ]
            );
        }
    }
}
