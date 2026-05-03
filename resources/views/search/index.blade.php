@extends('layouts.app')

@section('title', 'Recherche - Teranga Pass')

@section('content')
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Outils /</span> Recherche
    </h4>

    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" action="{{ route('admin.search.index') }}" class="row g-2 align-items-end">
                <div class="col-md-10">
                    <label class="form-label" for="q">Terme</label>
                    <input type="search" name="q" id="q" class="form-control" value="{{ old('q', $q) }}"
                           placeholder="Signalement, partenaire, utilisateur…" maxlength="200" autofocus>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100">Rechercher</button>
                </div>
            </form>
        </div>
    </div>

    @if($q === '')
        <p class="text-muted">Saisissez un terme puis lancez la recherche.</p>
    @else
        @php
            $total = $incidents->count() + $alerts->count() + $partners->count() + $users->count() + $sites->count();
        @endphp
        @if($total === 0)
            <div class="alert alert-secondary">Aucun résultat pour « {{ $q }} ».</div>
        @endif

        @if($incidents->isNotEmpty())
            <div class="card mb-3">
                <div class="card-header fw-semibold">Signalements ({{ $incidents->count() }})</div>
                <ul class="list-group list-group-flush">
                    @foreach($incidents as $incident)
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <span class="badge bg-label-primary me-1">{{ $incident->type }}</span>
                                <span class="badge bg-label-secondary">{{ $incident->status }}</span>
                                <div class="small text-muted mt-1">{{ Str::limit($incident->description ?? '—', 120) }}</div>
                            </div>
                            <a href="{{ route('admin.incidents.show', $incident) }}" class="btn btn-sm btn-outline-primary">Voir</a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if($alerts->isNotEmpty())
            <div class="card mb-3">
                <div class="card-header fw-semibold">Alertes SOS / médicales ({{ $alerts->count() }})</div>
                <ul class="list-group list-group-flush">
                    @foreach($alerts as $alert)
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <span class="badge bg-label-warning me-1">{{ $alert->type }}</span>
                                <span class="badge bg-label-secondary">{{ $alert->status }}</span>
                                <div class="small text-muted mt-1">{{ Str::limit($alert->address ?? $alert->notes ?? '—', 120) }}</div>
                            </div>
                            <a href="{{ route('admin.alerts.show', $alert) }}" class="btn btn-sm btn-outline-primary">Voir</a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if($partners->isNotEmpty())
            <div class="card mb-3">
                <div class="card-header fw-semibold">Partenaires / tourisme ({{ $partners->count() }})</div>
                <ul class="list-group list-group-flush">
                    @foreach($partners as $partner)
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <strong>{{ $partner->name }}</strong>
                                <span class="text-muted small">· {{ $partner->category }}</span>
                                <div class="small text-muted">{{ Str::limit($partner->address ?? '', 80) }}</div>
                            </div>
                            <a href="{{ route('admin.partners.show', $partner) }}" class="btn btn-sm btn-outline-primary">Voir</a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if($users->isNotEmpty())
            <div class="card mb-3">
                <div class="card-header fw-semibold">Utilisateurs mobile ({{ $users->count() }})</div>
                <ul class="list-group list-group-flush">
                    @foreach($users as $user)
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <strong>{{ $user->name }}</strong>
                                <div class="small text-muted">{{ $user->email }} @if($user->phone) · {{ $user->phone }} @endif</div>
                            </div>
                            <a href="{{ route('admin.mobile-users.show', $user) }}" class="btn btn-sm btn-outline-primary">Voir</a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endif

        @if($sites->isNotEmpty())
            <div class="card mb-3">
                <div class="card-header fw-semibold">Sites de compétition ({{ $sites->count() }})</div>
                <ul class="list-group list-group-flush">
                    @foreach($sites as $site)
                        <li class="list-group-item d-flex justify-content-between align-items-start">
                            <div>
                                <strong>{{ $site->name }}</strong>
                                <div class="small text-muted">{{ Str::limit($site->location ?? $site->address ?? '', 100) }}</div>
                            </div>
                            <a href="{{ route('admin.competition-sites.show', $site) }}" class="btn btn-sm btn-outline-primary">Voir</a>
                        </li>
                    @endforeach
                </ul>
            </div>
        @endif
    @endif
@endsection
