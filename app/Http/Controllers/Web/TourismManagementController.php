<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Partner;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class TourismManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = Partner::query();

        // Filtrer uniquement les catégories de tourisme
        $tourismCategories = ['hotel', 'restaurant', 'pharmacy', 'hospital', 'embassy', 'consulate'];
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
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'rating' => 'nullable|numeric|min:0|max:5',
            'opening_hours' => 'nullable|string|max:255',
            'logo_url' => 'nullable|url',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('icon')) {
            $validated['icon_path'] = $this->storeImageUrl($request->file('icon'), 'partners/icons');
        }

        $photoUrls = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $photoUrls[] = $this->storeImageUrl($photo, 'partners/photos');
            }
        }
        if (!empty($photoUrls)) {
            $validated['photos'] = $photoUrls;
        }

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
            'category' => 'required|in:hotel,restaurant,pharmacy,hospital,embassy,consulate,bank,gas_station,shop,notary,lawyer,doctor,clinic,government,school,university,media,professional_service,religious_site,other',
            'description' => 'nullable|string',
            'address' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'phone' => 'nullable|string',
            'email' => 'nullable|email',
            'website' => 'nullable|url',
            'rating' => 'nullable|numeric|min:0|max:5',
            'opening_hours' => 'nullable|string|max:255',
            'logo_url' => 'nullable|url',
            'icon' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'remove_icon' => 'nullable|boolean',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'remove_photos' => 'nullable|array',
            'remove_photos.*' => 'nullable|string',
            'is_active' => 'boolean',
        ]);

        if ($request->boolean('remove_icon') && !$request->hasFile('icon')) {
            $this->deleteStorageUrl($tourism->icon_path);
            $validated['icon_path'] = null;
        }

        if ($request->hasFile('icon')) {
            $this->deleteStorageUrl($tourism->icon_path);
            $validated['icon_path'] = $this->storeImageUrl($request->file('icon'), 'partners/icons');
        }

        $existingPhotos = is_array($tourism->photos) ? $tourism->photos : [];
        $photosToRemove = $request->input('remove_photos', []);
        if (is_array($photosToRemove) && !empty($photosToRemove)) {
            $existingPhotos = array_values(array_filter(
                $existingPhotos,
                function ($url) use ($photosToRemove) {
                    return !in_array($url, $photosToRemove, true);
                }
            ));

            foreach ($photosToRemove as $url) {
                $this->deleteStorageUrl($url);
            }
        }

        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $existingPhotos[] = $this->storeImageUrl($photo, 'partners/photos');
            }
        }

        $validated['photos'] = empty($existingPhotos) ? null : array_values($existingPhotos);

        $tourism->update($validated);

        return redirect()->route('admin.tourism.index')
            ->with('success', 'Point d\'intérêt mis à jour avec succès.');
    }

    public function destroy(Partner $tourism)
    {
        $this->deleteStorageUrl($tourism->icon_path);
        $photos = is_array($tourism->photos) ? $tourism->photos : [];
        foreach ($photos as $url) {
            $this->deleteStorageUrl($url);
        }

        $tourism->delete();
        return redirect()->route('admin.tourism.index')
            ->with('success', 'Point d\'intérêt supprimé avec succès.');
    }

    private function storeImageUrl($file, string $directory): string
    {
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs($directory, $filename, 'public');
        $publicUrl = Storage::url($path);
        $appUrl = config('app.url');
        $useHttps = is_string($appUrl) && str_starts_with($appUrl, 'https://');
        return ($useHttps || request()->isSecure()) ? secure_url($publicUrl) : url($publicUrl);
    }

    private function deleteStorageUrl(?string $url): void
    {
        if (!$url) {
            return;
        }

        $path = parse_url($url, PHP_URL_PATH);
        if (!$path || !str_contains($path, '/storage/')) {
            return;
        }

        $relative = ltrim(str_replace('/storage/', '', $path), '/');
        if ($relative === '') {
            return;
        }

        Storage::disk('public')->delete($relative);
    }
}
