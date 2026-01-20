<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;

class PartnerManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Partner::query();

        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        if ($request->filled('is_sponsor')) {
            $query->where('is_sponsor', $request->is_sponsor);
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

        $partners = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('partners.index', compact('partners'));
    }

    public function create()
    {
        return view('partners.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy,other',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'logo_url' => 'nullable|url',
            'is_sponsor' => 'boolean',
            'is_active' => 'boolean',
        ]);

        Partner::create($validated);

        return redirect()->route('admin.partners.index')
            ->with('success', 'Partenaire créé avec succès.');
    }

    public function show(Partner $partner)
    {
        return view('partners.show', compact('partner'));
    }

    public function edit(Partner $partner)
    {
        return view('partners.edit', compact('partner'));
    }

    public function update(Request $request, Partner $partner)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy,other',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'logo_url' => 'nullable|url',
            'is_sponsor' => 'boolean',
            'is_active' => 'boolean',
        ]);

        $partner->update($validated);

        return redirect()->route('admin.partners.index')
            ->with('success', 'Partenaire mis à jour avec succès.');
    }

    public function destroy(Partner $partner)
    {
        $partner->delete();
        return redirect()->route('admin.partners.index')
            ->with('success', 'Partenaire supprimé avec succès.');
    }
}
