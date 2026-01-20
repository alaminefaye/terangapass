<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;

class AlertManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Alert::with('user');

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

        $alerts = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('alerts.index', compact('alerts'));
    }

    public function show(Alert $alert)
    {
        $alert->load('user');
        return view('alerts.show', compact('alert'));
    }

    public function updateStatus(Request $request, Alert $alert)
    {
        $validated = $request->validate([
            'status' => 'required|in:pending,in_progress,resolved,cancelled',
            'notes' => 'nullable|string',
        ]);

        if ($request->status === 'resolved') {
            $validated['resolved_at'] = now();
        }

        $alert->update($validated);

        return redirect()->back()
            ->with('success', 'Statut de l\'alerte mis à jour.');
    }

    public function assign(Request $request, Alert $alert)
    {
        $validated = $request->validate([
            'assigned_to' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $alert->update([
            'notes' => ($alert->notes ? $alert->notes . "\n" : '') . "Assigné à: {$validated['assigned_to']}\n" . ($validated['notes'] ?? ''),
            'status' => 'in_progress',
        ]);

        return redirect()->back()
            ->with('success', 'Alerte assignée avec succès.');
    }
}
