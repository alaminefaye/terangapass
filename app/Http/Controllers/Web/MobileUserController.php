<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Support\EmailNormalizer;
use App\Support\PhoneNormalizer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\Rule;

class MobileUserController extends Controller
{
    protected function isProtectedAdmin(User $user): bool
    {
        return $user->user_type === 'admin';
    }

    public function index(Request $request)
    {
        $query = User::query();

        if ($request->filled('country')) {
            $query->where('country', $request->country);
        }

        if ($request->filled('user_type')) {
            $query->where('user_type', $request->user_type);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('email', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $users = $query->withCount(['alerts', 'incidents'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        $usersByCountry = User::select('country')
            ->selectRaw('count(*) as count')
            ->groupBy('country')
            ->orderByDesc('count')
            ->get();

        return view('mobile-users.index', compact('users', 'usersByCountry'));
    }

    public function show(User $user)
    {
        $user->load(['alerts' => function ($query) {
            $query->latest()->limit(10);
        }, 'incidents' => function ($query) {
            $query->latest()->limit(10);
        }, 'deviceTokens']);

        $stats = [
            'total_alerts' => $user->alerts()->count(),
            'sos_alerts' => $user->alerts()->where('type', 'sos')->count(),
            'medical_alerts' => $user->alerts()->where('type', 'medical')->count(),
            'total_incidents' => $user->incidents()->count(),
            'pending_incidents' => $user->incidents()->where('status', 'pending')->count(),
            'resolved_incidents' => $user->incidents()->where('status', 'resolved')->count(),
        ];

        return view('mobile-users.show', compact('user', 'stats'));
    }

    public function edit(User $user)
    {
        if ($this->isProtectedAdmin($user)) {
            return redirect()
                ->route('admin.mobile-users.index')
                ->with('error', 'Les comptes administrateur ne sont pas modifiables depuis cette page.');
        }

        return view('mobile-users.edit', compact('user'));
    }

    public function update(Request $request, User $user)
    {
        if ($this->isProtectedAdmin($user)) {
            return redirect()
                ->route('admin.mobile-users.index')
                ->with('error', 'Les comptes administrateur ne sont pas modifiables depuis cette page.');
        }

        $countryRaw = trim((string) $request->input('country', $user->country ?? 'SN'));
        $country = strtoupper($countryRaw === '' ? 'SN' : $countryRaw);

        $email = EmailNormalizer::normalize((string) $request->input('email', ''));
        $rawPhone = $request->input('phone');
        $phone = PhoneNormalizer::normalize(
            $rawPhone === null || (is_string($rawPhone) && trim($rawPhone) === '') ? null : (string) $rawPhone,
            $country,
        );

        $request->merge([
            'email' => $email,
            'phone' => $phone,
            'country' => $country,
        ]);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => [
                'required',
                'string',
                'email',
                'max:255',
                Rule::unique('users', 'email')->ignore($user->id),
            ],
            'phone' => [
                'required',
                'string',
                'max:30',
                Rule::unique('users', 'phone')->ignore($user->id),
            ],
            'country' => 'required|string|size:2',
            'user_type' => 'required|in:athlete,visitor,citizen',
            'language' => 'required|in:fr,en,es',
            'password' => 'nullable|string|min:8|confirmed',
        ], [
            'email.unique' => 'Cet email est déjà utilisé.',
            'phone.unique' => 'Ce numéro est déjà utilisé.',
        ]);

        $payload = [
            'name' => $validated['name'],
            'email' => $email,
            'phone' => $phone,
            'country' => strtoupper($validated['country']),
            'user_type' => $validated['user_type'],
            'language' => $validated['language'],
        ];

        if (! empty($validated['password'])) {
            $payload['password'] = Hash::make($validated['password']);
        }

        $user->update($payload);

        return redirect()
            ->route('admin.mobile-users.show', $user)
            ->with('success', 'Utilisateur mis à jour.');
    }

    public function toggleBlock(User $user)
    {
        if ($this->isProtectedAdmin($user)) {
            return redirect()->back()->with('error', 'Impossible de bloquer un compte administrateur.');
        }

        if (! Schema::hasColumn('users', 'is_blocked')) {
            return redirect()->back()->with('error', 'Migration manquante sur le serveur : exécutez « php artisan migrate » (colonne is_blocked).');
        }

        $user->is_blocked = ! $user->isBlockedAccount();
        $user->save();

        if ($user->isBlockedAccount()) {
            $user->deviceTokens()->update(['is_active' => false]);
        }

        $msg = $user->isBlockedAccount()
            ? 'Utilisateur bloqué. La connexion et l’API mobile sont désactivées pour ce compte.'
            : 'Utilisateur débloqué.';

        return redirect()->back()->with('success', $msg);
    }

    public function destroy(User $user)
    {
        if ($this->isProtectedAdmin($user)) {
            return redirect()->back()->with('error', 'Impossible de supprimer un compte administrateur.');
        }

        if (auth()->id() === $user->id) {
            return redirect()->back()->with('error', 'Vous ne pouvez pas supprimer votre propre compte.');
        }

        $user->delete();

        return redirect()
            ->route('admin.mobile-users.index')
            ->with('success', 'Utilisateur supprimé.');
    }
}
