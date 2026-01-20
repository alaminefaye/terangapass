@extends('layouts.app')

@section('title', 'Gestion du Transport - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Transport & Navettes
        </h4>
        <a href="{{ route('admin.transport.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer une navette
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.transport.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select name="type" class="form-select">
                        <option value="">Tous</option>
                        <option value="regular" {{ request('type') == 'regular' ? 'selected' : '' }}>Régulier</option>
                        <option value="express" {{ request('type') == 'express' ? 'selected' : '' }}>Express</option>
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
                <div class="col-md-4">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Nom, description...">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.transport.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Nom</th>
                        <th>Type</th>
                        <th>Départ → Arrivée</th>
                        <th>Période</th>
                        <th>Fréquence</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($shuttles as $shuttle)
                    <tr>
                        <td>{{ $shuttle->id }}</td>
                        <td><strong>{{ $shuttle->name }}</strong></td>
                        <td>
                            @if($shuttle->type == 'express')
                            <span class="badge bg-warning">Express</span>
                            @else
                            <span class="badge bg-info">Régulier</span>
                            @endif
                        </td>
                        <td>
                            <small>{{ $shuttle->start_location }}@if($shuttle->end_location) → {{ $shuttle->end_location }}@endif</small>
                        </td>
                        <td>
                            @if($shuttle->start_date && $shuttle->end_date)
                            {{ $shuttle->start_date->format('d/m') }} - {{ $shuttle->end_date->format('d/m/Y') }}
                            @else
                            -
                            @endif
                        </td>
                        <td>
                            @if($shuttle->frequency_minutes)
                            Tous les {{ $shuttle->frequency_minutes }} min
                            @else
                            -
                            @endif
                        </td>
                        <td>
                            @if($shuttle->is_active)
                            <span class="badge bg-success">Actif</span>
                            @else
                            <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="{{ route('admin.transport.show', $shuttle) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.transport.edit', $shuttle) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.transport.destroy', $shuttle) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer cette navette ?');">
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
                        <td colspan="8" class="text-center py-4">Aucune navette trouvée</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $shuttles->links() }}
        </div>
    </div>
</div>
@endsection
