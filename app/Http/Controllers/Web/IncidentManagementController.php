<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use Illuminate\Http\Request;

class IncidentManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Incident::with('user');

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('date_from')) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }

        $incidents = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('incidents.index', compact('incidents'));
    }

    public function show(Incident $incident)
    {
        $incident->load('user');
        return view('incidents.show', compact('incident'));
    }

    public function validateIncident(Request $request, Incident $incident)
    {
        $validated = $request->validate([
            'admin_notes' => 'nullable|string',
        ]);

        $incident->update([
            'status' => 'validated',
            'admin_notes' => $validated['admin_notes'] ?? null,
        ]);

        return redirect()->back()
            ->with('success', 'Signalement validé avec succès.');
    }

    public function reject(Request $request, Incident $incident)
    {
        $validated = $request->validate([
            'admin_notes' => 'required|string',
        ]);

        $incident->update([
            'status' => 'rejected',
            'admin_notes' => $validated['admin_notes'],
        ]);

        return redirect()->back()
            ->with('success', 'Signalement rejeté.');
    }

    public function updateStatus(Request $request, Incident $incident)
    {
        $validated = $request->validate([
            'status' => 'required|in:pending,validated,in_progress,resolved,rejected',
            'admin_notes' => 'nullable|string',
        ]);

        if ($request->status === 'resolved') {
            $validated['resolved_at'] = now();
        }

        $incident->update($validated);

        return redirect()->back()
            ->with('success', 'Statut du signalement mis à jour.');
    }
}
