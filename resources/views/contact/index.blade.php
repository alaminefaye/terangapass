@extends('layouts.app')

@section('title', 'Contact / Joindre - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Contact / Joindre
    </h4>

    <div class="row">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5>Formulaire de contact</h5>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.contact.store') }}" method="POST">
                        @csrf

                        <div class="mb-3">
                            <label class="form-label">Nom complet <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name') }}" required>
                            @error('name')
                            <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email') }}" required>
                            @error('email')
                            <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Sujet <span class="text-danger">*</span></label>
                            <input type="text" name="subject" class="form-control @error('subject') is-invalid @enderror" value="{{ old('subject') }}" required>
                            @error('subject')
                            <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Message <span class="text-danger">*</span></label>
                            <textarea name="message" class="form-control @error('message') is-invalid @enderror" rows="6" required>{{ old('message') }}</textarea>
                            @error('message')
                            <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <button type="submit" class="btn btn-primary">
                            <i class="bx bx-send me-2"></i> Envoyer le message
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Informations de contact</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Teranga Pass</strong>
                        <p class="mb-0">Centre Opérationnel de Sécurité et de Santé</p>
                    </div>
                    <div class="mb-3">
                        <strong>Email:</strong>
                        <p class="mb-0">contact@terangapass.sn</p>
                    </div>
                    <div class="mb-3">
                        <strong>Téléphone:</strong>
                        <p class="mb-0">+221 XX XXX XX XX</p>
                    </div>
                    <div class="mb-3">
                        <strong>Adresse:</strong>
                        <p class="mb-0">Dakar, Sénégal</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
