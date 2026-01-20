<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    /**
     * Enregistrer ou mettre à jour un token de device
     */
    public function register(Request $request)
    {
        $validated = $request->validate([
            'token' => 'required|string',
            'platform' => 'nullable|in:Android,iOS,android,ios,Web,web', // Format flexible pour compatibilité
        ]);

        $user = $this->getUserFromToken($request);
        
        // Si pas d'authentification, créer un token anonyme (optionnel)
        // Pour l'instant, on retourne une erreur si pas d'utilisateur
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        // Chercher si le token existe déjà
        $deviceToken = DeviceToken::where('token', $validated['token'])->first();

        // Normaliser la plateforme (android ou ios selon la migration)
        $platform = strtolower($validated['platform'] ?? 'android');
        if ($platform === 'web' || !in_array($platform, ['android', 'ios'])) {
            $platform = 'android'; // Fallback
        }

        if ($deviceToken) {
            // Mettre à jour le token existant
            $deviceToken->update([
                'user_id' => $user->id,
                'platform' => $platform,
                'is_active' => true,
                'last_used_at' => now(),
            ]);
        } else {
            // Créer un nouveau token
            $deviceToken = DeviceToken::create([
                'user_id' => $user->id,
                'token' => $validated['token'],
                'platform' => $platform,
                'is_active' => true,
                'last_used_at' => now(),
            ]);
        }

        return response()->json([
            'message' => 'Device token registered successfully',
            'device_token' => $deviceToken,
        ], 201);
    }

    /**
     * Supprimer un token (déconnexion de l'app)
     */
    public function unregister(Request $request)
    {
        $validated = $request->validate([
            'token' => 'required|string',
        ]);

        DeviceToken::where('token', $validated['token'])
            ->update(['is_active' => false]);

        return response()->json(['message' => 'Device token unregistered successfully']);
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
                    return User::find($parts[0]);
                }
            } catch (\Exception $e) {
                // Token invalide
                return null;
            }
        }
        return null;
    }
}
