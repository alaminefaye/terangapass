<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Services\PushNotificationService;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    public function sendSOS(Request $request, PushNotificationService $push)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $alert = Alert::create([
            'user_id' => $user->id,
            'type' => 'sos',
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'status' => 'pending',
        ]);

        $alert->load('user');
        try {
            $push->notifyNewAlertCreated($alert);
        } catch (\Throwable $e) {
            // Ne pas faire échouer l’enregistrement SOS si la push échoue
            report($e);
        }

        return response()->json([
            'message' => 'SOS alert sent successfully',
            'alert' => $alert,
        ], 201);
    }

    public function sendMedical(Request $request, PushNotificationService $push)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'emergency_type' => 'required|string',
            'accuracy' => 'nullable|numeric',
            'address' => 'nullable|string',
        ]);

        $user = $this->getUserFromToken($request);
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $alert = Alert::create([
            'user_id' => $user->id,
            'type' => 'medical',
            'emergency_type' => $request->emergency_type,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'accuracy' => $request->accuracy,
            'address' => $request->address,
            'status' => 'pending',
        ]);

        $alert->load('user');
        try {
            $push->notifyNewAlertCreated($alert);
        } catch (\Throwable $e) {
            report($e);
        }

        return response()->json([
            'message' => 'Medical alert sent successfully',
            'alert' => $alert,
        ], 201);
    }

    public function history(Request $request)
    {
        $user = $this->getUserFromToken($request);
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }
        $alerts = Alert::where('user_id', $user->id)
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
