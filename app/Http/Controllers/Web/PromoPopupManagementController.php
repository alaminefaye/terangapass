<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\PromoPopup;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PromoPopupManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = PromoPopup::query();

        if ($request->filled('placement')) {
            $query->where('placement', $request->placement);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        $popups = $query->orderByDesc('priority')->orderByDesc('id')->paginate(20);

        return view('promo-popups.index', compact('popups'));
    }

    public function create()
    {
        return view('promo-popups.create');
    }

    public function store(Request $request)
    {
        $validated = $this->validatePopup($request, requireImage: true);

        if ($request->hasFile('image')) {
            $validated['image_path'] = $request->file('image')->store('promo-popups', 'public');
        }

        $validated['is_active'] = $request->boolean('is_active');

        PromoPopup::create($validated);

        return redirect()
            ->route('admin.promo-popups.index')
            ->with('success', 'Pop-up publicitaire créé.');
    }

    public function edit(PromoPopup $promoPopup)
    {
        return view('promo-popups.edit', compact('promoPopup'));
    }

    public function update(Request $request, PromoPopup $promoPopup)
    {
        $validated = $this->validatePopup($request, requireImage: false);

        if ($request->hasFile('image')) {
            if ($promoPopup->image_path && ! str_starts_with($promoPopup->image_path, 'http')) {
                Storage::disk('public')->delete($promoPopup->image_path);
            }
            $validated['image_path'] = $request->file('image')->store('promo-popups', 'public');
        }

        $validated['is_active'] = $request->boolean('is_active');

        $promoPopup->update($validated);

        return redirect()
            ->route('admin.promo-popups.index')
            ->with('success', 'Pop-up mis à jour.');
    }

    public function destroy(PromoPopup $promoPopup)
    {
        if ($promoPopup->image_path && ! str_starts_with($promoPopup->image_path, 'http')) {
            Storage::disk('public')->delete($promoPopup->image_path);
        }

        $promoPopup->delete();

        return redirect()
            ->route('admin.promo-popups.index')
            ->with('success', 'Pop-up supprimé.');
    }

    /**
     * @return array<string, mixed>
     */
    private function validatePopup(Request $request, bool $requireImage): array
    {
        return $request->validate([
            'title' => 'required|string|max:255',
            'sponsor_name' => 'nullable|string|max:255',
            'image' => ($requireImage ? 'required' : 'nullable').'|image|mimes:jpeg,jpg,png,webp|max:5120',
            'link_url' => 'nullable|url|max:500',
            'link_label' => 'nullable|string|max:80',
            'placement' => 'required|in:home,map,tourism,all',
            'priority' => 'nullable|integer|min:0|max:9999',
            'starts_at' => 'nullable|date',
            'ends_at' => 'nullable|date|after_or_equal:starts_at',
            'frequency' => 'required|in:once_per_day,every_open,always',
            'is_active' => 'boolean',
        ]);
    }
}
