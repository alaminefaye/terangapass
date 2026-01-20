<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Shuttle;
use Illuminate\Http\Request;

class TransportManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Shuttle::with(['stops', 'schedules']);

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('start_location', 'like', "%{$search}%");
            });
        }

        $shuttles = $query->orderBy('name')->paginate(20);

        return view('transport.index', compact('shuttles'));
    }

    public function create()
    {
        return view('transport.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:regular,express',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'start_location' => 'required|string',
            'end_location' => 'nullable|string',
            'start_latitude' => 'nullable|numeric',
            'start_longitude' => 'nullable|numeric',
            'end_latitude' => 'nullable|numeric',
            'end_longitude' => 'nullable|numeric',
            'frequency_minutes' => 'nullable|integer',
            'first_departure' => 'nullable|date_format:H:i',
            'last_departure' => 'nullable|date_format:H:i',
            'operating_days' => 'nullable|array',
            'is_secure_route' => 'boolean',
            'is_active' => 'boolean',
        ]);

        Shuttle::create($validated);

        return redirect()->route('admin.transport.index')
            ->with('success', 'Navette créée avec succès.');
    }

    public function show(Shuttle $shuttle)
    {
        $shuttle->load(['stops', 'schedules']);
        return view('transport.show', compact('shuttle'));
    }

    public function edit(Shuttle $shuttle)
    {
        return view('transport.edit', compact('shuttle'));
    }

    public function update(Request $request, Shuttle $shuttle)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'type' => 'required|in:regular,express',
            'start_date' => 'required|date',
            'end_date' => 'required|date|after_or_equal:start_date',
            'start_location' => 'required|string',
            'end_location' => 'nullable|string',
            'start_latitude' => 'nullable|numeric',
            'start_longitude' => 'nullable|numeric',
            'end_latitude' => 'nullable|numeric',
            'end_longitude' => 'nullable|numeric',
            'frequency_minutes' => 'nullable|integer',
            'first_departure' => 'nullable|date_format:H:i',
            'last_departure' => 'nullable|date_format:H:i',
            'operating_days' => 'nullable|array',
            'is_secure_route' => 'boolean',
            'is_active' => 'boolean',
        ]);

        $shuttle->update($validated);

        return redirect()->route('admin.transport.index')
            ->with('success', 'Navette mise à jour avec succès.');
    }

    public function destroy(Shuttle $shuttle)
    {
        $shuttle->delete();
        return redirect()->route('admin.transport.index')
            ->with('success', 'Navette supprimée avec succès.');
    }
}
