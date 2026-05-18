@extends('layouts.app')

@section('title', 'Nouveau pop-up pub - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold mb-4">
        <span class="text-muted fw-light">Pop-ups pub /</span> Nouvelle campagne
    </h4>
    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.promo-popups.store') }}" method="POST" enctype="multipart/form-data">
                @csrf
                @include('promo-popups._form')
                <div class="d-flex justify-content-end gap-2 mt-3">
                    <a href="{{ route('admin.promo-popups.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Publier</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
