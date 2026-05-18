@php
    $popup = $promoPopup ?? null;
@endphp

<div class="row">
    <div class="col-md-6 mb-3">
        <label class="form-label">Titre interne <span class="text-danger">*</span></label>
        <input type="text" name="title" class="form-control @error('title') is-invalid @enderror"
               value="{{ old('title', $popup?->title) }}" required>
        @error('title')<div class="invalid-feedback">{{ $message }}</div>@enderror
    </div>
    <div class="col-md-6 mb-3">
        <label class="form-label">Annonceur / sponsor</label>
        <input type="text" name="sponsor_name" class="form-control"
               value="{{ old('sponsor_name', $popup?->sponsor_name) }}" placeholder="Ex. Orange, Wave…">
    </div>
</div>

<div class="mb-3">
    <label class="form-label">Visuel {{ $popup ? '' : '*' }}</label>
    <input type="file" name="image" class="form-control @error('image') is-invalid @enderror"
           accept="image/jpeg,image/png,image/webp" {{ $popup ? '' : 'required' }}>
    <small class="text-muted">Format portrait recommandé (ratio 4:5), max 5 Mo.</small>
    @error('image')<div class="invalid-feedback">{{ $message }}</div>@enderror
    @if($popup?->imageUrl())
    <div class="mt-2">
        <img src="{{ $popup->imageUrl() }}" alt="" class="img-fluid rounded" style="max-height:200px;">
    </div>
    @endif
</div>

<div class="row">
    <div class="col-md-8 mb-3">
        <label class="form-label">Lien au clic (optionnel)</label>
        <input type="url" name="link_url" class="form-control"
               value="{{ old('link_url', $popup?->link_url) }}" placeholder="https://…">
    </div>
    <div class="col-md-4 mb-3">
        <label class="form-label">Texte bouton</label>
        <input type="text" name="link_label" class="form-control"
               value="{{ old('link_label', $popup?->link_label ?? 'En savoir plus') }}">
    </div>
</div>

<div class="row">
    <div class="col-md-4 mb-3">
        <label class="form-label">Écran <span class="text-danger">*</span></label>
        <select name="placement" class="form-select" required>
            @foreach(['home' => 'Accueil', 'map' => 'Carte / Se déplacer', 'tourism' => 'Tourisme', 'all' => 'Tous'] as $k => $label)
                <option value="{{ $k }}" @selected(old('placement', $popup?->placement ?? 'home') === $k)>{{ $label }}</option>
            @endforeach
        </select>
    </div>
    <div class="col-md-4 mb-3">
        <label class="form-label">Priorité</label>
        <input type="number" name="priority" class="form-control" min="0" max="9999"
               value="{{ old('priority', $popup?->priority ?? 0) }}">
        <small class="text-muted">Plus élevé = affiché en premier.</small>
    </div>
    <div class="col-md-4 mb-3">
        <label class="form-label">Fréquence</label>
        <select name="frequency" class="form-select">
            <option value="once_per_day" @selected(old('frequency', $popup?->frequency ?? 'once_per_day') === 'once_per_day')>1× par jour max</option>
            <option value="every_open" @selected(old('frequency', $popup?->frequency) === 'every_open')>À chaque ouverture de l’écran</option>
            <option value="always" @selected(old('frequency', $popup?->frequency) === 'always')>Toujours (tests)</option>
        </select>
    </div>
</div>

<div class="row">
    <div class="col-md-6 mb-3">
        <label class="form-label">Début</label>
        <input type="datetime-local" name="starts_at" class="form-control"
               value="{{ old('starts_at', $popup?->starts_at?->format('Y-m-d\TH:i')) }}">
    </div>
    <div class="col-md-6 mb-3">
        <label class="form-label">Fin</label>
        <input type="datetime-local" name="ends_at" class="form-control"
               value="{{ old('ends_at', $popup?->ends_at?->format('Y-m-d\TH:i')) }}">
    </div>
</div>

<div class="mb-3">
    <div class="form-check">
        <input class="form-check-input" type="checkbox" name="is_active" value="1" id="is_active"
               @checked(old('is_active', $popup?->is_active ?? true))>
        <label class="form-check-label" for="is_active">Campagne active</label>
    </div>
</div>
