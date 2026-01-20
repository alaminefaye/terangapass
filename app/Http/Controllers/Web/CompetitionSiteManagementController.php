<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\CompetitionSite;
use Illuminate\Http\Request;

class CompetitionSiteManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = CompetitionSite::query();

        if ($request->filled('location')) {
            $query->where('location', $request->location);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('address', 'like', "%{$search}%");
            });
        }

        $sites = $query->orderBy('name')->paginate(20);

        return view('competition-sites.index', compact('sites'));
    }

    public function create()
    {
        return view('competition-sites.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'address' => 'nullable|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'sports' => 'nullable|array',
            'access_info' => 'nullable|string',
            'facilities' => 'nullable|array',
            'capacity' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        // Si sports_input est fourni, le convertir en array
        if ($request->filled('sports_input')) {
            $sports = explode(',', $request->sports_input);
            $validated['sports'] = array_map('trim', $sports);
        }

        CompetitionSite::create($validated);

        return redirect()->route('admin.competition-sites.index')
            ->with('success', 'Site de compétition créé avec succès.');
    }

    public function show(CompetitionSite $competitionSite)
    {
        return view('competition-sites.show', compact('competitionSite'));
    }

    public function edit(CompetitionSite $competitionSite)
    {
        return view('competition-sites.edit', compact('competitionSite'));
    }

    public function update(Request $request, CompetitionSite $competitionSite)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'address' => 'nullable|string',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'sports' => 'nullable|array',
            'access_info' => 'nullable|string',
            'facilities' => 'nullable|array',
            'capacity' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        // Si sports_input est fourni, le convertir en array
        if ($request->filled('sports_input')) {
            $sports = explode(',', $request->sports_input);
            $validated['sports'] = array_map('trim', $sports);
        }

        $competitionSite->update($validated);

        return redirect()->route('admin.competition-sites.index')
            ->with('success', 'Site de compétition mis à jour avec succès.');
    }

    public function destroy(CompetitionSite $competitionSite)
    {
        $competitionSite->delete();
        return redirect()->route('admin.competition-sites.index')
            ->with('success', 'Site de compétition supprimé avec succès.');
    }
}
