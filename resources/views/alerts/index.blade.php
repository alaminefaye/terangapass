@extends('layouts.app')

@section('title', 'Gestion des Alertes - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Alertes
    </h4>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.alerts.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-select">
                        <option value="">Tous</option>
                        <option value="sos" {{ request('type') == 'sos' ? 'selected' : '' }}>SOS</option>
                        <option value="medical" {{ request('type') == 'medical' ? 'selected' : '' }}>Médicale</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Statut</label>
                    <select name="status" class="form-select">
                        <option value="">Tous</option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>En attente</option>
                        <option value="in_progress" {{ request('status') == 'in_progress' ? 'selected' : '' }}>En cours</option>
                        <option value="resolved" {{ request('status') == 'resolved' ? 'selected' : '' }}>Résolue</option>
                        <option value="cancelled" {{ request('status') == 'cancelled' ? 'selected' : '' }}>Annulée</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Date début</label>
                    <input type="date" name="date_from" class="form-control" value="{{ request('date_from') }}">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Date fin</label>
                    <input type="date" name="date_to" class="form-control" value="{{ request('date_to') }}">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.alerts.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
                </div>
            </form>
        </div>
    </div>

    <!-- Tableau -->
    <div class="card">
        <div class="table-responsive text-nowrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Utilisateur</th>
                        <th>Type</th>
                        <th>Localisation</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($alerts as $alert)
                    <tr>
                        <td>{{ $alert->id }}</td>
                        <td>{{ $alert->user->name ?? 'N/A' }}</td>
                        <td>
                            @if($alert->type == 'sos')
                            <span class="badge bg-danger">SOS</span>
                            @else
                            <span class="badge bg-warning">Médicale</span>
                            @endif
                        </td>
                        <td>
                            @if($alert->address)
                            <small>{{ Str::limit($alert->address, 40) }}</small>
                            @else
                            <small>{{ number_format($alert->latitude, 6) }}, {{ number_format($alert->longitude, 6) }}</small>
                            @endif
                        </td>
                        <td>
                            @if($alert->status == 'pending')
                            <span class="badge bg-warning">En attente</span>
                            @elseif($alert->status == 'in_progress')
                            <span class="badge bg-info">En cours</span>
                            @elseif($alert->status == 'resolved')
                            <span class="badge bg-success">Résolue</span>
                            @else
                            <span class="badge bg-secondary">Annulée</span>
                            @endif
                        </td>
                        <td>{{ $alert->created_at->format('d/m/Y H:i') }}</td>
                        <td>
                            <a href="{{ route('admin.alerts.show', $alert) }}" class="btn btn-sm btn-primary">
                                <i class="bx bx-show"></i> Voir
                            </a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="text-center py-4">Aucune alerte trouvée</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $alerts->links() }}
        </div>
    </div>
</div>
@endsection
