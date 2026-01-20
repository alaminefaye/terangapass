@extends('layouts.app')

@section('title', 'Détails Point d\'Intérêt - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Tourisme /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.tourism.edit', $tourism) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.tourism.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Informations -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations du point d'intérêt</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Nom:</strong>
                            <p>{{ $tourism->name }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Catégorie:</strong>
                            <p>
                                @if($tourism->category == 'hotel')
                                <span class="badge bg-info">🏨 Hôtel</span>
                                @elseif($tourism->category == 'restaurant')
                                <span class="badge bg-success">🍽️ Restaurant</span>
                                @elseif($tourism->category == 'pharmacy')
                                <span class="badge bg-primary">💊 Pharmacie</span>
                                @elseif($tourism->category == 'hospital')
                                <span class="badge bg-danger">🏥 Hôpital</span>
                                @elseif($tourism->category == 'embassy')
                                <span class="badge bg-warning">🏛️ Ambassade</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    @if($tourism->description)
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $tourism->description }}</p>
                    </div>
                    @endif

                    <div class="mb-3">
                        <strong>Adresse:</strong>
                        <p>{{ $tourism->address }}</p>
                    </div>

                    <div class="row mb-3">
                        @if($tourism->phone)
                        <div class="col-md-6">
                            <strong>Téléphone:</strong>
                            <p><a href="tel:{{ $tourism->phone }}">{{ $tourism->phone }}</a></p>
                        </div>
                        @endif
                        @if($tourism->email)
                        <div class="col-md-6">
                            <strong>Email:</strong>
                            <p><a href="mailto:{{ $tourism->email }}">{{ $tourism->email }}</a></p>
                        </div>
                        @endif
                    </div>

                    @if($tourism->website)
                    <div class="mb-3">
                        <strong>Site web:</strong>
                        <p><a href="{{ $tourism->website }}" target="_blank">{{ $tourism->website }}</a></p>
                    </div>
                    @endif

                    <div class="mb-3">
                        <strong>Statut:</strong>
                        <p>
                            @if($tourism->is_active)
                            <span class="badge bg-success">Actif</span>
                            @else
                            <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </p>
                    </div>

                    <div class="mb-3">
                        <strong>Nombre de visites:</strong>
                        <p class="h5">{{ number_format($tourism->visit_count) }}</p>
                    </div>
                </div>
            </div>

            <!-- Carte -->
            @if($tourism->latitude && $tourism->longitude)
            <div class="card">
                <div class="card-header">
                    <h5>Localisation</h5>
                </div>
                <div class="card-body">
                    <div id="tourismMap" style="height: 400px; border-radius: 8px;"></div>
                    <div class="mt-3">
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Latitude:</strong> {{ number_format($tourism->latitude, 6) }}
                            </div>
                            <div class="col-md-6">
                                <strong>Longitude:</strong> {{ number_format($tourism->longitude, 6) }}
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
                        <p>{{ $tourism->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifié le:</strong>
                        <p>{{ $tourism->updated_at->format('d/m/Y à H:i') }}</p>
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
@if($tourism->latitude && $tourism->longitude)
<script>
    // Initialiser la carte
    var map = L.map('tourismMap').setView([{{ $tourism->latitude }}, {{ $tourism->longitude }}], 15);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter un marqueur
    var marker = L.marker([{{ $tourism->latitude }}, {{ $tourism->longitude }}]).addTo(map);
    marker.bindPopup("<strong>{{ $tourism->name }}</strong><br>{{ $tourism->address }}").openPopup();
</script>
@endif
@endpush
