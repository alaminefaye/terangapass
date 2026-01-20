@extends('layouts.app')

@section('title', 'Modifier une Annonce Audio - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Annonces Audio /</span> Modifier
        </h4>
        <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.audio-announcements.update', $audioAnnouncement) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Titre <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control @error('title') is-invalid @enderror" value="{{ old('title', $audioAnnouncement->title) }}" required>
                        @error('title')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Langue <span class="text-danger">*</span></label>
                        <select name="language" class="form-select @error('language') is-invalid @enderror" required>
                            <option value="fr" {{ old('language', $audioAnnouncement->language) == 'fr' ? 'selected' : '' }}>🇫🇷 Français</option>
                            <option value="en" {{ old('language', $audioAnnouncement->language) == 'en' ? 'selected' : '' }}>🇬🇧 Anglais</option>
                            <option value="es" {{ old('language', $audioAnnouncement->language) == 'es' ? 'selected' : '' }}>🇪🇸 Espagnol</option>
                        </select>
                        @error('language')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Description <span class="text-danger">*</span></label>
                    <textarea name="content" class="form-control @error('content') is-invalid @enderror" rows="5" required>{{ old('content', $audioAnnouncement->content) }}</textarea>
                    @error('content')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label">Fichier audio (optionnel)</label>
                    @if($audioAnnouncement->audio_url)
                    <div class="mb-2">
                        <audio controls class="w-100">
                            <source src="{{ asset($audioAnnouncement->audio_url) }}" type="audio/mpeg">
                            Votre navigateur ne supporte pas l'élément audio.
                        </audio>
                        <small class="text-muted d-block mt-1">Fichier actuel</small>
                    </div>
                    @endif
                    <input type="file" name="audio_file" class="form-control @error('audio_file') is-invalid @enderror" accept="audio/*">
                    <small class="form-text text-muted">Laisser vide pour conserver le fichier actuel. Formats acceptés: MP3, WAV, OGG, M4A (Max 10MB)</small>
                    @error('audio_file')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', $audioAnnouncement->is_active) ? 'checked' : '' }}>
                        <label class="form-check-label" for="is_active">
                            Annonce active
                        </label>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Mettre à jour</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
