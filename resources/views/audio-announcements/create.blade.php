@extends('layouts.app')

@section('title', 'Créer une Annonce Audio - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Annonces Audio /</span> Créer
        </h4>
        <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.audio-announcements.store') }}" method="POST" enctype="multipart/form-data">
                @csrf

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Titre <span class="text-danger">*</span></label>
                        <input type="text" name="title" class="form-control @error('title') is-invalid @enderror" value="{{ old('title') }}" required>
                        @error('title')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Langue <span class="text-danger">*</span></label>
                        <select name="language" class="form-select @error('language') is-invalid @enderror" required>
                            <option value="">Sélectionner une langue</option>
                            <option value="fr" {{ old('language') == 'fr' ? 'selected' : '' }}>🇫🇷 Français</option>
                            <option value="en" {{ old('language') == 'en' ? 'selected' : '' }}>🇬🇧 Anglais</option>
                            <option value="es" {{ old('language') == 'es' ? 'selected' : '' }}>🇪🇸 Espagnol</option>
                        </select>
                        @error('language')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Description <span class="text-danger">*</span></label>
                    <textarea name="content" class="form-control @error('content') is-invalid @enderror" rows="5" required>{{ old('content') }}</textarea>
                    @error('content')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label">Fichier audio <span class="text-danger">*</span></label>
                    <input type="file" name="audio_file" class="form-control @error('audio_file') is-invalid @enderror" accept="audio/*" required>
                    <small class="form-text text-muted">Formats acceptés: MP3, WAV, OGG, M4A (Max 10MB)</small>
                    @error('audio_file')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', true) ? 'checked' : '' }}>
                        <label class="form-check-label" for="is_active">
                            Annonce active
                        </label>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.audio-announcements.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Créer l'annonce</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
