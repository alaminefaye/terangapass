@extends('layouts.app')

@section('title', 'Détails Partenaire - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Partenaires /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.partners.edit', $partner) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.partners.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Informations -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations du partenaire</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Nom:</strong>
                            <p>{{ $partner->name }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Catégorie:</strong>
                            <p>
                                @if($partner->category == 'hotel')
                                <span class="badge bg-info">🏨 Hôtel</span>
                                @elseif($partner->category == 'restaurant')
                                <span class="badge bg-success">🍽️ Restaurant</span>
                                @elseif($partner->category == 'pharmacy')
                                <span class="badge bg-primary">💊 Pharmacie</span>
                                @elseif($partner->category == 'hospital')
                                <span class="badge bg-danger">🏥 Hôpital</span>
                                @elseif($partner->category == 'embassy')
                                <span class="badge bg-warning">🏛️ Ambassade</span>
                                @else
                                <span class="badge bg-secondary">Autre</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    @if($partner->description)
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $partner->description }}</p>
                    </div>
                    @endif

                    <div class="mb-3">
                        <strong>Adresse:</strong>
                        <p>{{ $partner->address }}</p>
                    </div>

                    <div class="row mb-3">
                        @if($partner->phone)
                        <div class="col-md-6">
                            <strong>Téléphone:</strong>
                            <p>{{ $partner->phone }}</p>
                        </div>
                        @endif
                        @if($partner->email)
                        <div class="col-md-6">
                            <strong>Email:</strong>
                            <p><a href="mailto:{{ $partner->email }}">{{ $partner->email }}</a></p>
                        </div>
                        @endif
                    </div>

                    @if($partner->website)
                    <div class="mb-3">
                        <strong>Site web:</strong>
                        <p><a href="{{ $partner->website }}" target="_blank">{{ $partner->website }}</a></p>
                    </div>
                    @endif

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($partner->is_active)
                                <span class="badge bg-success">Actif</span>
                                @else
                                <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Sponsor:</strong>
                            <p>
                                @if($partner->is_sponsor)
                                <span class="badge bg-warning">Oui</span>
                                @else
                                <span class="badge bg-secondary">Non</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    <div class="mb-3">
                        <strong>Nombre de visites:</strong>
                        <p class="h5">{{ number_format($partner->visit_count) }}</p>
                    </div>
                </div>
            </div>

            <!-- Carte -->
            @if($partner->latitude && $partner->longitude)
            <div class="card">
                <div class="card-header">
                    <h5>Localisation</h5>
                </div>
                <div class="card-body">
                    <div id="partnerMap" style="height: 400px; border-radius: 8px;"></div>
                    <div class="mt-3">
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Latitude:</strong> {{ number_format($partner->latitude, 6) }}
                            </div>
                            <div class="col-md-6">
                                <strong>Longitude:</strong> {{ number_format($partner->longitude, 6) }}
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
                        <p>{{ $partner->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifié le:</strong>
                        <p>{{ $partner->updated_at->format('d/m/Y à H:i') }}</p>
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
@if($partner->latitude && $partner->longitude)
<script>
    // Initialiser la carte
    var map = L.map('partnerMap').setView([{{ $partner->latitude }}, {{ $partner->longitude }}], 15);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter un marqueur
    var marker = L.marker([{{ $partner->latitude }}, {{ $partner->longitude }}]).addTo(map);
    marker.bindPopup("<strong>{{ $partner->name }}</strong><br>{{ $partner->address }}").openPopup();
</script>
@endif
@endpush
