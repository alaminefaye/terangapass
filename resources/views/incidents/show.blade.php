@extends('layouts.app')

@section('title', 'Détails Signalement - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Signalements /</span> Détails
        </h4>
        <a href="{{ route('admin.incidents.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Informations -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations du signalement</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Type:</strong>
                            <p>
                                @if($incident->type == 'perte')
                                <span class="badge bg-warning">Perte</span>
                                @elseif($incident->type == 'accident')
                                <span class="badge bg-danger">Accident</span>
                                @else
                                <span class="badge bg-info">Situation suspecte</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($incident->status == 'pending')
                                <span class="badge bg-warning">En attente</span>
                                @elseif($incident->status == 'validated')
                                <span class="badge bg-info">Validé</span>
                                @elseif($incident->status == 'in_progress')
                                <span class="badge bg-primary">En cours</span>
                                @elseif($incident->status == 'resolved')
                                <span class="badge bg-success">Résolu</span>
                                @else
                                <span class="badge bg-secondary">Rejeté</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $incident->description }}</p>
                    </div>

                    @if($incident->admin_notes)
                    <div class="mb-3">
                        <strong>Notes administrateur:</strong>
                        <p>{{ $incident->admin_notes }}</p>
                    </div>
                    @endif

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Créé le:</strong>
                            <p>{{ $incident->created_at->format('d/m/Y à H:i') }}</p>
                        </div>
                        @if($incident->resolved_at)
                        <div class="col-md-6">
                            <strong>Résolu le:</strong>
                            <p>{{ $incident->resolved_at->format('d/m/Y à H:i') }}</p>
                        </div>
                        @endif
                    </div>
                </div>
            </div>

            <!-- Photos -->
            @if($incident->photos && count(json_decode($incident->photos, true)) > 0)
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Photos</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        @foreach(json_decode($incident->photos, true) as $photo)
                        <div class="col-md-4 mb-3">
                            <img src="{{ asset($photo) }}" alt="Photo" class="img-fluid rounded" style="max-height: 200px; width: 100%; object-fit: cover;">
                        </div>
                        @endforeach
                    </div>
                </div>
            </div>
            @endif

            <!-- Audio -->
            @if($incident->audio_url)
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Enregistrement audio</h5>
                </div>
                <div class="card-body">
                    <audio controls class="w-100">
                        <source src="{{ asset($incident->audio_url) }}" type="audio/mpeg">
                        Votre navigateur ne supporte pas l'élément audio.
                    </audio>
                </div>
            </div>
            @endif

            <!-- Carte -->
            <div class="card">
                <div class="card-header">
                    <h5>Localisation</h5>
                </div>
                <div class="card-body">
                    <div id="incidentMap" style="height: 400px; border-radius: 8px;"></div>
                    <div class="mt-3">
                        <strong>Adresse:</strong>
                        <p>{{ $incident->address ?? 'Non disponible' }}</p>
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Latitude:</strong> {{ number_format($incident->latitude, 6) }}
                            </div>
                            <div class="col-md-6">
                                <strong>Longitude:</strong> {{ number_format($incident->longitude, 6) }}
                            </div>
                            @if($incident->accuracy)
                            <div class="col-md-6 mt-2">
                                <strong>Précision:</strong> {{ number_format($incident->accuracy, 2) }} mètres
                            </div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <!-- Utilisateur -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Utilisateur</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Nom:</strong>
                        <p>{{ $incident->user->name ?? 'N/A' }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Email:</strong>
                        <p>{{ $incident->user->email ?? 'N/A' }}</p>
                    </div>
                    @if($incident->user && $incident->user->phone)
                    <div class="mb-3">
                        <strong>Téléphone:</strong>
                        <p>{{ $incident->user->phone }}</p>
                    </div>
                    @endif
                </div>
            </div>

            <!-- Actions -->
            <div class="card">
                <div class="card-header">
                    <h5>Actions</h5>
                </div>
                <div class="card-body">
                    @if($incident->status == 'pending')
                    <form action="{{ route('admin.incidents.validate', $incident) }}" method="POST" class="mb-3">
                        @csrf
                        <textarea name="admin_notes" class="form-control mb-2" rows="3" placeholder="Notes (optionnel)"></textarea>
                        <button type="submit" class="btn btn-success w-100">Valider</button>
                    </form>

                    <form action="{{ route('admin.incidents.reject', $incident) }}" method="POST" class="mb-3">
                        @csrf
                        <textarea name="admin_notes" class="form-control mb-2" rows="3" placeholder="Raison du rejet *" required></textarea>
                        <button type="submit" class="btn btn-danger w-100">Rejeter</button>
                    </form>
                    @endif

                    <form action="{{ route('admin.incidents.updateStatus', $incident) }}" method="POST">
                        @csrf
                        @method('PUT')
                        <label class="form-label">Changer le statut</label>
                        <select name="status" class="form-select mb-2">
                            <option value="pending" {{ $incident->status == 'pending' ? 'selected' : '' }}>En attente</option>
                            <option value="validated" {{ $incident->status == 'validated' ? 'selected' : '' }}>Validé</option>
                            <option value="in_progress" {{ $incident->status == 'in_progress' ? 'selected' : '' }}>En cours</option>
                            <option value="resolved" {{ $incident->status == 'resolved' ? 'selected' : '' }}>Résolu</option>
                            <option value="rejected" {{ $incident->status == 'rejected' ? 'selected' : '' }}>Rejeté</option>
                        </select>
                        <textarea name="admin_notes" class="form-control mb-2" rows="3" placeholder="Notes (optionnel)">{{ old('admin_notes', $incident->admin_notes) }}</textarea>
                        <button type="submit" class="btn btn-primary w-100">Mettre à jour</button>
                    </form>
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
<script>
    // Initialiser la carte
    var map = L.map('incidentMap').setView([{{ $incident->latitude }}, {{ $incident->longitude }}], 15);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter un marqueur pour le signalement
    var markerColor = '{{ $incident->type == "accident" ? "red" : ($incident->type == "perte" ? "orange" : "blue") }}';
    var marker = L.marker([{{ $incident->latitude }}, {{ $incident->longitude }}], {
        icon: L.divIcon({
            className: 'incident-marker',
            html: '<div style="background: ' + markerColor + '; width: 30px; height: 30px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);"></div>',
            iconSize: [30, 30]
        })
    }).addTo(map);

    marker.bindPopup("<strong>{{ ucfirst($incident->type) }}</strong><br>{{ $incident->address ?? 'Localisation' }}").openPopup();
</script>
@endpush
