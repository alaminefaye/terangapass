<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Models\Incident;
use App\Models\Notification;
use App\Models\AudioAnnouncement;
use App\Models\User;
use App\Models\Partner;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    public function index(Request $request)
    {
        // Période par défaut : 30 derniers jours
        $period = $request->get('period', '30');
        $startDate = now()->subDays($period);
        $endDate = now();

        // Statistiques globales
        $stats = [
            'total_users' => User::count(),
            'active_users' => User::where('last_active_at', '>=', $startDate)->count(),
            'total_alerts' => Alert::count(),
            'sos_alerts' => Alert::where('type', 'sos')->count(),
            'medical_alerts' => Alert::where('type', 'medical')->count(),
            'total_incidents' => Incident::count(),
            'total_notifications' => Notification::count(),
            'total_audio_announcements' => AudioAnnouncement::count(),
            'total_partners' => Partner::count(),
        ];

        // Alertes par jour (30 derniers jours)
        $alertsByDay = Alert::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->mapWithKeys(function ($item) {
                return [$item->date => $item->count];
            });

        // Signalements par jour
        $incidentsByDay = Incident::selectRaw('DATE(created_at) as date, COUNT(*) as count')
            ->whereBetween('created_at', [$startDate, $endDate])
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->mapWithKeys(function ($item) {
                return [$item->date => $item->count];
            });

        // Alertes par type
        $alertsByType = Alert::selectRaw('type, COUNT(*) as count')
            ->groupBy('type')
            ->get()
            ->pluck('count', 'type');

        // Signalements par type
        $incidentsByType = Incident::selectRaw('type, COUNT(*) as count')
            ->groupBy('type')
            ->get()
            ->pluck('count', 'type');

        // Utilisateurs par pays
        $usersByCountry = User::select('country', DB::raw('count(*) as count'))
            ->whereNotNull('country')
            ->groupBy('country')
            ->orderByDesc('count')
            ->limit(10)
            ->get();

        // Partenaires par catégorie
        $partnersByCategory = Partner::select('category', DB::raw('count(*) as count'))
            ->groupBy('category')
            ->get()
            ->pluck('count', 'category');

        return view('statistics.index', compact(
            'stats',
            'alertsByDay',
            'incidentsByDay',
            'alertsByType',
            'incidentsByType',
            'usersByCountry',
            'partnersByCategory',
            'period'
        ));
    }
}
