<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PromoPopup;
use Illuminate\Http\Request;

class PromoPopupController extends Controller
{
    /**
     * Pop-up publicitaire actif pour un écran (accueil, carte, tourisme).
     */
    public function active(Request $request)
    {
        $validated = $request->validate([
            'placement' => 'sometimes|string|in:home,map,tourism,all',
        ]);

        $placement = $validated['placement'] ?? 'home';

        $popup = PromoPopup::query()
            ->active()
            ->forPlacement($placement)
            ->orderByDesc('priority')
            ->orderByDesc('id')
            ->first();

        if ($popup === null) {
            return response()->json(['data' => null]);
        }

        return response()->json([
            'data' => $this->formatPopup($popup),
        ]);
    }

    public function recordImpression(int $id)
    {
        $popup = PromoPopup::query()->findOrFail($id);
        $popup->increment('impression_count');

        return response()->json(['success' => true]);
    }

    public function recordClick(int $id)
    {
        $popup = PromoPopup::query()->findOrFail($id);
        $popup->increment('click_count');

        return response()->json(['success' => true]);
    }

    private function formatPopup(PromoPopup $popup): array
    {
        return [
            'id' => $popup->id,
            'title' => $popup->title,
            'sponsor_name' => $popup->sponsor_name,
            'image_url' => $this->normalizeUrl($popup->imageUrl()),
            'link_url' => $popup->link_url,
            'link_label' => $popup->link_label,
            'placement' => $popup->placement,
            'frequency' => $popup->frequency,
        ];
    }

    private function normalizeUrl(?string $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        $appUrl = config('app.url');
        $useHttps = is_string($appUrl) && str_starts_with($appUrl, 'https://');

        if (str_starts_with($value, 'http://')) {
            return ($useHttps || request()->isSecure())
                ? preg_replace('/^http:\\/\\//', 'https://', $value)
                : $value;
        }

        if (str_starts_with($value, 'https://')) {
            return $value;
        }

        return ($useHttps || request()->isSecure()) ? secure_url($value) : url($value);
    }
}
