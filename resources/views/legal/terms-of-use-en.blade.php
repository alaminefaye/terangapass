@extends('layouts.legal')

@section('title', 'Terms of Use')
@section('meta_description', 'Terms of Use for the Teranga Pass mobile application.')
@section('page_heading', 'Terms of Use')
@section('nav_label', 'Legal navigation')

@section('legal_nav')
    <a href="{{ route('legal.privacy.en') }}">Privacy Policy</a>
    <a href="{{ route('legal.terms') }}">Version française</a>
@endsection

@section('content')
    <p class="legal-meta">
        Last updated: {{ \Carbon\Carbon::parse($lastUpdated)->locale('en')->isoFormat('MMMM D, YYYY') }}<br>
        Publisher: {{ $publisher }} — Contact: <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>

    <p>
        These Terms of Use govern access to and use of the <strong>{{ $appName }}</strong> mobile application
        (the "App"), published by <strong>{{ $publisher }}</strong>. By installing or using the App, you agree to these Terms.
        If you do not agree, do not use the App.
    </p>

    <h2>1. Purpose</h2>
    <p>
        {{ $appName }} provides information and services for visitors and residents, including tourism content, maps,
        alerts, incident reporting, emergency (SOS) features, and related tools. The App does not replace official emergency
        services. In immediate danger, call local emergency numbers.
    </p>

    <h2>2. Account</h2>
    <p>
        Some features require an account. You must provide accurate information and keep your credentials secure. You are
        responsible for activity under your account. {{ $publisher }} may suspend or delete accounts for violations or abuse.
    </p>

    <h2>3. Acceptable use</h2>
    <ul>
        <li>No illegal use or false SOS / abusive reports;</li>
        <li>No unauthorized access to systems or data;</li>
        <li>No harmful, defamatory, or infringing content;</li>
        <li>No attempt to disrupt the service or bypass security.</li>
    </ul>

    <h2>4. Location &amp; permissions</h2>
    <p>
        The App may request location, notifications, camera, or storage access depending on features used. See our
        <a href="{{ route('legal.privacy.en') }}">Privacy Policy</a> for data processing details.
    </p>

    <h2>5. Alerts &amp; SOS</h2>
    <p>
        Alert and reporting features aim to improve safety and information. They do not guarantee immediate response by
        authorities. Misuse may lead to suspension or reporting to authorities.
    </p>

    <h2>6. Intellectual property</h2>
    <p>
        The App, brand, UI, and content are protected. Unauthorized copying or exploitation is prohibited. Third-party
        content remains the property of respective owners.
    </p>

    <h2>7. Availability</h2>
    <p>
        We strive to keep the App available but do not guarantee uninterrupted service. Features may change. Continued use
        after updates constitutes acceptance of revised Terms.
    </p>

    <h2>8. Limitation of liability</h2>
    <p>
        To the extent permitted by law, {{ $publisher }} is not liable for indirect damages, third-party inaccuracies, or
        delays by public services. The App is provided "as is".
    </p>

    <h2>9. Account deletion</h2>
    <p>
        You may delete your account from the App (profile) or by emailing
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>.
    </p>

    <h2>10. Governing law</h2>
    <p>
        These Terms are governed by the laws of Senegal, subject to mandatory consumer protections in your country of residence.
    </p>

    <h2>11. Contact</h2>
    <p>
        Questions: <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>.
    </p>
@endsection
