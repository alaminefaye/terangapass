@extends('layouts.legal')

@section('title', 'Politique de confidentialité')
@section('meta_description', 'Politique de confidentialité de l\'application Teranga Pass.')
@section('page_heading', 'Politique de confidentialité')
@section('nav_label', 'Navigation légale')

@section('legal_nav')
    <a href="{{ route('legal.terms') }}">Conditions d'utilisation</a>
    <a href="{{ route('legal.privacy.en') }}">English version</a>
@endsection

@section('content')
    <p class="legal-meta">
        Dernière mise à jour : {{ \Carbon\Carbon::parse($lastUpdated)->locale('fr')->isoFormat('D MMMM YYYY') }}<br>
        Responsable : {{ $publisher }} — <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>

    <p>
        La présente politique décrit comment <strong>{{ $appName }}</strong> collecte et traite vos données personnelles
        dans le cadre de l'utilisation de l'application mobile.
    </p>

    <h2>1. Données collectées</h2>
    <ul>
        <li><strong>Compte</strong> : nom, e-mail, téléphone, langue, préférences.</li>
        <li><strong>Localisation</strong> : position GPS lorsque vous activez la géolocalisation (carte, météo, alertes).</li>
        <li><strong>Sécurité</strong> : contenus liés aux alertes SOS, signalements, historique associé.</li>
        <li><strong>Technique</strong> : identifiant d'appareil, jetons de notification push, journaux techniques.</li>
    </ul>

    <h2>2. Finalités</h2>
    <p>
        Fourniture du service, personnalisation, notifications utiles, traitement des urgences et signalements,
        amélioration de l'Application, sécurité et respect des obligations légales.
    </p>

    <h2>3. Base légale</h2>
    <p>
        Exécution du contrat (utilisation de l'App), consentement (géolocalisation, notifications lorsque requis),
        intérêt légitime (sécurité, amélioration du service) et obligations légales.
    </p>

    <h2>4. Partage</h2>
    <p>
        Les données peuvent être partagées avec des prestataires techniques (hébergement, notifications push) et, le cas
        échéant, avec des partenaires ou autorités dans le cadre du traitement des alertes. Nous ne vendons pas vos données
        personnelles.
    </p>

    <h2>5. Durée de conservation</h2>
    <p>
        Les données sont conservées pendant la durée d'utilisation du compte, puis supprimées ou anonymisées après suppression,
        sauf obligation légale de conservation plus longue.
    </p>

    <h2>6. Vos droits</h2>
    <p>
        Vous pouvez accéder, rectifier ou supprimer vos données, retirer votre consentement et vous opposer à certains
        traitements en nous contactant à <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a> ou via les réglages
        de l'Application.
    </p>

    <h2>7. Sécurité</h2>
    <p>
        Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données.
    </p>

    <h2>8. Contact</h2>
    <p>
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>
@endsection
