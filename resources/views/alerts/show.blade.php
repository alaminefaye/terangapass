@extends('layouts.app')

@section('title', 'Détails Alerte - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Alertes /</span> Détails
        </h4>
        <a href="{{ route('admin.alerts.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Carte -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Localisation</h5>
                </div>
                <div class="card-body">
                    <div id="alertMap" style="height: 400px; border-radius: 8px;"></div>
                    <div class="mt-3">
                        <strong>Adresse:</strong>
                        <p>{{ $alert->address ?? 'Non disponible' }}</p>
                        <div class="row">
                            <div class="col-md-6">
                                <strong>Latitude:</strong> {{ number_format($alert->latitude, 6) }}
                            </div>
                            <div class="col-md-6">
                                <strong>Longitude:</strong> {{ number_format($alert->longitude, 6) }}
                            </div>
                            @if($alert->accuracy)
                            <div class="col-md-6 mt-2">
                                <strong>Précision:</strong> {{ number_format($alert->accuracy, 2) }} mètres
                            </div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>

            <!-- Informations -->
            <div class="card">
                <div class="card-header">
                    <h5>Informations de l'alerte</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Type:</strong>
                            <p>
                                @if($alert->type == 'sos')
                                <span class="badge bg-danger">SOS Urgence</span>
                                @else
                                <span class="badge bg-warning">Alerte Médicale</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($alert->status == 'pending')
                                <span class="badge bg-warning">En attente</span>
                                @elseif($alert->status == 'in_progress')
                                <span class="badge bg-info">En cours</span>
                                @elseif($alert->status == 'resolved')
                                <span class="badge bg-success">Résolue</span>
                                @else
                                <span class="badge bg-secondary">Annulée</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    @if($alert->emergency_type)
                    <div class="mb-3">
                        <strong>Type d'urgence médicale:</strong>
                        <p>{{ $alert->emergency_type }}</p>
                    </div>
                    @endif

                    @if($alert->notes)
                    <div class="mb-3">
                        <strong>Notes:</strong>
                        <p>{{ $alert->notes }}</p>
                    </div>
                    @endif

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Créée le:</strong>
                            <p>{{ $alert->created_at->format('d/m/Y à H:i') }}</p>
                        </div>
                        @if($alert->resolved_at)
                        <div class="col-md-6">
                            <strong>Résolue le:</strong>
                            <p>{{ $alert->resolved_at->format('d/m/Y à H:i') }}</p>
                        </div>
                        @endif
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
                        <p>{{ $alert->user->name ?? 'N/A' }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Email:</strong>
                        <p>{{ $alert->user->email ?? 'N/A' }}</p>
                    </div>
                    @if($alert->user && $alert->user->phone)
                    <div class="mb-3">
                        <strong>Téléphone:</strong>
                        <p>{{ $alert->user->phone }}</p>
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
                    <form action="{{ route('admin.alerts.updateStatus', $alert) }}" method="POST" class="mb-3">
                        @csrf
                        @method('PUT')
                        <label class="form-label">Changer le statut</label>
                        <select name="status" class="form-select mb-2">
                            <option value="pending" {{ $alert->status == 'pending' ? 'selected' : '' }}>En attente</option>
                            <option value="in_progress" {{ $alert->status == 'in_progress' ? 'selected' : '' }}>En cours</option>
                            <option value="resolved" {{ $alert->status == 'resolved' ? 'selected' : '' }}>Résolue</option>
                            <option value="cancelled" {{ $alert->status == 'cancelled' ? 'selected' : '' }}>Annulée</option>
                        </select>
                        <textarea name="notes" class="form-control mb-2" rows="3" placeholder="Notes (optionnel)">{{ old('notes', $alert->notes) }}</textarea>
                        <button type="submit" class="btn btn-primary w-100">Mettre à jour</button>
                    </form>

                    <form action="{{ route('admin.alerts.assign', $alert) }}" method="POST">
                        @csrf
                        <label class="form-label">Assigner à</label>
                        <input type="text" name="assigned_to" class="form-control mb-2" placeholder="Service/Personne" required>
                        <textarea name="notes" class="form-control mb-2" rows="2" placeholder="Notes (optionnel)"></textarea>
                        <button type="submit" class="btn btn-success w-100">Assigner</button>
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
    var map = L.map('alertMap').setView([{{ $alert->latitude }}, {{ $alert->longitude }}], 15);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter un marqueur pour l'alerte
    var marker = L.marker([{{ $alert->latitude }}, {{ $alert->longitude }}], {
        icon: L.divIcon({
            className: 'alert-marker',
            html: '<div style="background: {{ $alert->type == "sos" ? "red" : "orange" }}; width: 30px; height: 30px; border-radius: 50%; border: 3px solid white; box-shadow: 0 2px 8px rgba(0,0,0,0.3);"></div>',
            iconSize: [30, 30]
        })
    }).addTo(map);

    marker.bindPopup("<strong>{{ $alert->type == 'sos' ? 'SOS' : 'Alerte Médicale' }}</strong><br>{{ $alert->address ?? 'Localisation' }}").openPopup();
</script>
@endpush
