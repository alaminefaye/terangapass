@extends('layouts.app')

@section('title', 'Gestion des Notifications - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Notifications Push
        </h4>
        <a href="{{ route('admin.notifications.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer une notification
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.notifications.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-select">
                        <option value="">Tous</option>
                        <option value="sécurité" {{ request('type') == 'sécurité' ? 'selected' : '' }}>Sécurité</option>
                        <option value="météo" {{ request('type') == 'météo' ? 'selected' : '' }}>Météo</option>
                        <option value="circulation" {{ request('type') == 'circulation' ? 'selected' : '' }}>Circulation</option>
                        <option value="consignes_joj" {{ request('type') == 'consignes_joj' ? 'selected' : '' }}>Consignes JOJ</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Zone</label>
                    <select name="zone" class="form-select">
                        <option value="">Toutes</option>
                        @foreach($zones as $zone)
                        <option value="{{ $zone->name }}" {{ request('zone') == $zone->name ? 'selected' : '' }}>{{ $zone->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Statut</label>
                    <select name="is_active" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" {{ request('is_active') == '1' ? 'selected' : '' }}>Actif</option>
                        <option value="0" {{ request('is_active') == '0' ? 'selected' : '' }}>Inactif</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.notifications.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Titre</th>
                        <th>Type</th>
                        <th>Zone</th>
                        <th>Envoyées</th>
                        <th>Vues</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($notifications as $notification)
                    <tr>
                        <td>{{ $notification->id }}</td>
                        <td><strong>{{ $notification->title }}</strong></td>
                        <td><span class="badge bg-info">{{ ucfirst($notification->type) }}</span></td>
                        <td>{{ $notification->zone ?? 'Toutes' }}</td>
                        <td>{{ number_format($notification->sent_count) }}</td>
                        <td>{{ number_format($notification->viewed_count) }}</td>
                        <td>
                            @if($notification->is_active)
                            <span class="badge bg-success">Actif</span>
                            @else
                            <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>{{ $notification->created_at->format('d/m/Y H:i') }}</td>
                        <td>
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="{{ route('admin.notifications.show', $notification) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.notifications.edit', $notification) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.notifications.send', $notification) }}" method="POST" class="d-inline">
                                        @csrf
                                        <button type="submit" class="dropdown-item">
                                            <i class="bx bx-send me-1"></i> Envoyer maintenant
                                        </button>
                                    </form>
                                    <form action="{{ route('admin.notifications.destroy', $notification) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer cette notification ?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="dropdown-item text-danger">
                                            <i class="bx bx-trash me-1"></i> Supprimer
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="text-center py-4">Aucune notification trouvée</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $notifications->links() }}
        </div>
    </div>
</div>
@endsection
