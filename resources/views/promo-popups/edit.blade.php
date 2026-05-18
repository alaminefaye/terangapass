@extends('layouts.app')

@section('title', 'Modifier pop-up pub - Teranga Pass')

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <h4 class="fw-bold mb-4">
        <span class="text-muted fw-light">Pop-ups pub /</span> Modifier
    </h4>
    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.promo-popups.update', $promoPopup) }}" method="POST" enctype="multipart/form-data">
                @csrf
                @method('PUT')
                @include('promo-popups._form', ['promoPopup' => $promoPopup])
                <div class="d-flex justify-content-end gap-2 mt-3">
                    <a href="{{ route('admin.promo-popups.index') }}" class="btn btn-outline-secondary">Annuler</a>
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
