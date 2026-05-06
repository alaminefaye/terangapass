<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $this->getUserFromToken($request);
        return response()->json(['data' => $user ?? ['name' => 'Utilisateur', 'email' => 'user@example.com']]);
    }

    public function updateProfile(Request $request)
    {
        $user = $this->getUserFromToken($request);
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Non autorisé. Veuillez vous reconnecter.',
            ], 401);
        }

        $rawPhone = $request->input('phone') ?? $request->input('telephone');
        $phone = $rawPhone === null ? null : preg_replace('/[^\d\+]/', '', trim((string) $rawPhone));
        $request->merge(['phone' => $phone]);

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => [
                'sometimes',
                'nullable',
                'string',
                'max:30',
                Rule::unique('users', 'phone')->ignore($user->id),
            ],
            'language' => 'sometimes|in:fr,en,es',
            'user_type' => 'sometimes|in:athlete,visitor,citizen',
        ], [
            'phone.unique' => 'Ce numéro de téléphone est déjà utilisé.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Les données fournies sont invalides.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user->update($request->only(['name', 'phone', 'language', 'user_type']));

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
