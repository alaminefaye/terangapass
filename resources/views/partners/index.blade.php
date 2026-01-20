@extends('layouts.app')

@section('title', 'Gestion des Partenaires - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Partenaires
        </h4>
        <a href="{{ route('admin.partners.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer un partenaire
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.partners.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Catégorie</label>
                    <select name="category" class="form-select">
                        <option value="">Toutes</option>
                        <option value="hotel" {{ request('category') == 'hotel' ? 'selected' : '' }}>Hôtel</option>
                        <option value="restaurant" {{ request('category') == 'restaurant' ? 'selected' : '' }}>Restaurant</option>
                        <option value="pharmacy" {{ request('category') == 'pharmacy' ? 'selected' : '' }}>Pharmacie</option>
                        <option value="hospital" {{ request('category') == 'hospital' ? 'selected' : '' }}>Hôpital</option>
                        <option value="embassy" {{ request('category') == 'embassy' ? 'selected' : '' }}>Ambassade</option>
                        <option value="other" {{ request('category') == 'other' ? 'selected' : '' }}>Autre</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Sponsor</label>
                    <select name="is_sponsor" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" {{ request('is_sponsor') == '1' ? 'selected' : '' }}>Oui</option>
                        <option value="0" {{ request('is_sponsor') == '0' ? 'selected' : '' }}>Non</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Statut</label>
                    <select name="is_active" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" {{ request('is_active') == '1' ? 'selected' : '' }}>Actif</option>
                        <option value="0" {{ request('is_active') == '0' ? 'selected' : '' }}>Inactif</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Nom, adresse...">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.partners.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Visites</th>
                        <th>Sponsor</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($partners as $partner)
                    <tr>
                        <td>{{ $partner->id }}</td>
                        <td><strong>{{ $partner->name }}</strong></td>
                        <td>
                            @if($partner->category == 'hotel')
                            <span class="badge bg-info">Hôtel</span>
                            @elseif($partner->category == 'restaurant')
                            <span class="badge bg-success">Restaurant</span>
                            @elseif($partner->category == 'pharmacy')
                            <span class="badge bg-primary">Pharmacie</span>
                            @elseif($partner->category == 'hospital')
                            <span class="badge bg-danger">Hôpital</span>
                            @elseif($partner->category == 'embassy')
                            <span class="badge bg-warning">Ambassade</span>
                            @else
                            <span class="badge bg-secondary">Autre</span>
                            @endif
                        </td>
                        <td><small>{{ Str::limit($partner->address, 40) }}</small></td>
                        <td>{{ number_format($partner->visit_count) }}</td>
                        <td>
                            @if($partner->is_sponsor)
                            <span class="badge bg-warning">Oui</span>
                            @else
                            <span class="badge bg-secondary">Non</span>
                            @endif
                        </td>
                        <td>
                            @if($partner->is_active)
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
                                    <a class="dropdown-item" href="{{ route('admin.partners.show', $partner) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.partners.edit', $partner) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.partners.destroy', $partner) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer ce partenaire ?');">
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
                        <td colspan="8" class="text-center py-4">Aucun partenaire trouvé</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $partners->links() }}
        </div>
    </div>
</div>
@endsection
