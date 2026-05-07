<?php

namespace App\Http\Middleware;

use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureApiUserNotBlocked
{
    /**
     * Si un jeton Bearer identifie un utilisateur bloqué, refuser l’accès API (403).
     */
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();
        if ($token === null || $token === '') {
            return $next($request);
        }

        $decoded = base64_decode($token, true);
        if ($decoded === false || $decoded === '') {
            return $next($request);
        }

        $parts = explode('|', $decoded);
        if (count($parts) < 1) {
            return $next($request);
        }

        $userId = (int) $parts[0];
        if ($userId <= 0) {
            return $next($request);
        }

        $user = User::query()->find($userId);
        if ($user && $user->is_blocked) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte est suspendu.',
            ], 403);
        }

        return $next($request);
    }
}
