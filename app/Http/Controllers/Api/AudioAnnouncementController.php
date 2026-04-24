<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AudioAnnouncement;
use Illuminate\Http\Request;

class AudioAnnouncementController extends Controller
{
    public function index(Request $request)
    {
        $announcements = AudioAnnouncement::where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($announcement) {
                // Normaliser audio_url en URL absolue si c'est un chemin relatif
                if ($announcement->audio_url && !str_starts_with($announcement->audio_url, 'http')) {
                    $announcement->audio_url = url($announcement->audio_url);
                }
                return $announcement;
            });

        return response()->json(['data' => $announcements]);
    }
}
