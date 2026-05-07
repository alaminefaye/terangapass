<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PassTicket;
use App\Models\User;
use App\Services\TerangaPassQrSigner;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PassTicketController extends Controller
{
    /**
     * Billet / QR pour l’utilisateur connecté (pilote JOJ sans paiement in-app).
     */
    public function my(Request $request, TerangaPassQrSigner $signer)
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

        $ticket = PassTicket::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->whereNull('revoked_at')
            ->where(function ($q): void {
                $q->whereNull('valid_until')->orWhere('valid_until', '>', now());
            })
            ->orderByDesc('id')
            ->first();

        if ($ticket === null) {
            $hadRevokedPass = PassTicket::query()
                ->where('user_id', $user->id)
                ->where(function ($q): void {
                    $q->where('status', 'revoked')
                        ->orWhereNotNull('revoked_at');
                })
                ->exists();

            if ($hadRevokedPass) {
                return response()->json([
                    'success' => false,
                    'message' => 'Votre pass a été désactivé. Contactez le support pour un nouvel accès.',
                ], 403);
            }

            $ticket = new PassTicket([
                'user_id' => $user->id,
                'public_id' => (string) Str::ulid(),
                'type' => 'joj_visitor_pilot',
                'status' => 'active',
                'valid_until' => now()->addYear(),
            ]);
            $ticket->save();
        }

        $exp = $ticket->valid_until !== null
            ? $ticket->valid_until->getTimestamp()
            : now()->addYear()->getTimestamp();

        $claims = [
            'v' => 1,
            'pid' => $ticket->public_id,
            'sub' => (int) $user->id,
            'typ' => $ticket->type,
            'iat' => now()->getTimestamp(),
            'exp' => $exp,
        ];

        $qr = $signer->makeToken($claims);

        return response()->json([
            'data' => [
                'type' => $ticket->type,
                'public_id' => $ticket->public_id,
                'qr_payload' => $qr,
                'issued_at' => $ticket->created_at?->toIso8601String(),
                'valid_until' => $ticket->valid_until?->toIso8601String(),
            ],
        ]);
    }

    /**
     * Vérification côté contrôleur / staff — protégée par X-Teranga-Pass-Control.
     */
    public function validateScan(Request $request, TerangaPassQrSigner $signer)
    {
        $control = (string) $request->header('X-Teranga-Pass-Control', '');
        $expected = config('services.teranga_pass.control_key');
        if ($expected === null || $expected === '') {
            return response()->json([
                'success' => false,
                'message' => 'Contrôle Pass non configuré (TERANGA_PASS_CONTROL_KEY).',
            ], 503);
        }
        if (! hash_equals($expected, $control)) {
            return response()->json(['success' => false, 'message' => 'Non autorisé.'], 403);
        }

        $qr = (string) $request->input('qr', '');
        if ($qr === '') {
            return response()->json(['success' => false, 'message' => 'QR manquant.'], 422);
        }

        $claims = $signer->parseAndVerify($qr);
        if ($claims === null) {
            return response()->json(['success' => false, 'message' => 'QR invalide ou altéré.'], 422);
        }

        $pid = $claims['pid'] ?? null;
        $sub = isset($claims['sub']) ? (int) $claims['sub'] : 0;
        $exp = isset($claims['exp']) ? (int) $claims['exp'] : 0;

        if (! is_string($pid) || $sub <= 0) {
            return response()->json(['success' => false, 'message' => 'QR incohérent.'], 422);
        }
        if ($exp < now()->getTimestamp()) {
            return response()->json(['success' => false, 'message' => 'QR expiré.'], 422);
        }

        $ticket = PassTicket::query()
            ->where('public_id', $pid)
            ->where('user_id', $sub)
            ->first();

        if ($ticket === null || ! $ticket->isActive()) {
            return response()->json([
                'success' => false,
                'message' => 'Billet révoqué, expiré ou inconnu.',
            ], 422);
        }

        $user = User::find($sub);
        if ($user === null || $user->isBlockedAccount()) {
            return response()->json([
                'success' => false,
                'message' => 'Utilisateur invalide ou suspendu.',
            ], 422);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'holder_name' => $user->name,
                'user_id' => $user->id,
                'ticket_type' => $ticket->type,
                'public_id' => $ticket->public_id,
            ],
        ]);
    }

    private function getUserFromToken(Request $request): ?User
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
