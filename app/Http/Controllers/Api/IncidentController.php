<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Incident;
use App\Models\User;
use Illuminate\Http\Request;

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
            'audio_url' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        
        $incident = Incident::create([
            'user_id' => $user ? $user->id : 1,
            'type' => $request->incident_type,
            'description' => $request->description,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'photos' => $request->photos,
            'audio_url' => $request->audio_url,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Incident reported successfully',
            'incident' => $incident,
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
