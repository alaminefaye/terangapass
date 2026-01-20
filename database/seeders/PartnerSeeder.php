<?php

namespace Database\Seeders;

use App\Models\Partner;
use Illuminate\Database\Seeder;

class PartnerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $partners = [
            // Hôtels
            [
                'name' => 'Hôtel Radisson Blu Dakar Sea Plaza',
                'category' => 'hotel',
                'description' => 'Hôtel 5 étoiles situé face à la mer, à proximité des sites de compétition.',
                'address' => 'Boulevard de la Corniche Ouest, Almadies, Dakar',
                'latitude' => 14.7367,
                'longitude' => -17.5077,
                'phone' => '+221338392222',
                'email' => 'reservations.dakar@radissonblu.com',
                'website' => 'https://www.radissonhotels.com',
                'logo_url' => null,
                'is_sponsor' => true,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Pullman Dakar Teranga',
                'category' => 'hotel',
                'description' => 'Hôtel de luxe au cœur de Dakar, idéal pour les participants aux JOJ.',
                'address' => 'Avenue Faidherbe, Plateau, Dakar',
                'latitude' => 14.6914,
                'longitude' => -17.4467,
                'phone' => '+221338492100',
                'email' => 'reservations.dakar@pullman.com',
                'website' => 'https://www.pullmanhotels.com',
                'logo_url' => null,
                'is_sponsor' => true,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Hôtel Terrou-Bi',
                'category' => 'hotel',
                'description' => 'Hôtel 4 étoiles avec vue sur l\'océan.',
                'address' => 'Boulevard Martin Luther King, Almadies, Dakar',
                'latitude' => 14.7417,
                'longitude' => -17.5127,
                'phone' => '+221338392200',
                'email' => 'reservations@terroubi.com',
                'website' => 'https://www.terroubi.com',
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],

            // Restaurants
            [
                'name' => 'Restaurant Chez Loutcha',
                'category' => 'restaurant',
                'description' => 'Restaurant traditionnel sénégalais, spécialités locales.',
                'address' => 'Rue de la République, Plateau, Dakar',
                'latitude' => 14.6944,
                'longitude' => -17.4477,
                'phone' => '+221338212345',
                'email' => null,
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Le Ngor',
                'category' => 'restaurant',
                'description' => 'Restaurant gastronomique français avec vue sur mer.',
                'address' => 'Route de Ngor, Almadies, Dakar',
                'latitude' => 14.7517,
                'longitude' => -17.5177,
                'phone' => '+221338393939',
                'email' => 'contact@lengor.sn',
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'La Fourchette',
                'category' => 'restaurant',
                'description' => 'Restaurant international, cuisine variée.',
                'address' => 'Avenue Cheikh Anta Diop, Dakar',
                'latitude' => 14.7014,
                'longitude' => -17.4517,
                'phone' => '+221338214567',
                'email' => null,
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],

            // Pharmacies
            [
                'name' => 'Pharmacie Centrale du Plateau',
                'category' => 'pharmacy',
                'description' => 'Pharmacie principale du quartier Plateau, ouverte 24/7.',
                'address' => 'Avenue Faidherbe, Plateau, Dakar',
                'latitude' => 14.6924,
                'longitude' => -17.4467,
                'phone' => '+221338211234',
                'email' => null,
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Pharmacie de la Corniche',
                'category' => 'pharmacy',
                'description' => 'Pharmacie située sur la Corniche Ouest.',
                'address' => 'Boulevard de la Corniche Ouest, Almadies, Dakar',
                'latitude' => 14.7387,
                'longitude' => -17.5087,
                'phone' => '+221338393333',
                'email' => null,
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],

            // Hôpitaux
            [
                'name' => 'Hôpital Principal de Dakar',
                'category' => 'hospital',
                'description' => 'Hôpital public principal de Dakar, urgences 24/7.',
                'address' => 'Avenue Cheikh Anta Diop, Dakar',
                'latitude' => 14.7024,
                'longitude' => -17.4527,
                'phone' => '+221338385850',
                'email' => null,
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Clinique Pasteur',
                'category' => 'hospital',
                'description' => 'Clinique privée avec services d\'urgence.',
                'address' => 'Boulevard de la République, Plateau, Dakar',
                'latitude' => 14.6934,
                'longitude' => -17.4477,
                'phone' => '+221338212345',
                'email' => 'contact@cliniquepasteur.sn',
                'website' => null,
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],

            // Ambassades
            [
                'name' => 'Ambassade de France',
                'category' => 'embassy',
                'description' => 'Ambassade de France au Sénégal.',
                'address' => 'Route des Almadies, Dakar',
                'latitude' => 14.7427,
                'longitude' => -17.5117,
                'phone' => '+221338395000',
                'email' => 'contact.ambafrance@diplomatie.gouv.fr',
                'website' => 'https://sn.ambafrance.org',
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
            [
                'name' => 'Ambassade des États-Unis',
                'category' => 'embassy',
                'description' => 'Embassy of the United States in Senegal.',
                'address' => 'Route des Almadies, Dakar',
                'latitude' => 14.7447,
                'longitude' => -17.5127,
                'phone' => '+221338792100',
                'email' => 'dakarconsul@state.gov',
                'website' => 'https://sn.usembassy.gov',
                'logo_url' => null,
                'is_sponsor' => false,
                'visit_count' => 0,
                'is_active' => true,
            ],
        ];

        foreach ($partners as $partner) {
            Partner::create($partner);
        }
    }
}
