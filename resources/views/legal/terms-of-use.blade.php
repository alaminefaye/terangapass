@extends('layouts.legal')

@section('title', 'Conditions d\'utilisation')
@section('meta_description', 'Conditions générales d\'utilisation de l\'application mobile Teranga Pass.')
@section('page_heading', 'Conditions d\'utilisation')
@section('nav_label', 'Navigation légale')

@section('legal_nav')
    <a href="{{ route('legal.privacy') }}">Politique de confidentialité</a>
    <a href="{{ route('legal.terms.en') }}">English version</a>
@endsection

@section('content')
    <p class="legal-meta">
        Dernière mise à jour : {{ \Carbon\Carbon::parse($lastUpdated)->locale('fr')->isoFormat('D MMMM YYYY') }}<br>
        Éditeur : {{ $publisher }} — Contact : <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>

    <p>
        Les présentes conditions générales d'utilisation (ci-après les «&nbsp;CGU&nbsp;») régissent l'accès et l'utilisation
        de l'application mobile <strong>{{ $appName }}</strong> (ci-après l'«&nbsp;Application&nbsp;»), éditée par
        <strong>{{ $publisher }}</strong>. En installant ou en utilisant l'Application, vous acceptez sans réserve les CGU.
        Si vous n'acceptez pas ces conditions, vous ne devez pas utiliser l'Application.
    </p>

    <h2>1. Objet de l'Application</h2>
    <p>
        {{ $appName }} est une application d'information et de services destinée aux visiteurs et résidents, notamment
        dans le cadre d'événements et du tourisme au Sénégal. Elle peut proposer notamment&nbsp;: informations touristiques,
        cartographie, alertes et notifications, signalement d'incidents, fonction d'urgence (SOS), assistant d'information,
        contenus audio, et services connexes. L'Application ne remplace pas les services d'urgence officiels (police,
        pompiers, SAMU). En cas de danger immédiat, contactez les numéros d'urgence locaux.
    </p>

    <h2>2. Compte utilisateur</h2>
    <p>
        Certaines fonctionnalités nécessitent la création d'un compte. Vous vous engagez à fournir des informations exactes
        et à maintenir la confidentialité de vos identifiants. Vous êtes responsable de toute activité réalisée depuis votre
        compte. {{ $publisher }} peut suspendre ou supprimer un compte en cas de violation des CGU, d'usage frauduleux ou
        de comportement portant atteinte à la sécurité d'autrui.
    </p>

    <h2>3. Utilisation acceptable</h2>
    <p>Vous vous engagez à ne pas&nbsp;:</p>
    <ul>
        <li>utiliser l'Application à des fins illégales ou contraires à l'ordre public&nbsp;;</li>
        <li>émettre de fausses alertes SOS ou de signalements abusifs&nbsp;;</li>
        <li>tenter d'accéder sans autorisation aux systèmes, API ou données de {{ $publisher }}&nbsp;;</li>
        <li>publier ou transmettre des contenus diffamatoires, haineux, violents ou portant atteinte aux droits de tiers&nbsp;;</li>
        <li>contourner les mesures de sécurité ou perturber le fonctionnement du service.</li>
    </ul>

    <h2>4. Géolocalisation et permissions</h2>
    <p>
        L'Application peut demander l'accès à votre position, aux notifications push, à l'appareil photo ou au stockage
        selon les fonctionnalités utilisées. Ces permissions peuvent être gérées dans les réglages de votre téléphone.
        Le refus de certaines permissions peut limiter l'accès à des services (ex.&nbsp;: carte, alertes de proximité).
        Le traitement des données personnelles est décrit dans notre
        <a href="{{ route('legal.privacy') }}">politique de confidentialité</a>.
    </p>

    <h2>5. Alertes, SOS et signalements</h2>
    <p>
        Les fonctionnalités d'alerte et de signalement ont pour but d'améliorer la sécurité et l'information des utilisateurs.
        Elles ne garantissent pas une intervention immédiate des autorités ou des secours. {{ $publisher }} et ses partenaires
        s'efforcent de traiter les demandes de bonne foi, sans engagement de délai ni de résultat. Tout usage malveillant
        pourra faire l'objet de mesures (suspension, signalement aux autorités).
    </p>

    <h2>6. Contenus et propriété intellectuelle</h2>
    <p>
        L'Application, sa marque, son interface, ses textes, visuels et bases de données sont protégés par le droit de la
        propriété intellectuelle. Toute reproduction ou exploitation non autorisée est interdite. Les contenus tiers
        (partenaires, cartes, API) restent la propriété de leurs auteurs respectifs.
    </p>

    <h2>7. Disponibilité et évolutions</h2>
    <p>
        {{ $publisher }} s'efforce d'assurer la disponibilité de l'Application mais ne garantit pas un fonctionnement
        ininterrompu (maintenance, réseau, force majeure). Des mises à jour peuvent modifier ou retirer des fonctionnalités.
        Les CGU peuvent être modifiées&nbsp;; la date de mise à jour figure en tête de page. La poursuite de l'utilisation
        vaut acceptation des CGU modifiées.
    </p>

    <h2>8. Limitation de responsabilité</h2>
    <p>
        Dans les limites autorisées par la loi applicable, {{ $publisher }} ne pourra être tenue responsable des dommages
        indirects, pertes de données, préjudices résultant d'un mauvais usage de l'Application, d'informations inexactes
        provenant de tiers, ou d'un retard d'intervention des services publics. L'Application est fournie «&nbsp;en l'état&nbsp;».
    </p>

    <h2>9. Suppression de compte</h2>
    <p>
        Vous pouvez demander la suppression de votre compte depuis l'Application (profil) ou en écrivant à
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>. La suppression entraîne l'effacement ou l'anonymisation
        des données associées, sous réserve des obligations légales de conservation.
    </p>

    <h2>10. Droit applicable et litiges</h2>
    <p>
        Les présentes CGU sont régies par le droit sénégalais, sous réserve des dispositions impératives applicables dans
        votre pays de résidence. En cas de litige, une solution amiable sera recherchée avant toute action judiciaire.
        À défaut, les tribunaux compétents du Sénégal seront saisis, sauf disposition contraire impérative.
    </p>

    <h2>11. Contact</h2>
    <p>
        Pour toute question relative aux CGU&nbsp;:
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>.
    </p>
@endsection
