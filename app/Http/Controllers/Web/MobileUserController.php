<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Alert;
use App\Models\Incident;
use Illuminate\Http\Request;

class MobileUserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::query();

        if ($request->filled('country')) {
            $query->where('country', $request->country);
        }

        if ($request->filled('user_type')) {
            $query->where('user_type', $request->user_type);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $users = $query->withCount(['alerts', 'incidents'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        // Statistiques par pays
        $usersByCountry = User::select('country')
            ->selectRaw('count(*) as count')
            ->groupBy('country')
            ->orderByDesc('count')
            ->get();

        return view('mobile-users.index', compact('users', 'usersByCountry'));
    }

    public function show(User $user)
    {
        $user->load(['alerts' => function($query) {
            $query->latest()->limit(10);
        }, 'incidents' => function($query) {
            $query->latest()->limit(10);
        }, 'deviceTokens']);

        $stats = [
            'total_alerts' => $user->alerts()->count(),
            'sos_alerts' => $user->alerts()->where('type', 'sos')->count(),
            'medical_alerts' => $user->alerts()->where('type', 'medical')->count(),
            'total_incidents' => $user->incidents()->count(),
            'pending_incidents' => $user->incidents()->where('status', 'pending')->count(),
            'resolved_incidents' => $user->incidents()->where('status', 'resolved')->count(),
        ];

        return view('mobile-users.show', compact('user', 'stats'));
    }

    public function updateStatus(Request $request, User $user)
    {
        $validated = $request->validate([
            'status' => 'required|in:active,inactive',
        ]);

        // Ici on pourrait ajouter un champ status dans la table users
        // Pour l'instant, on peut utiliser un soft delete ou un champ is_active
        if ($validated['status'] === 'inactive') {
            // Désactiver tous les tokens de device
            $user->deviceTokens()->update(['is_active' => false]);
        }

        return redirect()->back()
            ->with('success', 'Statut de l\'utilisateur mis à jour.');
    }
}
