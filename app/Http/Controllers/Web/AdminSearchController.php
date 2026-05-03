<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Models\CompetitionSite;
use App\Models\Incident;
use App\Models\Partner;
use App\Models\User;
use Illuminate\Http\Request;

class AdminSearchController extends Controller
{
    /**
     * Recherche transversale (signalements, alertes, partenaires, utilisateurs app, sites JOJ).
     */
    public function index(Request $request)
    {
        $validated = $request->validate([
            'q' => 'nullable|string|max:200',
        ]);

        $q = trim((string) ($validated['q'] ?? ''));

        if ($q === '') {
            return view('search.index', [
                'q' => '',
                'incidents' => collect(),
                'alerts' => collect(),
                'partners' => collect(),
                'users' => collect(),
                'sites' => collect(),
            ]);
        }

        $term = '%'.$q.'%';

        $incidents = Incident::query()
            ->where(function ($query) use ($term) {
                $query->where('description', 'like', $term)
                    ->orWhere('address', 'like', $term)
                    ->orWhere('type', 'like', $term);
            })
            ->orderByDesc('created_at')
            ->limit(12)
            ->get();

        $alerts = Alert::query()
            ->where(function ($query) use ($term) {
                $query->where('address', 'like', $term)
                    ->orWhere('notes', 'like', $term)
                    ->orWhere('type', 'like', $term)
                    ->orWhere('emergency_type', 'like', $term);
            })
            ->orderByDesc('created_at')
            ->limit(12)
            ->get();

        $partners = Partner::query()
            ->where(function ($query) use ($term) {
                $query->where('name', 'like', $term)
                    ->orWhere('address', 'like', $term)
                    ->orWhere('description', 'like', $term);
            })
            ->orderBy('name')
            ->limit(12)
            ->get();

        $users = User::query()
            ->where(function ($query) use ($term) {
                $query->where('name', 'like', $term)
                    ->orWhere('email', 'like', $term)
                    ->orWhere('phone', 'like', $term);
            })
            ->orderByDesc('created_at')
            ->limit(12)
            ->get();

        $sites = CompetitionSite::query()
            ->where(function ($query) use ($term) {
                $query->where('name', 'like', $term)
                    ->orWhere('location', 'like', $term)
                    ->orWhere('address', 'like', $term)
                    ->orWhere('description', 'like', $term);
            })
            ->orderBy('name')
            ->limit(12)
            ->get();

        return view('search.index', compact(
            'q',
            'incidents',
            'alerts',
            'partners',
            'users',
            'sites'
        ));
    }
}
