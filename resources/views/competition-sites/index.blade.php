@extends('layouts.app')

@section('title', 'Gestion des Sites de Compétition - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Sites de Compétition JOJ
        </h4>
        <a href="{{ route('admin.competition-sites.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer un site
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.competition-sites.index') }}" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Localisation</label>
                    <input type="text" name="location" class="form-control" value="{{ request('location') }}" placeholder="Ex: Dakar Centre">
                </div>
                <div class="col-md-4">
                    <label class="form-label">Statut</label>
                    <select name="is_active" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" {{ request('is_active') == '1' ? 'selected' : '' }}>Actif</option>
                        <option value="0" {{ request('is_active') == '0' ? 'selected' : '' }}>Inactif</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Nom, adresse...">
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
                        <th>Localisation</th>
                        <th>Période</th>
                        <th>Capacité</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($sites as $site)
                    <tr>
                        <td>{{ $site->id }}</td>
                        <td><strong>{{ $site->name }}</strong></td>
                        <td>{{ $site->location }}</td>
                        <td>
                            @if($site->start_date && $site->end_date)
                            {{ $site->start_date->format('d/m') }} - {{ $site->end_date->format('d/m/Y') }}
                            @else
                            -
                            @endif
                        </td>
                        <td>{{ $site->capacity ? number_format($site->capacity) : '-' }}</td>
                        <td>
                            @if($site->is_active)
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
                                    <a class="dropdown-item" href="{{ route('admin.competition-sites.show', $site) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.competition-sites.edit', $site) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.competition-sites.destroy', $site) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer ce site ?');">
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
                        <td colspan="7" class="text-center py-4">Aucun site de compétition trouvé</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $sites->links() }}
        </div>
    </div>
</div>
@endsection
