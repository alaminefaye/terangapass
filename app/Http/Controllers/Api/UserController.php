<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $this->getUserFromToken($request);
        return response()->json(['data' => $user ?? ['name' => 'Utilisateur', 'email' => 'user@example.com']]);
    }

    public function updateProfile(Request $request)
    {
        $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|nullable|string',
            'language' => 'sometimes|in:fr,en,es',
            'user_type' => 'sometimes|in:athlete,visitor,citizen',
        ]);

        $user = $this->getUserFromToken($request);
        if ($user) {
            $user->update($request->only(['name', 'phone', 'language', 'user_type']));
        }

        return response()->json(['data' => $user]);
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
