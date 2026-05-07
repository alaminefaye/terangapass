@extends('layouts.app')

@section('title', 'Modifier un utilisateur - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion / Utilisateurs /</span> Modifier
        </h4>
        <a href="{{ route('admin.mobile-users.show', $user) }}" class="btn btn-outline-secondary">
            <i class="bx bx-arrow-back me-2"></i> Retour
        </a>
    </div>

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.mobile-users.update', $user) }}" method="POST">
                @csrf
                @method('PUT')

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nom <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name', $user->name) }}" required>
                        @error('name')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Email <span class="text-danger">*</span></label>
                        <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email', $user->email) }}" required autocomplete="off">
                        @error('email')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Téléphone <span class="text-danger">*</span></label>
                        <input type="text" name="phone" class="form-control @error('phone') is-invalid @enderror" value="{{ old('phone', $user->phone) }}" required placeholder="+221…">
                        @error('phone')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Pays (code ISO) <span class="text-danger">*</span></label>
                        <input type="text" name="country" maxlength="2" class="form-control @error('country') is-invalid @enderror" value="{{ old('country', $user->country) }}" required placeholder="SN">
                        @error('country')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Type <span class="text-danger">*</span></label>
                        <select name="user_type" class="form-select @error('user_type') is-invalid @enderror" required>
                            <option value="visitor" {{ old('user_type', $user->user_type) == 'visitor' ? 'selected' : '' }}>Visiteur</option>
                            <option value="athlete" {{ old('user_type', $user->user_type) == 'athlete' ? 'selected' : '' }}>Athlète</option>
                            <option value="citizen" {{ old('user_type', $user->user_type) == 'citizen' ? 'selected' : '' }}>Citoyen</option>
                        </select>
                        @error('user_type')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Langue <span class="text-danger">*</span></label>
                        <select name="language" class="form-select @error('language') is-invalid @enderror" required>
                            <option value="fr" {{ old('language', $user->language) == 'fr' ? 'selected' : '' }}>Français</option>
                            <option value="en" {{ old('language', $user->language) == 'en' ? 'selected' : '' }}>English</option>
                            <option value="es" {{ old('language', $user->language) == 'es' ? 'selected' : '' }}>Español</option>
                        </select>
                        @error('language')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nouveau mot de passe</label>
                        <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" autocomplete="new-password" placeholder="Laisser vide pour ne pas changer">
                        @error('password')
                        <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Confirmation du mot de passe</label>
                        <input type="password" name="password_confirmation" class="form-control" autocomplete="new-password">
                    </div>
                </div>

                <div class="mt-2">
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                    <a href="{{ route('admin.mobile-users.show', $user) }}" class="btn btn-outline-secondary">Annuler</a>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
