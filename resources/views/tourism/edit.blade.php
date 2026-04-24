@extends('layouts.app')

@section('title', 'Modifier un Point d\'Intérêt - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Tourisme /</span> Modifier
        </h4>
        <a href="{{ route('admin.tourism.index') }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.tourism.update', $tourism) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nom <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name', $tourism->name) }}" required>
                        @error('name')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Catégorie <span class="text-danger">*</span></label>
                        <select name="category" class="form-select @error('category') is-invalid @enderror" required>
                            <option value="hotel" {{ old('category', $tourism->category) == 'hotel' ? 'selected' : '' }}>🏨 Hôtel</option>
                            <option value="restaurant" {{ old('category', $tourism->category) == 'restaurant' ? 'selected' : '' }}>🍽️ Restaurant</option>
                            <option value="pharmacy" {{ old('category', $tourism->category) == 'pharmacy' ? 'selected' : '' }}>💊 Pharmacie</option>
                            <option value="hospital" {{ old('category', $tourism->category) == 'hospital' ? 'selected' : '' }}>🏥 Hôpital</option>
                            <option value="embassy" {{ old('category', $tourism->category) == 'embassy' ? 'selected' : '' }}>🏛️ Ambassade</option>
                        </select>
                        @error('category')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control @error('description') is-invalid @enderror" rows="3">{{ old('description', $tourism->description) }}</textarea>
                    @error('description')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="mb-3">
                    <label class="form-label">Adresse <span class="text-danger">*</span></label>
                    <input type="text" name="address" class="form-control @error('address') is-invalid @enderror" value="{{ old('address', $tourism->address) }}" required>
                    @error('address')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Latitude</label>
                        <input type="number" step="any" name="latitude" class="form-control @error('latitude') is-invalid @enderror" value="{{ old('latitude', $tourism->latitude) }}">
                        @error('latitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Longitude</label>
                        <input type="number" step="any" name="longitude" class="form-control @error('longitude') is-invalid @enderror" value="{{ old('longitude', $tourism->longitude) }}">
                        @error('longitude')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">Téléphone</label>
                        <input type="text" name="phone" class="form-control @error('phone') is-invalid @enderror" value="{{ old('phone', $tourism->phone) }}">
                        @error('phone')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-4 mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email', $tourism->email) }}">
                        @error('email')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="col-md-4 mb-3">
                        <label class="form-label">Site web</label>
                        <input type="url" name="website" class="form-control @error('website') is-invalid @enderror" value="{{ old('website', $tourism->website) }}">
                        @error('website')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">URL du logo</label>
                    <input type="url" name="logo_url" class="form-control @error('logo_url') is-invalid @enderror" value="{{ old('logo_url', $tourism->logo_url) }}">
                    @error('logo_url')
                    <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Photo icône (affichage dans l'app)</label>
                        <input type="file" name="icon" class="form-control @error('icon') is-invalid @enderror" accept="image/*">
                        @error('icon')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror

                        @if($tourism->icon_path)
                            <div class="mt-3 d-flex align-items-center gap-3">
                                <img src="{{ $tourism->icon_path }}" alt="Icon" style="width:72px;height:72px;object-fit:cover;border-radius:12px;">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="remove_icon" value="1" id="remove_icon">
                                    <label class="form-check-label" for="remove_icon">Supprimer l'icône</label>
                                </div>
                            </div>
                        @endif
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Ajouter des photos à la galerie</label>
                        <input type="file" name="photos[]" class="form-control @error('photos') is-invalid @enderror" accept="image/*" multiple>
                        @error('photos')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                        @error('photos.*')
                        <div class="invalid-feedback d-block">{{ $message }}</div>
                        @enderror

                        @if(is_array($tourism->photos) && count($tourism->photos) > 0)
                            <div class="mt-3">
                                <div class="mb-2">Photos actuelles (cocher pour supprimer)</div>
                                <div class="d-flex flex-wrap gap-2">
                                    @foreach($tourism->photos as $photoUrl)
                                        <label class="position-relative" style="cursor:pointer;">
                                            <img src="{{ $photoUrl }}" alt="Photo" style="width:72px;height:72px;object-fit:cover;border-radius:12px;">
                                            <input type="checkbox" name="remove_photos[]" value="{{ $photoUrl }}" class="form-check-input position-absolute" style="top:6px;left:6px;">
                                        </label>
                                    @endforeach
                                </div>
                                @error('remove_photos')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                                @enderror
                            </div>
                        @endif
                    </div>
                </div>

                <div class="mb-3">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active" {{ old('is_active', $tourism->is_active) ? 'checked' : '' }}>
                        <label class="form-check-label" for="is_active">
                            Point d'intérêt actif
                        </label>
                    </div>
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.tourism.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Mettre à jour</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
