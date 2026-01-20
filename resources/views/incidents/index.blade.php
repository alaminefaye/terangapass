@extends('layouts.app')

@section('title', 'Gestion des Signalements - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Signalements
    </h4>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.incidents.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-select">
                        <option value="">Tous</option>
                        <option value="perte" {{ request('type') == 'perte' ? 'selected' : '' }}>Perte</option>
                        <option value="accident" {{ request('type') == 'accident' ? 'selected' : '' }}>Accident</option>
                        <option value="suspect" {{ request('type') == 'suspect' ? 'selected' : '' }}>Situation suspecte</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Statut</label>
                    <select name="status" class="form-select">
                        <option value="">Tous</option>
                        <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>En attente</option>
                        <option value="validated" {{ request('status') == 'validated' ? 'selected' : '' }}>Validé</option>
                        <option value="in_progress" {{ request('status') == 'in_progress' ? 'selected' : '' }}>En cours</option>
                        <option value="resolved" {{ request('status') == 'resolved' ? 'selected' : '' }}>Résolu</option>
                        <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>Rejeté</option>
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
                    <a href="{{ route('admin.incidents.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Description</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($incidents as $incident)
                    <tr>
                        <td>{{ $incident->id }}</td>
                        <td>{{ $incident->user->name ?? 'N/A' }}</td>
                        <td>
                            @if($incident->type == 'perte')
                            <span class="badge bg-warning">Perte</span>
                            @elseif($incident->type == 'accident')
                            <span class="badge bg-danger">Accident</span>
                            @else
                            <span class="badge bg-info">Suspect</span>
                            @endif
                        </td>
                        <td><small>{{ Str::limit($incident->description, 50) }}</small></td>
                        <td>
                            @if($incident->status == 'pending')
                            <span class="badge bg-warning">En attente</span>
                            @elseif($incident->status == 'validated')
                            <span class="badge bg-info">Validé</span>
                            @elseif($incident->status == 'in_progress')
                            <span class="badge bg-primary">En cours</span>
                            @elseif($incident->status == 'resolved')
                            <span class="badge bg-success">Résolu</span>
                            @else
                            <span class="badge bg-secondary">Rejeté</span>
                            @endif
                        </td>
                        <td>{{ $incident->created_at->format('d/m/Y H:i') }}</td>
                        <td>
                            <a href="{{ route('admin.incidents.show', $incident) }}" class="btn btn-sm btn-primary">
                                <i class="bx bx-show"></i> Voir
                            </a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="7" class="text-center py-4">Aucun signalement trouvé</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $incidents->links() }}
        </div>
    </div>
</div>
@endsection
