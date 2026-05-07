@extends('layouts.app')

@section('title', 'Pass QR (billetterie pilote) - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Pass QR
    </h4>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Fermer"></button>
        </div>
    @endif
    @if(session('warning'))
        <div class="alert alert-warning alert-dismissible fade show" role="alert">
            {{ session('warning') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Fermer"></button>
        </div>
    @endif

    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.pass-tickets.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Statut</label>
                    <select name="status" class="form-select">
                        <option value="">Tous</option>
                        <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Actif</option>
                        <option value="revoked" {{ request('status') === 'revoked' ? 'selected' : '' }}>Révoqué</option>
                    </select>
                </div>
                <div class="col-md-5">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Public ID, type, nom ou email utilisateur…">
                </div>
                <div class="col-md-4 d-flex align-items-end gap-2 flex-wrap">
                    <button type="submit" class="btn btn-primary">Filtrer</button>
                    <a href="{{ route('admin.pass-tickets.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="table-responsive text-nowrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Public ID</th>
                        <th>Type</th>
                        <th>Utilisateur</th>
                        <th>Statut</th>
                        <th>Valide jusqu’au</th>
                        <th>Créé le</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($tickets as $ticket)
                        <tr>
                            <td>{{ $ticket->id }}</td>
                            <td><code class="small">{{ $ticket->public_id }}</code></td>
                            <td>{{ $ticket->type }}</td>
                            <td>
                                @if($ticket->user)
                                    <a href="{{ route('admin.mobile-users.show', $ticket->user) }}">{{ $ticket->user->name }}</a>
                                    <div class="small text-muted">{{ $ticket->user->email }}</div>
                                @else
                                    —
                                @endif
                            </td>
                            <td>
                                @if($ticket->isActive())
                                    <span class="badge bg-success">Actif</span>
                                @else
                                    <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </td>
                            <td>{{ $ticket->valid_until ? $ticket->valid_until->format('d/m/Y H:i') : '—' }}</td>
                            <td>{{ $ticket->created_at->format('d/m/Y H:i') }}</td>
                            <td>
                                @if($ticket->isActive())
                                    <form action="{{ route('admin.pass-tickets.revoke', $ticket) }}" method="POST" class="d-inline" onsubmit="return confirm('Révoquer ce pass ? Le QR ne sera plus valide.');">
                                        @csrf
                                        <button type="submit" class="btn btn-sm btn-outline-danger">Révoquer</button>
                                    </form>
                                @elseif($ticket->user && !\App\Models\PassTicket::queryActiveForUser($ticket->user_id)->exists())
                                    <form action="{{ route('admin.pass-tickets.reissue', $ticket->user) }}" method="POST" class="d-inline" onsubmit="return confirm('Émettre un nouveau pass pour cet utilisateur ?');">
                                        @csrf
                                        <button type="submit" class="btn btn-sm btn-outline-success">Redélivrer</button>
                                    </form>
                                @else
                                    <span class="text-muted small">—</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="text-center text-muted py-4">Aucun billet pour le moment.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($tickets->hasPages())
            <div class="card-body">
                {{ $tickets->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
