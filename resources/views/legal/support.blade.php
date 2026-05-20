@extends('layouts.legal')

@section('title', 'Assistance')
@section('meta_description', 'Assistance et contact pour l\'application Teranga Pass.')
@section('page_heading', 'Assistance')
@section('nav_label', 'Navigation')

@section('legal_nav')
    <a href="{{ route('legal.terms') }}">Conditions d'utilisation</a>
    <a href="{{ route('legal.privacy') }}">Politique de confidentialité</a>
    <a href="{{ route('legal.support.en') }}">English version</a>
@endsection

@section('content')
    <p class="legal-meta">
        Application <strong>{{ $appName }}</strong> — {{ $publisher }}<br>
        Site : <a href="https://www.terangapass.com">www.terangapass.com</a>
    </p>

    <p>
        Vous utilisez <strong>{{ $appName }}</strong> au Sénégal (carte, tourisme, JOJ Dakar 2026, alertes SOS).
        Cette page regroupe les moyens de nous contacter pour toute question technique, compte ou signalement.
    </p>

    <h2>Contact support</h2>
    <p>
        <strong>E-mail :</strong>
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>
    <p>
        Décrivez votre demande (appareil, version de l'app, capture d'écran si possible).
        Nous répondons en général sous <strong>2 à 5 jours ouvrés</strong>.
    </p>

    <h2>Urgences</h2>
    <p>
        Les fonctions <strong>SOS</strong> et <strong>alerte médicale</strong> de l'application ne remplacent pas
        les services d'urgence officiels. En cas de danger immédiat, appelez le <strong>17</strong> (police)
        ou le <strong>18</strong> (pompiers / secours) au Sénégal.
    </p>

    <h2>Compte et données</h2>
    <ul>
        <li><strong>Suppression de compte</strong> : Profil → Supprimer mon compte (confirmation requise dans l'app).</li>
        <li><strong>Données personnelles</strong> : voir notre
            <a href="{{ route('legal.privacy') }}">politique de confidentialité</a>.</li>
        <li><strong>Conditions d'utilisation</strong> :
            <a href="{{ route('legal.terms') }}">conditions d'utilisation</a>.</li>
    </ul>

    <h2>Problèmes fréquents</h2>
    <ul>
        <li><strong>Notifications</strong> : autorisez les notifications dans Réglages iOS / Android pour {{ $appName }}.</li>
        <li><strong>Localisation</strong> : activez la géolocalisation pour la carte, la météo et les alertes à proximité.</li>
        <li><strong>Connexion</strong> : vérifiez votre connexion Internet (Wi‑Fi ou données mobiles).</li>
    </ul>

    <h2>Partenaires & presse</h2>
    <p>
        Pour un partenariat, une annonce sur l'annuaire ou la presse, écrivez à
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a> avec l'objet « Partenariat » ou « Presse ».
    </p>
@endsection
