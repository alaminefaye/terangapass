@extends('layouts.app')

@section('title', 'Détails Navette - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Transport /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.transport.edit', $shuttle) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.transport.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations de la navette</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Nom:</strong>
                            <p>{{ $shuttle->name }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Type:</strong>
                            <p>
                                @if($shuttle->type == 'express')
                                <span class="badge bg-warning">Express</span>
                                @else
                                <span class="badge bg-info">Régulier</span>
                                @endif
                            </p>
                        </div>
                    </div>

                    @if($shuttle->description)
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $shuttle->description }}</p>
                    </div>
                    @endif

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Période:</strong>
                            <p>{{ $shuttle->start_date->format('d/m/Y') }} - {{ $shuttle->end_date->format('d/m/Y') }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Itinéraire:</strong>
                            <p>{{ $shuttle->start_location }}@if($shuttle->end_location) → {{ $shuttle->end_location }}@endif</p>
                        </div>
                    </div>

                    @if($shuttle->frequency_minutes)
                    <div class="mb-3">
                        <strong>Fréquence:</strong>
                        <p>Tous les {{ $shuttle->frequency_minutes }} minutes</p>
                    </div>
                    @endif

                    @if($shuttle->first_departure && $shuttle->last_departure)
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Premier départ:</strong>
                            <p>{{ $shuttle->first_departure->format('H:i') }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Dernier départ:</strong>
                            <p>{{ $shuttle->last_departure->format('H:i') }}</p>
                        </div>
                    </div>
                    @endif

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($shuttle->is_active)
                                <span class="badge bg-success">Actif</span>
                                @else
                                <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Itinéraire sécurisé:</strong>
                            <p>
                                @if($shuttle->is_secure_route)
                                <span class="badge bg-success">Oui</span>
                                @else
                                <span class="badge bg-secondary">Non</span>
                                @endif
                            </p>
                        </div>
                    </div>
                </div>
            </div>

            @if($shuttle->stops->count() > 0)
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Arrêts ({{ $shuttle->stops->count() }})</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Ordre</th>
                                    <th>Nom</th>
                                    <th>Adresse</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($shuttle->stops as $stop)
                                <tr>
                                    <td>{{ $stop->order }}</td>
                                    <td>{{ $stop->name }}</td>
                                    <td><small>{{ $stop->address ?? '-' }}</small></td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            @endif

            @if($shuttle->schedules->count() > 0)
            <div class="card">
                <div class="card-header">
                    <h5>Horaires ({{ $shuttle->schedules->count() }})</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Heure</th>
                                    <th>Jour</th>
                                    <th>Statut</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($shuttle->schedules as $schedule)
                                <tr>
                                    <td>{{ $schedule->departure_time->format('H:i') }}</td>
                                    <td>
                                        @if($schedule->day_of_week !== null)
                                        @php
                                        $days = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
                                        @endphp
                                        {{ $days[$schedule->day_of_week] ?? '-' }}
                                        @else
                                        Tous les jours
                                        @endif
                                    </td>
                                    <td>
                                        @if($schedule->is_active)
                                        <span class="badge bg-success">Actif</span>
                                        @else
                                        <span class="badge bg-secondary">Inactif</span>
                                        @endif
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
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
                        <strong>Créée le:</strong>
                        <p>{{ $shuttle->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifiée le:</strong>
                        <p>{{ $shuttle->updated_at->format('d/m/Y à H:i') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
