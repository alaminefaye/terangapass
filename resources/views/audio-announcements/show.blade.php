@extends('layouts.app')

@section('title', 'Détails Annonce Audio - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Annonces Audio /</span> Détails
        </h4>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.audio-announcements.edit', $audioAnnouncement) }}" class="btn btn-primary">
                <i class="bx bx-edit me-2"></i> Modifier
            </a>
            <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">
                <i class="bx bx-arrow-back me-2"></i> Retour
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations de l'annonce</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Titre:</strong>
                        <p>{{ $audioAnnouncement->title }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Description:</strong>
                        <p>{{ $audioAnnouncement->content }}</p>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <strong>Langue:</strong>
                            <p>
                                @if($audioAnnouncement->language == 'fr')
                                <span class="badge bg-info">🇫🇷 Français</span>
                                @elseif($audioAnnouncement->language == 'en')
                                <span class="badge bg-info">🇬🇧 Anglais</span>
                                @elseif($audioAnnouncement->language == 'es')
                                <span class="badge bg-info">🇪🇸 Espagnol</span>
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6">
                            <strong>Statut:</strong>
                            <p>
                                @if($audioAnnouncement->is_active)
                                <span class="badge bg-success">Actif</span>
                                @else
                                <span class="badge bg-secondary">Inactif</span>
                                @endif
                            </p>
                        </div>
                    </div>
                    <div class="row mb-3">
                        @if($audioAnnouncement->duration)
                        <div class="col-md-6">
                            <strong>Durée:</strong>
                            <p>{{ gmdate('i:s', $audioAnnouncement->duration) }}</p>
                        </div>
                        @endif
                        <div class="col-md-6">
                            <strong>Nombre de lectures:</strong>
                            <p class="h5">{{ number_format($audioAnnouncement->play_count) }}</p>
                        </div>
                    </div>
                </div>
            </div>

            @if($audioAnnouncement->audio_url)
            <div class="card">
                <div class="card-header">
                    <h5>Fichier audio</h5>
                </div>
                <div class="card-body">
                    <audio controls class="w-100">
                        <source src="{{ asset($audioAnnouncement->audio_url) }}" type="audio/mpeg">
                        Votre navigateur ne supporte pas l'élément audio.
                    </audio>
                    <div class="mt-3">
                        <strong>URL:</strong>
                        <p><a href="{{ asset($audioAnnouncement->audio_url) }}" target="_blank">{{ asset($audioAnnouncement->audio_url) }}</a></p>
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
                        <p>{{ $audioAnnouncement->created_at->format('d/m/Y à H:i') }}</p>
                    </div>
                    <div class="mb-3">
                        <strong>Modifiée le:</strong>
                        <p>{{ $audioAnnouncement->updated_at->format('d/m/Y à H:i') }}</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
