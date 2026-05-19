@extends('layouts.legal')

@section('title', 'Privacy Policy')
@section('meta_description', 'Privacy Policy for the Teranga Pass mobile application.')
@section('page_heading', 'Privacy Policy')
@section('nav_label', 'Legal navigation')

@section('legal_nav')
    <a href="{{ route('legal.terms.en') }}">Terms of Use</a>
    <a href="{{ route('legal.privacy') }}">Version française</a>
@endsection

@section('content')
    <p class="legal-meta">
        Last updated: {{ \Carbon\Carbon::parse($lastUpdated)->locale('en')->isoFormat('MMMM D, YYYY') }}<br>
        Controller: {{ $publisher }} — <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>

    <p>
        This policy explains how <strong>{{ $appName }}</strong> collects and processes your personal data when you use the mobile app.
    </p>

    <h2>1. Data collected</h2>
    <ul>
        <li><strong>Account</strong>: name, email, phone, language, preferences.</li>
        <li><strong>Location</strong>: GPS when you enable location services.</li>
        <li><strong>Safety</strong>: SOS alerts, incident reports, related history.</li>
        <li><strong>Technical</strong>: device identifiers, push tokens, logs.</li>
    </ul>

    <h2>2. Purposes</h2>
    <p>Service delivery, personalization, notifications, safety processing, app improvement, security, and legal compliance.</p>

    <h2>3. Legal bases</h2>
    <p>Contract performance, consent (where required), legitimate interests, and legal obligations.</p>

    <h2>4. Sharing</h2>
    <p>Data may be shared with technical providers (hosting, push) and partners or authorities when handling alerts. We do not sell your personal data.</p>

    <h2>5. Retention</h2>
    <p>Data is kept while your account is active, then deleted or anonymized unless longer retention is required by law.</p>

    <h2>6. Your rights</h2>
    <p>Contact <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a> to access, rectify, delete data, or withdraw consent.</p>

    <h2>7. Security</h2>
    <p>We implement appropriate technical and organizational measures to protect your data.</p>

    <h2>8. Contact</h2>
    <p><a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a></p>
@endsection
