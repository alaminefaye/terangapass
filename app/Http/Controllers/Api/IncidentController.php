<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class IncidentController extends Controller
{
    public function report(Request $request)
    {
        $request->validate([
            'incident_type' => 'required|in:perte,accident,suspect',
            'description' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:5120', // 5MB max
            'audio' => 'nullable|file|mimes:mp3,wav,m4a,aac|max:10240', // 10MB max
            'audio_url' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        
        // Gérer l'upload des photos
        $photoUrls = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photo) {
                $filename = Str::uuid() . '.' . $photo->getClientOriginalExtension();
                $path = $photo->storeAs('incidents/photos', $filename, 'public');
                $photoUrls[] = Storage::url($path);
            }
        } elseif ($request->has('photos') && is_array($request->photos)) {
            // Si les photos sont déjà des URLs (depuis l'app mobile)
            $photoUrls = $request->photos;
        }
        
        // Gérer l'upload de l'audio
        $audioUrl = $request->audio_url;
        if ($request->hasFile('audio')) {
            $audio = $request->file('audio');
            $filename = Str::uuid() . '.' . $audio->getClientOriginalExtension();
            $path = $audio->storeAs('incidents/audio', $filename, 'public');
            $audioUrl = Storage::url($path);
        }
        
        $incident = Incident::create([
            'user_id' => $user ? $user->id : 1,
            'type' => $request->incident_type,
            'description' => $request->description,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'photos' => !empty($photoUrls) ? $photoUrls : null,
            'audio_url' => $audioUrl,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Incident reported successfully',
            'data' => $incident,
        ], 201);
    }

    public function history(Request $request)
    {
        $user = $this->getUserFromToken($request);
        $incidents = Incident::where('user_id', $user ? $user->id : 1)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['data' => $incidents]);
    }

    private function getUserFromToken(Request $request)
    {
        $token = $request->bearerToken() ?? $request->header('Authorization');
        if ($token) {
            $token = str_replace('Bearer ', '', $token);
            $decoded = base64_decode($token);
            $parts = explode('|', $decoded);
            if (count($parts) >= 3) {
                return User::find($parts[0]);
            }
        }
        return null;
    }
}
