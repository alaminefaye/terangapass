<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\PhoneNormalizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $this->getUserFromToken($request);
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Non autorisé. Veuillez vous reconnecter.',
            ], 401);
        }
        if ($user->isBlockedAccount()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte est suspendu.',
            ], 403);
        }

        return response()->json(['data' => $user]);
    }

    public function updateProfile(Request $request)
    {
        $user = $this->getUserFromToken($request);
        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Non autorisé. Veuillez vous reconnecter.',
            ], 401);
        }
        if ($user->isBlockedAccount()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte est suspendu.',
            ], 403);
        }

        $rawPhone = $request->input('phone') ?? $request->input('telephone');
        $country = trim((string) $request->input('country', $user->country ?? 'SN'));
        $country = strtoupper($country === '' ? 'SN' : $country);
        $phone = PhoneNormalizer::normalize(
            $rawPhone === null ? null : (string) $rawPhone,
            $country,
        );
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
            'language' => 'sometimes|in:fr,en,es,pt',
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
