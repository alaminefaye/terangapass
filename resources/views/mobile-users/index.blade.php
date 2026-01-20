@extends('layouts.app')

@section('title', 'Gestion des Utilisateurs Mobile - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Utilisateurs Mobile
    </h4>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.mobile-users.index') }}" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">Pays</label>
                    <select name="country" class="form-select">
                        <option value="">Tous</option>
                        @foreach($usersByCountry as $country)
                        <option value="{{ $country->country }}" {{ request('country') == $country->country ? 'selected' : '' }}>
                            {{ $country->country }} ({{ $country->count }})
                        </option>
                        @endforeach
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">Type</label>
                    <select name="user_type" class="form-select">
                        <option value="">Tous</option>
                        <option value="athlete" {{ request('user_type') == 'athlete' ? 'selected' : '' }}>Athlète</option>
                        <option value="visitor" {{ request('user_type') == 'visitor' ? 'selected' : '' }}>Visiteur</option>
                        <option value="citizen" {{ request('user_type') == 'citizen' ? 'selected' : '' }}>Citoyen</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Recherche</label>
                    <input type="text" name="search" class="form-control" value="{{ request('search') }}" placeholder="Nom, email, téléphone...">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.mobile-users.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
                </div>
            </form>
        </div>
    </div>

    <!-- Statistiques -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title">{{ number_format($users->total()) }}</h5>
                    <p class="card-text text-muted">Total Utilisateurs</p>
                </div>
            </div>
        </div>
        @foreach($usersByCountry->take(3) as $country)
        <div class="col-md-3">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="card-title">{{ number_format($country->count) }}</h5>
                    <p class="card-text text-muted">{{ $country->country }}</p>
                </div>
            </div>
        </div>
        @endforeach
    </div>

    <!-- Tableau -->
    <div class="card">
        <div class="table-responsive text-nowrap">
            <table class="table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nom</th>
                        <th>Email</th>
                        <th>Téléphone</th>
                        <th>Pays</th>
                        <th>Type</th>
                        <th>Alertes</th>
                        <th>Signalements</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($users as $user)
                    <tr>
                        <td>{{ $user->id }}</td>
                        <td><strong>{{ $user->name }}</strong></td>
                        <td>{{ $user->email }}</td>
                        <td>{{ $user->phone ?? '-' }}</td>
                        <td>{{ $user->country ?? '-' }}</td>
                        <td>
                            @if($user->user_type == 'athlete')
                            <span class="badge bg-info">Athlète</span>
                            @elseif($user->user_type == 'visitor')
                            <span class="badge bg-success">Visiteur</span>
                            @elseif($user->user_type == 'citizen')
                            <span class="badge bg-primary">Citoyen</span>
                            @else
                            <span class="badge bg-secondary">-</span>
                            @endif
                        </td>
                        <td><span class="badge bg-danger">{{ $user->alerts_count }}</span></td>
                        <td><span class="badge bg-warning">{{ $user->incidents_count }}</span></td>
                        <td>
                            <a href="{{ route('admin.mobile-users.show', $user) }}" class="btn btn-sm btn-primary">
                                <i class="bx bx-show"></i> Voir
                            </a>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="text-center py-4">Aucun utilisateur trouvé</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $users->links() }}
        </div>
    </div>
</div>
@endsection
