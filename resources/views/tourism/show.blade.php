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
                                @elseif($tourism->category == 'consulate')
                                <span class="badge bg-dark">🏢 Consulat</span>
                                @elseif($tourism->category == 'bank')
                                <span class="badge bg-secondary">🏦 Banque / DAB</span>
                                @elseif($tourism->category == 'gas_station')
                                <span class="badge bg-secondary">⛽ Station-service</span>
                                @elseif($tourism->category == 'shop')
                                <span class="badge bg-secondary">🛍️ Boutique</span>
                                @else
                                <span class="badge bg-secondary">📌 Autre</span>
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
                    <div id="tourismMap"
                         style="height: 400px; border-radius: 8px;"
                         data-lat="{{ $tourism->latitude }}"
                         data-lng="{{ $tourism->longitude }}"
                         data-name="{{ $tourism->name }}"
                         data-address="{{ $tourism->address }}"></div>
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

            <div class="card mt-4">
                <div class="card-header">
                    <h5>Médias</h5>
                </div>
                <div class="card-body">
                    @php
                        $icon = $tourism->icon_path ?: $tourism->logo_url;
                        $photos = is_array($tourism->photos) ? $tourism->photos : [];
                    @endphp

                    <div class="mb-3">
                        <strong>Icône</strong>
                        <div class="mt-2">
                            @if($icon)
                                <img src="{{ $icon }}" alt="Icon" style="width:120px;height:120px;object-fit:cover;border-radius:16px;">
                            @else
                                <div style="width:120px;height:120px;background:#f1f3f5;border-radius:16px;"></div>
                            @endif
                        </div>
                    </div>

                    <div>
                        <strong>Galerie ({{ count($photos) }})</strong>
                        @if(count($photos) > 0)
                            <div class="d-flex flex-wrap gap-2 mt-2">
                                @foreach($photos as $photoUrl)
                                    <a href="{{ $photoUrl }}" target="_blank">
                                        <img src="{{ $photoUrl }}" alt="Photo" style="width:78px;height:78px;object-fit:cover;border-radius:12px;">
                                    </a>
                                @endforeach
                            </div>
                        @else
                            <div class="text-muted mt-2">Aucune photo</div>
                        @endif
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
    var mapEl = document.getElementById('tourismMap');
    var lat = parseFloat(mapEl.dataset.lat);
    var lng = parseFloat(mapEl.dataset.lng);
    var name = mapEl.dataset.name || '';
    var address = mapEl.dataset.address || '';

    var map = L.map('tourismMap').setView([lat, lng], 15);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    var marker = L.marker([lat, lng]).addTo(map);
    marker.bindPopup("<strong>" + name + "</strong><br>" + address).openPopup();
</script>
@endif
@endpush
