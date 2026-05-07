<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\PassTicket;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class PassTicketManagementController extends Controller
{
    public function index(Request $request)
    {
        $query = PassTicket::query()->with('user');

        if ($request->filled('status')) {
            if ($request->status === 'active') {
                $query->where('status', 'active')->whereNull('revoked_at');
            } elseif ($request->status === 'revoked') {
                $query->where(function ($q): void {
                    $q->where('status', 'revoked')->orWhereNotNull('revoked_at');
                });
            }
        }

        if ($request->filled('search')) {
            $s = $request->search;
            $query->where(function ($q) use ($s): void {
                $q->where('public_id', 'like', "%{$s}%")
                    ->orWhere('type', 'like', "%{$s}%")
                    ->orWhereHas('user', function ($uq) use ($s): void {
                        $uq->where('name', 'like', "%{$s}%")
                            ->orWhere('email', 'like', "%{$s}%");
                    });
            });
        }

        $tickets = $query->orderByDesc('created_at')->paginate(25)->withQueryString();

        return view('pass-tickets.index', compact('tickets'));
    }

    public function revoke(PassTicket $passTicket)
    {
        if ($passTicket->status === 'revoked' || $passTicket->revoked_at !== null) {
            return redirect()
                ->route('admin.pass-tickets.index')
                ->with('warning', 'Ce billet est déjà révoqué.');
        }

        $passTicket->update([
            'status' => 'revoked',
            'revoked_at' => now(),
        ]);

        return redirect()
            ->route('admin.pass-tickets.index')
            ->with('success', 'Billet révoqué. Le QR ne sera plus accepté aux contrôles.');
    }

    /**
     * Émet un nouveau pass actif (ex. après révocation), si l’utilisateur n’en a pas déjà un.
     */
    public function reissue(User $user)
    {
        if ($user->user_type === 'admin') {
            return redirect()
                ->route('admin.pass-tickets.index')
                ->with('warning', 'Les comptes administrateur ne reçoivent pas de pass depuis cette page.');
        }

        if (PassTicket::queryActiveForUser($user->id)->exists()) {
            return redirect()
                ->route('admin.pass-tickets.index')
                ->with('warning', 'Cet utilisateur a déjà un pass actif.');
        }

        PassTicket::create([
            'user_id' => $user->id,
            'public_id' => (string) Str::ulid(),
            'type' => 'joj_visitor_pilot',
            'status' => 'active',
            'valid_until' => now()->addYear(),
        ]);

        return redirect()
            ->route('admin.pass-tickets.index')
            ->with('success', 'Nouveau pass émis pour '.$user->name.'.');
    }
}
