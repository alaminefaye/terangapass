@extends('layouts.app')

@section('title', 'Modifier une Notification - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Notifications /</span> Modifier
        </h4>
        <a href="{{ route('admin.notifications.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.notifications.update', $notification) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Type <span class="text-danger">*</span></label>
                        <select name="type" class="form-select @error('type') is-invalid @enderror" required>
                            <option value="sécurité" {{ old('type', $notification->type) == 'sécurité' ? 'selected' : '' }}>Sécurité</option>
                            <option value="météo" {{ old('type', $notification->type) == 'météo' ? 'selected' : '' }}>Météo</option>
                            <option value="circulation" {{ old('type', $notification->type) == 'circulation' ? 'selected' : '' }}>Circulation</option>
                            <option value="consignes_joj" {{ old('type', $notification->type) == 'consignes_joj' ? 'selected' : '' }}>Consignes JOJ</option>
                        </select>
                        @error('type')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Zone</label>
                        <select name="zone" class="form-select">
                            <option value="">Toutes les zones</option>
                            @foreach($zones as $zone)
                            <option value="{{ $zone->name }}" {{ old('zone', $notification->zone) == $zone->name ? 'selected' : '' }}>{{ $zone->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Titre <span class="text-danger">*</span></label>
                    <input type="text" name="title" class="form-control @error('title') is-invalid @enderror" value="{{ old('title', $notification->title) }}" required>
                    @error('title')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label">Description <span class="text-danger">*</span></label>
                    <textarea name="description" class="form-control @error('description') is-invalid @enderror" rows="5" required>{{ old('description', $notification->description) }}</textarea>
                    @error('description')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label">Date programmée (optionnel)</label>
                    <input type="datetime-local" name="scheduled_at" class="form-control" value="{{ old('scheduled_at', $notification->scheduled_at ? $notification->scheduled_at->format('Y-m-d\TH:i') : '') }}">
                    <small class="form-text text-muted">Laissez vide pour envoyer immédiatement</small>
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', $notification->is_active) ? 'checked' : '' }}>
                        <label class="form-check-label" for="is_active">
                            Notification active
                        </label>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.notifications.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Mettre à jour</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
