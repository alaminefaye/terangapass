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
            ->get();

        return response()->json(['data' => $announcements]);
    }
}
