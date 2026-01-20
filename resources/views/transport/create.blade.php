@extends('layouts.app')

@section('title', 'Créer une Navette - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Transport /</span> Créer
        </h4>
        <a href="{{ route('admin.transport.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.transport.store') }}" method="POST">
                @csrf

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nom <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name') }}" required>
                        @error('name')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Type <span class="text-danger">*</span></label>
                        <select name="type" class="form-select @error('type') is-invalid @enderror" required>
                            <option value="">Sélectionner un type</option>
                            <option value="regular" {{ old('type') == 'regular' ? 'selected' : '' }}>Régulier</option>
                            <option value="express" {{ old('type') == 'express' ? 'selected' : '' }}>Express</option>
                        </select>
                        @error('type')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control @error('description') is-invalid @enderror" rows="3">{{ old('description') }}</textarea>
                    @error('description')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Date début <span class="text-danger">*</span></label>
                        <input type="date" name="start_date" class="form-control @error('start_date') is-invalid @enderror" value="{{ old('start_date') }}" required>
                        @error('start_date')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Date fin <span class="text-danger">*</span></label>
                        <input type="date" name="end_date" class="form-control @error('end_date') is-invalid @enderror" value="{{ old('end_date') }}" required>
                        @error('end_date')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Point de départ <span class="text-danger">*</span></label>
                        <input type="text" name="start_location" class="form-control @error('start_location') is-invalid @enderror" value="{{ old('start_location') }}" required>
                        @error('start_location')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Point d'arrivée</label>
                        <input type="text" name="end_location" class="form-control @error('end_location') is-invalid @enderror" value="{{ old('end_location') }}">
                        @error('end_location')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-3 mb-3">
                        <label class="form-label">Latitude départ</label>
                        <input type="number" step="any" name="start_latitude" class="form-control @error('start_latitude') is-invalid @enderror" value="{{ old('start_latitude') }}">
                        @error('start_latitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Longitude départ</label>
                        <input type="number" step="any" name="start_longitude" class="form-control @error('start_longitude') is-invalid @enderror" value="{{ old('start_longitude') }}">
                        @error('start_longitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Latitude arrivée</label>
                        <input type="number" step="any" name="end_latitude" class="form-control @error('end_latitude') is-invalid @enderror" value="{{ old('end_latitude') }}">
                        @error('end_latitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-3 mb-3">
                        <label class="form-label">Longitude arrivée</label>
                        <input type="number" step="any" name="end_longitude" class="form-control @error('end_longitude') is-invalid @enderror" value="{{ old('end_longitude') }}">
                        @error('end_longitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Fréquence (minutes)</label>
                        <input type="number" name="frequency_minutes" class="form-control @error('frequency_minutes') is-invalid @enderror" value="{{ old('frequency_minutes') }}" placeholder="Ex: 20">
                        @error('frequency_minutes')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-4 mb-3">
                        <label class="form-label">Premier départ</label>
                        <input type="time" name="first_departure" class="form-control @error('first_departure') is-invalid @enderror" value="{{ old('first_departure') }}">
                        @error('first_departure')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-4 mb-3">
                        <label class="form-label">Dernier départ</label>
                        <input type="time" name="last_departure" class="form-control @error('last_departure') is-invalid @enderror" value="{{ old('last_departure') }}">
                        @error('last_departure')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="is_secure_route" value="1" id="is_secure_route" {{ old('is_secure_route', true) ? 'checked' : '' }}>
                            <label class="form-check-label" for="is_secure_route">
                                Itinéraire sécurisé
                            </label>
                        </div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', true) ? 'checked' : '' }}>
                            <label class="form-check-label" for="is_active">
                                Navette active
                            </label>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.transport.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Créer la navette</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
