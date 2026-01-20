@extends('layouts.app')

@section('title', 'Gestion des Annonces Audio - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Annonces Audio
        </h4>
        <a href="{{ route('admin.audio-announcements.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Créer une annonce
        </a>
    </div>

    <!-- Filtres -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.audio-announcements.index') }}" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Langue</label>
                    <select name="language" class="form-select">
                        <option value="">Toutes</option>
                        <option value="fr" {{ request('language') == 'fr' ? 'selected' : '' }}>Français</option>
                        <option value="en" {{ request('language') == 'en' ? 'selected' : '' }}>Anglais</option>
                        <option value="es" {{ request('language') == 'es' ? 'selected' : '' }}>Espagnol</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Statut</label>
                    <select name="is_active" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" {{ request('is_active') == '1' ? 'selected' : '' }}>Actif</option>
                        <option value="0" {{ request('is_active') == '0' ? 'selected' : '' }}>Inactif</option>
                    </select>
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">Filtrer</button>
                    <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
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
                        <th>Langue</th>
                        <th>Durée</th>
                        <th>Lectures</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody class="table-border-bottom-0">
                    @forelse($announcements as $announcement)
                    <tr>
                        <td>{{ $announcement->id }}</td>
                        <td><strong>{{ $announcement->title }}</strong></td>
                        <td>
                            <span class="badge bg-info">
                                @if($announcement->language == 'fr') 🇫🇷 FR
                                @elseif($announcement->language == 'en') 🇬🇧 EN
                                @elseif($announcement->language == 'es') 🇪🇸 ES
                                @endif
                            </span>
                        </td>
                        <td>{{ $announcement->duration ? gmdate('i:s', $announcement->duration) : '-' }}</td>
                        <td>{{ number_format($announcement->play_count) }}</td>
                        <td>
                            @if($announcement->is_active)
                            <span class="badge bg-success">Actif</span>
                            @else
                            <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>{{ $announcement->created_at->format('d/m/Y H:i') }}</td>
                        <td>
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="{{ route('admin.audio-announcements.show', $announcement) }}">
                                        <i class="bx bx-show me-1"></i> Voir
                                    </a>
                                    <a class="dropdown-item" href="{{ route('admin.audio-announcements.edit', $announcement) }}">
                                        <i class="bx bx-edit-alt me-1"></i> Modifier
                                    </a>
                                    <form action="{{ route('admin.audio-announcements.destroy', $announcement) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer cette annonce ?');">
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
                        <td colspan="8" class="text-center py-4">Aucune annonce audio trouvée</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        <div class="card-footer">
            {{ $announcements->links() }}
        </div>
    </div>
</div>
@endsection
