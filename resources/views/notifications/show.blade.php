@extends('layouts.app')

@section('title', 'Détails Notification - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Notifications /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.notifications.edit', $notification) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.notifications.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations de la notification</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Titre:</strong>
                        <p>{{ $notification->title }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $notification->description }}</p>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Type:</strong>
                            <p><span class="badge bg-info">{{ ucfirst($notification->type) }}</span></p>
                        </div>
                        <div class="col-md-6">
                            <strong>Zone:</strong>
                            <p>{{ $notification->zone ?? 'Toutes les zones' }}</p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($notification->is_active)
                                <span class="badge bg-success">Actif</span>
                                @else
                                <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Date programmée:</strong>
                            <p>{{ $notification->scheduled_at ? $notification->scheduled_at->format('d/m/Y H:i') : 'Immédiat' }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h5>Statistiques</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <strong>Envoyées:</strong>
                                <p class="h4">{{ number_format($notification->sent_count) }}</p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <strong>Vues:</strong>
                                <p class="h4">{{ number_format($notification->viewed_count) }}</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Actions</h5>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.notifications.send', $notification) }}" method="POST" class="mb-3">
                        @csrf
                        <button type="submit" class="btn btn-success w-100">
                            <i class="bx bx-send me-2"></i> Envoyer maintenant
                        </button>
                    </form>
                    <div class="mb-3">
                        <strong>Créée le:</strong>
                        <p>{{ $notification->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifiée le:</strong>
                        <p>{{ $notification->updated_at->format('d/m/Y à H:i') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
