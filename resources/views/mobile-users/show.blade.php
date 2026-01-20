@extends('layouts.app')

@section('title', 'Détails Utilisateur - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Utilisateurs /</span> Détails
        </h4>
        <a href="{{ route('admin.mobile-users.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="row">
        <div class="col-md-8">
            <!-- Informations utilisateur -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations personnelles</h5>
                </div>
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Nom:</strong>
                            <p>{{ $user->name }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Email:</strong>
                            <p>{{ $user->email }}</p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Téléphone:</strong>
                            <p>{{ $user->phone ?? 'Non renseigné' }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Pays:</strong>
                            <p>{{ $user->country ?? 'Non renseigné' }}</p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Type d'utilisateur:</strong>
                            <p>
                                @if($user->user_type == 'athlete')
                                <span class="badge bg-info">Athlète</span>
                                @elseif($user->user_type == 'visitor')
                                <span class="badge bg-success">Visiteur</span>
                                @elseif($user->user_type == 'citizen')
                                <span class="badge bg-primary">Citoyen</span>
                                @else
                                <span class="badge bg-secondary">Non défini</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Langue:</strong>
                            <p>{{ strtoupper($user->language ?? 'FR') }}</p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Inscription:</strong>
                            <p>{{ $user->created_at->format('d/m/Y à H:i') }}</p>
                        </div>
                        <div class="col-md-6">
                            <strong>Dernière activité:</strong>
                            <p>{{ $user->last_active_at ? $user->last_active_at->format('d/m/Y à H:i') : 'Jamais' }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Statistiques -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Statistiques</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-3 text-center mb-3">
                            <div class="h4 text-danger">{{ $stats['total_alerts'] }}</div>
                            <small class="text-muted">Total Alertes</small>
                        </div>
                        <div class="col-md-3 text-center mb-3">
                            <div class="h4 text-danger">{{ $stats['sos_alerts'] }}</div>
                            <small class="text-muted">SOS</small>
                        </div>
                        <div class="col-md-3 text-center mb-3">
                            <div class="h4 text-warning">{{ $stats['medical_alerts'] }}</div>
                            <small class="text-muted">Médicales</small>
                        </div>
                        <div class="col-md-3 text-center mb-3">
                            <div class="h4 text-primary">{{ $stats['total_incidents'] }}</div>
                            <small class="text-muted">Signalements</small>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Historique Alertes -->
            <div class="card mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Historique des alertes</h5>
                    <span class="badge bg-danger">{{ $user->alerts->count() }}</span>
                </div>
                <div class="card-body">
                    @if($user->alerts->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Statut</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($user->alerts as $alert)
                                <tr>
                                    <td>
                                        @if($alert->type == 'sos')
                                        <span class="badge bg-danger">SOS</span>
                                        @else
                                        <span class="badge bg-warning">Médicale</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($alert->status == 'resolved')
                                        <span class="badge bg-success">Résolue</span>
                                        @elseif($alert->status == 'in_progress')
                                        <span class="badge bg-info">En cours</span>
                                        @else
                                        <span class="badge bg-warning">En attente</span>
                                        @endif
                                    </td>
                                    <td>{{ $alert->created_at->format('d/m/Y H:i') }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    @else
                    <p class="text-muted mb-0">Aucune alerte enregistrée</p>
                    @endif
                </div>
            </div>

            <!-- Historique Signalements -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">Historique des signalements</h5>
                    <span class="badge bg-warning">{{ $user->incidents->count() }}</span>
                </div>
                <div class="card-body">
                    @if($user->incidents->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-sm">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Statut</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($user->incidents as $incident)
                                <tr>
                                    <td>
                                        @if($incident->type == 'perte')
                                        <span class="badge bg-warning">Perte</span>
                                        @elseif($incident->type == 'accident')
                                        <span class="badge bg-danger">Accident</span>
                                        @else
                                        <span class="badge bg-info">Suspect</span>
                                        @endif
                                    </td>
                                    <td>
                                        @if($incident->status == 'resolved')
                                        <span class="badge bg-success">Résolu</span>
                                        @elseif($incident->status == 'validated')
                                        <span class="badge bg-info">Validé</span>
                                        @else
                                        <span class="badge bg-warning">En attente</span>
                                        @endif
                                    </td>
                                    <td>{{ $incident->created_at->format('d/m/Y H:i') }}</td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    @else
                    <p class="text-muted mb-0">Aucun signalement enregistré</p>
                    @endif
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Actions</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Tokens de device:</strong>
                        <p>{{ $user->deviceTokens->count() }} appareil(s) enregistré(s)</p>
                    </div>
                    <div class="mb-3">
                        <strong>Dernière activité:</strong>
                        <p>{{ $user->last_active_at ? $user->last_active_at->diffForHumans() : 'Jamais' }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
