<?php

namespace App\Http\Controllers;

use App\Models\Alert;
use App\Models\Incident;
use App\Models\Notification;
use App\Models\AudioAnnouncement;
use App\Models\Partner;
use App\Models\User;
use App\Models\NotificationLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        // Statistiques principales
        $stats = [
            'audio_announcements' => AudioAnnouncement::sum('play_count'),
            'sos_alerts' => Alert::where('type', 'sos')->count(),
            'medical_alerts' => Alert::where('type', 'medical')->count(),
            'total_alerts' => Alert::count(),
            'notifications_sent' => Notification::sum('sent_count'),
            'incidents' => Incident::count(),
            'sponsor_ads' => Partner::where('is_sponsor', true)->count(),
            'total_users' => User::count(),
        ];

        // Statistiques par pays
        $usersByCountry = User::select('country', DB::raw('count(*) as count'))
            ->groupBy('country')
            ->orderByDesc('count')
            ->get();

        // Données pour la carte
        $mapData = [
            'sos' => Alert::where('type', 'sos')
                ->select('latitude', 'longitude', 'address', 'created_at')
                ->latest()
                ->limit(50)
                ->get(),
            'alerts' => Alert::where('type', 'medical')
                ->select('latitude', 'longitude', 'address', 'created_at')
                ->latest()
                ->limit(50)
                ->get(),
            'hotels' => Partner::where('category', 'hotel')
                ->whereNotNull('latitude')
                ->whereNotNull('longitude')
                ->select('name', 'latitude', 'longitude', 'address')
                ->get(),
            'restaurants' => Partner::where('category', 'restaurant')
                ->whereNotNull('latitude')
                ->whereNotNull('longitude')
                ->select('name', 'latitude', 'longitude', 'address')
                ->get(),
        ];

        // Notifications/Signalements géolocalisés par site
        $geolocatedData = $this->getGeolocatedData();

        // Données pour les graphiques
        $chartData = [
            'announcements_week' => $this->getAnnouncementsWeekData(),
            'traffic_sources' => $this->getTrafficSourcesData(),
        ];

        // Pourcentages et variations
        $variations = [
            'sos_increase' => $this->calculatePercentageChange(
                Alert::where('type', 'sos')
                    ->whereDate('created_at', '>=', now()->subDays(7))
                    ->count(),
                Alert::where('type', 'sos')
                    ->whereDate('created_at', '>=', now()->subDays(14))
                    ->whereDate('created_at', '<', now()->subDays(7))
                    ->count()
            ),
            'incidents_increase' => $this->calculatePercentageChange(
                Incident::whereDate('created_at', '>=', now()->subDays(7))->count(),
                Incident::whereDate('created_at', '>=', now()->subDays(14))
                    ->whereDate('created_at', '<', now()->subDays(7))
                    ->count()
            ),
        ];

        return view('dashboard', compact(
            'stats',
            'usersByCountry',
            'mapData',
            'geolocatedData',
            'chartData',
            'variations'
        ));
    }

    private function getGeolocatedData()
    {
        // Récupérer les sites de compétition réels
        $competitionSites = \App\Models\CompetitionSite::all();
        
        $data = [];
        
        // Si on a des sites de compétition, utiliser leurs données
        if ($competitionSites->isNotEmpty()) {
            foreach ($competitionSites as $site) {
                // Compter les incidents dans un rayon de 5km (approximation)
                $incidents = Incident::selectRaw('*, (
                    6371 * acos(
                        cos(radians(?)) * cos(radians(latitude)) *
                        cos(radians(longitude) - radians(?)) +
                        sin(radians(?)) * sin(radians(latitude))
                    )
                ) AS distance', [$site->latitude, $site->longitude, $site->latitude])
                    ->having('distance', '<', 5)
                    ->count();
                
                // Compter les alertes dans le même rayon
                $alerts = Alert::selectRaw('*, (
                    6371 * acos(
                        cos(radians(?)) * cos(radians(latitude)) *
                        cos(radians(longitude) - radians(?)) +
                        sin(radians(?)) * sin(radians(latitude))
                    )
                ) AS distance', [$site->latitude, $site->longitude, $site->latitude])
                    ->having('distance', '<', 5)
                    ->count();
                
                if ($incidents > 0 || $alerts > 0) {
                    $data[] = [
                        'site' => $site->name,
                        'incidents' => $incidents,
                        'alerts' => $alerts,
                        'total' => $incidents + $alerts,
                    ];
                }
            }
        } else {
            // Fallback: utiliser les données réelles groupées par zone
            $incidentsByZone = Incident::selectRaw('address, COUNT(*) as count')
                ->whereNotNull('address')
                ->groupBy('address')
                ->orderByDesc('count')
                ->limit(5)
                ->get();
            
            foreach ($incidentsByZone as $item) {
                $alerts = Alert::where('address', $item->address)->count();
                $data[] = [
                    'site' => $item->address ?? 'Zone inconnue',
                    'incidents' => $item->count,
                    'alerts' => $alerts,
                    'total' => $item->count + $alerts,
                ];
            }
        }

        // Trier par total décroissant
        usort($data, fn($a, $b) => $b['total'] <=> $a['total']);

        return $data;
    }

    private function getAnnouncementsWeekData()
    {
        // Données pour la semaine (7 derniers jours)
        $data = [];
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $data[] = [
                'date' => $date->format('d-m'),
                'audio' => rand(1000, 5000),
                'alerts' => rand(500, 2000),
            ];
        }
        return $data;
    }

    private function getTrafficSourcesData()
    {
        // Données pour les sources de trafic
        $sources = ['Hôtels & restos', 'Compétitions JOJ', 'Transport', 'Autres Services'];
        $data = [];
        
        for ($i = 6; $i >= 0; $i--) {
            $date = now()->subDays($i);
            $dayData = ['date' => $date->format('d-m')];
            foreach ($sources as $source) {
                $dayData[$source] = rand(100, 5000);
            }
            $data[] = $dayData;
        }
        
        return [
            'sources' => $sources,
            'data' => $data,
        ];
    }

    private function calculatePercentageChange($current, $previous)
    {
        if ($previous == 0) {
            return $current > 0 ? 100 : 0;
        }
        return round((($current - $previous) / $previous) * 100, 1);
    }
}
