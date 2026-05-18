@extends('layouts.app')

@section('title', 'Pop-ups publicitaires - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
        <h4 class="fw-bold py-3 mb-0">
            <span class="text-muted fw-light">Monétisation /</span> Pop-ups pub
        </h4>
        <a href="{{ route('admin.promo-popups.create') }}" class="btn btn-primary">
            <i class="bx bx-plus me-2"></i> Nouvelle campagne
        </a>
    </div>

    <div class="alert alert-info">
        Les visuels s’affichent en plein écran sur l’app mobile (style interstitiel), avec bouton fermer.
        Recommandé : image 1080×1350 px, JPG ou PNG, &lt; 500 Ko.
    </div>

    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Écran</label>
                    <select name="placement" class="form-select">
                        <option value="">Tous</option>
                        @foreach(['home' => 'Accueil', 'map' => 'Carte', 'tourism' => 'Tourisme', 'all' => 'Tous les écrans'] as $k => $label)
                            <option value="{{ $k }}" @selected(request('placement') === $k)>{{ $label }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Statut</label>
                    <select name="is_active" class="form-select">
                        <option value="">Tous</option>
                        <option value="1" @selected(request('is_active') === '1')>Actif</option>
                        <option value="0" @selected(request('is_active') === '0')>Inactif</option>
                    </select>
                </div>
                <div class="col-md-4 d-flex align-items-end gap-2">
                    <button type="submit" class="btn btn-primary">Filtrer</button>
                    <a href="{{ route('admin.promo-popups.index') }}" class="btn btn-outline-secondary">Réinitialiser</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="table-responsive text-nowrap">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Aperçu</th>
                        <th>Campagne</th>
                        <th>Écran</th>
                        <th>Priorité</th>
                        <th>Vues</th>
                        <th>Clics</th>
                        <th>Période</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($popups as $popup)
                    <tr>
                        <td>
                            @if($popup->imageUrl())
                            <img src="{{ $popup->imageUrl() }}" alt="" style="height:48px;border-radius:6px;">
                            @endif
                        </td>
                        <td>
                            <strong>{{ $popup->title }}</strong>
                            @if($popup->sponsor_name)
                            <br><small class="text-muted">{{ $popup->sponsor_name }}</small>
                            @endif
                        </td>
                        <td><span class="badge bg-label-primary">{{ $popup->placement }}</span></td>
                        <td>{{ $popup->priority }}</td>
                        <td>{{ number_format($popup->impression_count) }}</td>
                        <td>{{ number_format($popup->click_count) }}</td>
                        <td>
                            <small>
                                @if($popup->starts_at){{ $popup->starts_at->format('d/m/Y') }}@else—@endif
                                →
                                @if($popup->ends_at){{ $popup->ends_at->format('d/m/Y') }}@else—@endif
                            </small>
                        </td>
                        <td>
                            @if($popup->is_active)
                            <span class="badge bg-success">Actif</span>
                            @else
                            <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>
                            <a href="{{ route('admin.promo-popups.edit', $popup) }}" class="btn btn-sm btn-outline-primary">Modifier</a>
                            <form action="{{ route('admin.promo-popups.destroy', $popup) }}" method="POST" class="d-inline" onsubmit="return confirm('Supprimer cette campagne ?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-outline-danger">Supprimer</button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="text-center text-muted py-4">Aucune campagne pop-up.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        @if($popups->hasPages())
        <div class="card-footer">{{ $popups->links() }}</div>
        @endif
    </div>
</div>
@endsection
