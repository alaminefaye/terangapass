<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\EmailNormalizer;
use App\Support\PhoneNormalizer;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $email = EmailNormalizer::normalize((string) $request->input('email', ''));
        $rawPhone = $request->input('phone') ?? $request->input('telephone');
        $countryRaw = trim((string) $request->input('country', 'SN'));
        $country = strtoupper($countryRaw === '' ? 'SN' : $countryRaw);
        $phone = PhoneNormalizer::normalize(
            $rawPhone === null ? null : (string) $rawPhone,
            $country,
        );

        $request->merge([
            'email' => $email,
            'phone' => $phone,
            'country' => $country,
        ]);

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique('users', 'email'),
            ],
            'password' => 'required|string|min:6',
            'phone' => [
                'required',
                'string',
                'max:30',
                Rule::unique('users', 'phone'),
            ],
            'user_type' => 'sometimes|in:athlete,visitor,citizen',
            'country' => 'sometimes|string|size:2',
            'language' => 'sometimes|in:fr,en,es',
        ], [
            'email.unique' => 'Cet email est déjà utilisé.',
            'phone.unique' => 'Ce numéro de téléphone est déjà utilisé.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Les données fournies sont invalides.',
                'errors' => $validator->errors(),
            ], 422);
        }

        if (User::whereRaw('LOWER(email) = ?', [$email])->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Cet email est déjà utilisé.',
                'errors' => ['email' => ['Cet email est déjà utilisé.']],
            ], 422);
        }

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $email,
                'password' => Hash::make($request->password),
                'phone' => $phone,
                'user_type' => $request->user_type ?? 'visitor',
                'country' => $country,
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
                    'phone' => $user->phone,
                    'user_type' => $user->user_type,
                    'language' => $user->language,
                    'country' => $user->country,
                ],
            ], 201);
        } catch (QueryException $e) {
            $sqlState = $e->errorInfo[0] ?? '';
            if ($sqlState === '23000' || str_contains(strtolower($e->getMessage()), 'duplicate')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cet email ou ce numéro est déjà utilisé.',
                    'errors' => [
                        'email' => ['Cet email est peut-être déjà utilisé.'],
                        'phone' => ['Ce numéro est peut-être déjà utilisé.'],
                    ],
                ], 422);
            }

            return response()->json([
                'success' => false,
                'message' => 'Une erreur est survenue lors de la création du compte.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur serveur',
            ], 500);
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
        $email = EmailNormalizer::normalize((string) $request->input('email', ''));
        $request->merge(['email' => $email]);

        $validator = Validator::make($request->all(), [
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

        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Les identifiants fournis ne correspondent pas à nos enregistrements.',
                'errors' => [
                    'email' => ['The provided credentials are incorrect.'],
                ],
            ], 401);
        }

        if ($user->isBlockedAccount()) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte est suspendu. Contactez le support.',
                'errors' => [
                    'email' => ['Ce compte est suspendu.'],
                ],
            ], 403);
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
