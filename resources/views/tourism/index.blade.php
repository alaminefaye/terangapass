@extends('layouts.app')

@section('title', 'Gestion du Tourisme - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Tourisme & Services Utiles
        </h4>
        <a href="{{ route('admin.tourism.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer un point d'intérêt
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.tourism.index') }}" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Catégorie</label>
                    <select name="category" class="form-select">
                        <option value="">Toutes</option>
                        <option value="hotel" {{ request('category') == 'hotel' ? 'selected' : '' }}>Hôtel</option>
                        <option value="restaurant" {{ request('category') == 'restaurant' ? 'selected' : '' }}>Restaurant</option>
                        <option value="pharmacy" {{ request('category') == 'pharmacy' ? 'selected' : '' }}>Pharmacie</option>
                        <option value="hospital" {{ request('category') == 'hospital' ? 'selected' : '' }}>Hôpital</option>
                        <option value="embassy" {{ request('category') == 'embassy' ? 'selected' : '' }}>Ambassade</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Nom, adresse...">
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.tourism.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Catégorie</th>
                        <th>Adresse</th>
                        <th>Téléphone</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($pointsOfInterest as $point)
                    <tr>
                        <td>{{ $point->id }}</td>
                        <td><strong>{{ $point->name }}</strong></td>
                        <td>
                            @if($point->category == 'hotel')
                            <span class="badge bg-info">🏨 Hôtel</span>
                            @elseif($point->category == 'restaurant')
                            <span class="badge bg-success">🍽️ Restaurant</span>
                            @elseif($point->category == 'pharmacy')
                            <span class="badge bg-primary">💊 Pharmacie</span>
                            @elseif($point->category == 'hospital')
                            <span class="badge bg-danger">🏥 Hôpital</span>
                            @elseif($point->category == 'embassy')
                            <span class="badge bg-warning">🏛️ Ambassade</span>
                            @endif
                        </td>
                        <td><small>{{ Str::limit($point->address, 40) }}</small></td>
                        <td>{{ $point->phone ?? '-' }}</td>
                        <td>
                            @if($point->is_active)
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
                                    <a class="dropdown-item" href="{{ route('admin.tourism.show', $point) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.tourism.edit', $point) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.tourism.destroy', $point) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer ce point d\'intérêt ?');">
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
                        <td colspan="7" class="text-center py-4">Aucun point d'intérêt trouvé</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $pointsOfInterest->links() }}
        </div>
    </div>
</div>
@endsection
