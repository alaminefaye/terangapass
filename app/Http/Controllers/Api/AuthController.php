<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Les données fournies sont invalides.',
                'errors' => $validator->errors(),
            ], 422);
        }

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'user_type' => $request->user_type ?? 'visitor',
                'country' => $request->country ?? 'SN',
                'language' => $request->language ?? 'fr',
            ]);

            // Token simple (à remplacer par Sanctum plus tard)
            $token = base64_encode($user->id . '|' . now()->timestamp . '|' . $user->email);

            return response()->json([
                'success' => true,
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'user_type' => $user->user_type,
                    'language' => $user->language,
                    'country' => $user->country,
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de la création du compte.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur serveur',
            ], 500);
        }
    }

    public function login(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Les données fournies sont invalides.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Les identifiants fournis ne correspondent pas à nos enregistrements.',
                'errors' => [
                    'email' => ['The provided credentials are incorrect.'],
                ],
            ], 401);
        }

        // Token simple (à remplacer par Sanctum plus tard)
        $token = base64_encode($user->id . '|' . now()->timestamp . '|' . $user->email);

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'user_type' => $user->user_type,
                'language' => $user->language,
                'country' => $user->country,
            ],
        ], 200);
    }

    public function logout(Request $request)
    {
        // Pour l'instant, juste retourner un message
        return response()->json([
            'success' => true,
            'message' => 'Déconnexion réussie.',
        ], 200);
    }
}
