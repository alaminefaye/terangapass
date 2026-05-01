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
            'incident_type' => 'required|in:perte,accident,suspect,autre',
            'description' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
            'photos' => 'nullable|array',
            'photos.*' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:5120', // 5MB max
            'videos' => 'nullable|array',
            'videos.*' => 'nullable|file|mimetypes:video/*|mimes:mp4,mov,mkv,avi,webm,3gp,m4v|max:51200', // 50MB max
            'audio' => 'nullable|file|max:10240', // 10MB max, accept all audio formats (Android may send video/mp4 MIME for m4a)
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

        // Gérer l'upload des vidéos
        $videoUrls = [];
        if ($request->hasFile('videos')) {
            foreach ($request->file('videos') as $video) {
                $extension = $video->getClientOriginalExtension() ?: 'mp4';
                $filename = Str::uuid() . '.' . $extension;
                $path = $video->storeAs('incidents/videos', $filename, 'public');
                $videoUrls[] = Storage::url($path);
            }
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
            'video_urls' => !empty($videoUrls) ? $videoUrls : null,
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

    public function tracking(Request $request, int $id)
    {
        $user = $this->getUserFromToken($request);
        $incident = Incident::query()
            ->where('id', $id)
            ->where('user_id', $user ? $user->id : 1)
            ->firstOrFail();

        $timeline = [
            [
                'key' => 'reported',
                'label' => 'Signalement envoye',
                'completed' => true,
                'at' => optional($incident->created_at)?->toIso8601String(),
            ],
            [
                'key' => 'review',
                'label' => 'En cours de traitement',
                'completed' => in_array($incident->status, ['in_progress', 'resolved', 'closed'], true),
                'at' => in_array($incident->status, ['in_progress', 'resolved', 'closed'], true)
                    ? optional($incident->updated_at)?->toIso8601String()
                    : null,
            ],
            [
                'key' => 'resolved',
                'label' => 'Traite',
                'completed' => in_array($incident->status, ['resolved', 'closed'], true),
                'at' => $incident->resolved_at?->toIso8601String(),
            ],
        ];

        return response()->json([
            'data' => [
                'id' => $incident->id,
                'type' => $incident->type,
                'status' => $incident->status,
                'description' => $incident->description,
                'address' => $incident->address,
                'created_at' => optional($incident->created_at)?->toIso8601String(),
                'updated_at' => optional($incident->updated_at)?->toIso8601String(),
                'timeline' => $timeline,
            ],
        ]);
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
