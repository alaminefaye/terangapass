<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use App\Services\GooglePlacesService;
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

        if ($request->filled('is_recommended')) {
            $query->where('is_recommended', $request->is_recommended);
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
        $validated = $this->validatePartner($request);

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
        $validated = $this->validatePartner($request);

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

    /**
     * @return array<string, mixed>
     */
    private function validatePartner(Request $request): array
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string|max:80',
            'email' => 'nullable|email|max:255',
            'website' => 'nullable|string|max:500',
            'rating' => 'nullable|numeric|min:0|max:5',
            'opening_hours' => 'nullable|string|max:10000',
            'logo_url' => 'nullable|string|max:65535',
            'is_sponsor' => 'boolean',
            'is_recommended' => 'boolean',
            'recommendation_priority' => 'nullable|integer|min:0|max:9999',
            'recommendation_pitch' => 'nullable|string|max:200',
            'is_active' => 'boolean',
        ]);

        $validated['is_sponsor'] = $request->boolean('is_sponsor');
        $validated['is_recommended'] = $request->boolean('is_recommended');
        $validated['is_active'] = $request->boolean('is_active');
        $validated['recommendation_priority'] = (int) ($validated['recommendation_priority'] ?? 0);

        $logo = trim((string) ($validated['logo_url'] ?? ''));
        $validated['logo_url'] = $logo === '' ? null : $logo;

        $website = trim((string) ($validated['website'] ?? ''));
        if ($website !== '' && ! str_starts_with($website, 'http://') && ! str_starts_with($website, 'https://')) {
            $website = 'https://'.$website;
        }
        $validated['website'] = $website === '' ? null : $website;

        if ($validated['logo_url'] !== null && ! $this->isAllowedLogoValue($validated['logo_url'])) {
            validator(['logo_url' => $validated['logo_url']], [
                'logo_url' => function (string $attribute, mixed $value, \Closure $fail): void {
                    $fail('URL du logo invalide (utilisez une adresse https://… ou laissez la référence Google importée).');
                },
            ])->validate();
        }

        return $validated;
    }

    private function isAllowedLogoValue(string $value): bool
    {
        if (str_starts_with($value, GooglePlacesService::PHOTO_REF_PREFIX)) {
            return true;
        }
        if (str_starts_with($value, '/') || str_starts_with($value, 'storage/')) {
            return true;
        }

        return filter_var($value, FILTER_VALIDATE_URL) !== false;
    }
}
