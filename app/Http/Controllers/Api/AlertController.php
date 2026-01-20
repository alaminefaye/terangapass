<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function sendSOS(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        
        $alert = Alert::create([
            'user_id' => $user ? $user->id : 1,
            'type' => 'sos',
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'SOS alert sent successfully',
            'alert' => $alert,
        ], 201);
    }

    public function sendMedical(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'emergency_type' => 'required|string',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        
        $alert = Alert::create([
            'user_id' => $user ? $user->id : 1,
            'type' => 'medical',
            'emergency_type' => $request->emergency_type,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Medical alert sent successfully',
            'alert' => $alert,
        ], 201);
    }

    public function history(Request $request)
    {
        $user = $this->getUserFromToken($request);
        $alerts = Alert::where('user_id', $user ? $user->id : 1)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['data' => $alerts]);
    }

    /**
     * Récupère l'utilisateur depuis le token d'authentification
     */
    private function getUserFromToken(Request $request)
    {
        $token = $request->bearerToken() ?? $request->header('Authorization');
        if ($token) {
            $token = str_replace('Bearer ', '', $token);
            try {
                $decoded = base64_decode($token);
                $parts = explode('|', $decoded);
                if (count($parts) >= 3) {
                    return \App\Models\User::find($parts[0]);
                }
            } catch (\Exception $e) {
                // Token invalide
                return null;
            }
        }
        return null;
    }
}
