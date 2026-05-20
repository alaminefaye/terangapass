@extends('layouts.legal')

@section('title', 'Support')
@section('meta_description', 'Support and contact for the Teranga Pass app.')
@section('page_heading', 'Support')
@section('nav_label', 'Navigation')

@section('legal_nav')
    <a href="{{ route('legal.terms.en') }}">Terms of use</a>
    <a href="{{ route('legal.privacy.en') }}">Privacy policy</a>
    <a href="{{ route('legal.support') }}">Version française</a>
@endsection

@section('content')
    <p class="legal-meta">
        <strong>{{ $appName }}</strong> app — {{ $publisher }}<br>
        Website: <a href="https://www.terangapass.com">www.terangapass.com</a>
    </p>

    <p>
        <strong>{{ $appName }}</strong> helps visitors and residents in Senegal (map, tourism, YOG Dakar 2026, SOS alerts).
        Use this page to reach us for technical issues, account questions, or feedback.
    </p>

    <h2>Contact support</h2>
    <p>
        <strong>Email:</strong>
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a>
    </p>
    <p>
        Include your device, app version, and screenshots if possible.
        We usually reply within <strong>2–5 business days</strong>.
    </p>

    <h2>Emergencies</h2>
    <p>
        <strong>SOS</strong> and medical alert features do not replace official emergency services.
        In immediate danger in Senegal, call <strong>17</strong> (police) or <strong>18</strong> (fire / rescue).
    </p>

    <h2>Account & privacy</h2>
    <ul>
        <li><strong>Delete account</strong>: Profile → Delete my account (in-app confirmation required).</li>
        <li><strong>Privacy</strong>: see our <a href="{{ route('legal.privacy.en') }}">privacy policy</a>.</li>
        <li><strong>Terms</strong>: <a href="{{ route('legal.terms.en') }}">terms of use</a>.</li>
    </ul>

    <h2>Common issues</h2>
    <ul>
        <li><strong>Notifications</strong>: allow notifications for {{ $appName }} in iOS / Android settings.</li>
        <li><strong>Location</strong>: enable location for map, weather, and nearby alerts.</li>
        <li><strong>Sign-in</strong>: check your internet connection (Wi‑Fi or mobile data).</li>
    </ul>

    <h2>Partners & press</h2>
    <p>
        For partnerships, directory listings, or press inquiries, email
        <a href="mailto:{{ $contactEmail }}">{{ $contactEmail }}</a> with subject “Partnership” or “Press”.
    </p>
@endsection
