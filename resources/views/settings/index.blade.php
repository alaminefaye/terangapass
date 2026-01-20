@extends('layouts.app')

@section('title', 'Paramètres - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold py-3 mb-4">
        <span class="text-muted fw-light">Gestion /</span> Paramètres
    </h4>

    <div class="row">
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Paramètres système</h5>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.settings.update') }}" method="POST">
                        @csrf
                        @method('PUT')

                        <div class="mb-3">
                            <label class="form-label">Nom de l'application</label>
                            <input type="text" name="app_name" class="form-control" value="{{ config('app.name') }}" readonly>
                            <small class="text-muted">Modifiable dans le fichier .env</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">URL de l'application</label>
                            <input type="text" name="app_url" class="form-control" value="{{ config('app.url') }}" readonly>
                            <small class="text-muted">Modifiable dans le fichier .env</small>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Fuseau horaire</label>
                            <input type="text" name="timezone" class="form-control" value="{{ config('app.timezone') }}" readonly>
                            <small class="text-muted">Modifiable dans le fichier .env</small>
                        </div>

                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn btn-primary" disabled>
                                <i class="bx bx-save me-2"></i> Enregistrer
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <h5>Notifications</h5>
                </div>
                <div class="card-body">
                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" id="email_notifications" checked disabled>
                        <label class="form-check-label" for="email_notifications">
                            Notifications par email
                        </label>
                    </div>
                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" id="push_notifications" checked disabled>
                        <label class="form-check-label" for="push_notifications">
                            Notifications push
                        </label>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Informations</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <strong>Version:</strong>
                        <p>1.0.0</p>
                    </div>
                    <div class="mb-3">
                        <strong>Environnement:</strong>
                        <p>
                            <span class="badge bg-{{ app()->environment() === 'production' ? 'success' : 'warning' }}">
                                {{ app()->environment() }}
                            </span>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
