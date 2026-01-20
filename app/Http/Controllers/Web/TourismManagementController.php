<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;

class TourismManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Partner::query();

        // Filtrer uniquement les catégories de tourisme
        $tourismCategories = ['hotel', 'restaurant', 'pharmacy', 'hospital', 'embassy'];
        $query->whereIn('category', $tourismCategories);

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('address', 'like', "%{$search}%");
            });
        }

        $pointsOfInterest = $query->orderBy('name')->paginate(20);

        return view('tourism.index', compact('pointsOfInterest'));
    }

    public function create()
    {
        return view('tourism.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'logo_url' => 'nullable|url',
            'is_active' => 'boolean',
        ]);

        Partner::create($validated);

        return redirect()->route('admin.tourism.index')
            ->with('success', 'Point d\'intérêt créé avec succès.');
    }

    public function show(Partner $tourism)
    {
        return view('tourism.show', compact('tourism'));
    }

    public function edit(Partner $tourism)
    {
        return view('tourism.edit', compact('tourism'));
    }

    public function update(Request $request, Partner $tourism)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'logo_url' => 'nullable|url',
            'is_active' => 'boolean',
        ]);

        $tourism->update($validated);

        return redirect()->route('admin.tourism.index')
            ->with('success', 'Point d\'intérêt mis à jour avec succès.');
    }

    public function destroy(Partner $tourism)
    {
        $tourism->delete();
        return redirect()->route('admin.tourism.index')
            ->with('success', 'Point d\'intérêt supprimé avec succès.');
    }
}
