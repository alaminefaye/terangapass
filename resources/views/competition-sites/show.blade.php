@extends('layouts.app')

@section('title', 'Détails Site de Compétition - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Sites JOJ /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.competition-sites.edit', $competitionSite) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.competition-sites.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Informations -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations du site</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Nom:</strong>
                            <p>{{ $competitionSite->name }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Localisation:</strong>
                            <p>{{ $competitionSite->location }}</p>
                        </div>
                    </div>

                    @if($competitionSite->description)
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $competitionSite->description }}</p>
                    </div>
                    @endif

                    @if($competitionSite->start_date && $competitionSite->end_date)
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Date début:</strong>
                            <p>{{ $competitionSite->start_date->format('d/m/Y') }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Date fin:</strong>
                            <p>{{ $competitionSite->end_date->format('d/m/Y') }}</p>
                        </div>
                    </div>
                    @endif

                    @if($competitionSite->address)
                    <div class="mb-3">
                        <strong>Adresse:</strong>
                        <p>{{ $competitionSite->address }}</p>
                    </div>
                    @endif

                    @if($competitionSite->sports && count($competitionSite->sports) > 0)
                    <div class="mb-3">
                        <strong>Sports pratiqués:</strong>
                        <div class="d-flex flex-wrap gap-2 mt-2">
                            @foreach($competitionSite->sports as $sport)
                            <span class="badge bg-info">{{ $sport }}</span>
                            @endforeach
                        </div>
                    </div>
                    @endif

                    @if($competitionSite->access_info)
                    <div class="mb-3">
                        <strong>Informations d'accès:</strong>
                        <p>{{ $competitionSite->access_info }}</p>
                    </div>
                    @endif

                    <div class="row mb-3">
                        @if($competitionSite->capacity)
                        <div class="col-md-6">
                            <strong>Capacité:</strong>
                            <p>{{ number_format($competitionSite->capacity) }} places</p>
                        </div>
                        @endif
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($competitionSite->is_active)
                                <span class="badge bg-success">Actif</span>
                                @else
                                <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Carte -->
            @if($competitionSite->latitude && $competitionSite->longitude)
            <div class="card">
                <div class="card-header">
                    <h5>Localisation</h5>
                </div>
                <div class="card-body">
                    <div id="siteMap" style="height: 400px; border-radius: 8px;"></div>
                    <div class="mt-3">
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Latitude:</strong> {{ number_format($competitionSite->latitude, 6) }}
                            </div>
                            <div class="col-md-6">
                                <strong>Longitude:</strong> {{ number_format($competitionSite->longitude, 6) }}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            @endif
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Informations</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Créé le:</strong>
                        <p>{{ $competitionSite->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifié le:</strong>
                        <p>{{ $competitionSite->updated_at->format('d/m/Y à H:i') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('vendor-js')
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
@endpush

@push('page-js')
@if($competitionSite->latitude && $competitionSite->longitude)
<script>
    // Initialiser la carte
    var map = L.map('siteMap').setView([{{ $competitionSite->latitude }}, {{ $competitionSite->longitude }}], 15);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter un marqueur
    var marker = L.marker([{{ $competitionSite->latitude }}, {{ $competitionSite->longitude }}], {
        icon: L.divIcon({
            className: 'site-marker',
            html: '<div style="background: #00853F; width: 30px; height: 30px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);"></div>',
            iconSize: [30, 30]
        })
    }).addTo(map);
    marker.bindPopup("<strong>{{ $competitionSite->name }}</strong><br>{{ $competitionSite->address ?? $competitionSite->location }}").openPopup();
</script>
@endif
@endpush
