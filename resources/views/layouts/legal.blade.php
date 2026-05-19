<!DOCTYPE html>
<html lang="{{ $locale ?? 'fr' }}">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>@yield('title') — {{ $appName ?? config('app.name', 'Teranga Pass') }}</title>
    <meta name="description" content="@yield('meta_description')" />
    <meta name="robots" content="index, follow" />
    <link rel="icon" type="image/png" href="{{ route('brand.terangpass-logo') }}" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <style>
        :root {
            --tp-green: #00853f;
            --tp-green-dark: #04581f;
            --tp-text: #1a1f2e;
            --tp-muted: #6b7280;
            --tp-border: #e5dfd3;
            --tp-bg: #faf7f0;
            --tp-card: #ffffff;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: 'Public Sans', system-ui, sans-serif;
            color: var(--tp-text);
            background: var(--tp-bg);
            line-height: 1.65;
        }
        .legal-header {
            background: linear-gradient(135deg, var(--tp-green-dark), var(--tp-green));
            color: #fff;
            padding: 1.25rem 1rem;
        }
        .legal-header-inner {
            max-width: 820px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        .legal-header img { height: 44px; width: auto; }
        .legal-header h1 {
            margin: 0;
            font-size: 1.25rem;
            font-weight: 700;
        }
        .legal-header p {
            margin: 0.2rem 0 0;
            font-size: 0.85rem;
            opacity: 0.9;
        }
        .legal-wrap {
            max-width: 820px;
            margin: 0 auto;
            padding: 1.5rem 1rem 3rem;
        }
        .legal-card {
            background: var(--tp-card);
            border: 1px solid var(--tp-border);
            border-radius: 14px;
            padding: 1.75rem 1.5rem;
            box-shadow: 0 8px 24px rgba(26, 31, 46, 0.06);
        }
        .legal-meta {
            font-size: 0.875rem;
            color: var(--tp-muted);
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--tp-border);
        }
        .legal-card h2 {
            font-size: 1.05rem;
            margin: 1.75rem 0 0.6rem;
            color: var(--tp-green-dark);
        }
        .legal-card h2:first-of-type { margin-top: 0; }
        .legal-card p, .legal-card li { font-size: 0.95rem; }
        .legal-card ul { padding-left: 1.25rem; }
        .legal-card a { color: var(--tp-green-dark); }
        .legal-nav {
            margin-top: 1.5rem;
            font-size: 0.875rem;
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem 1.25rem;
        }
        .legal-nav a { color: var(--tp-green-dark); text-decoration: none; font-weight: 600; }
        .legal-nav a:hover { text-decoration: underline; }
        .legal-footer {
            text-align: center;
            font-size: 0.8rem;
            color: var(--tp-muted);
            margin-top: 2rem;
        }
    </style>
</head>
<body>
    <header class="legal-header">
        <div class="legal-header-inner">
            <img src="{{ route('brand.terangpass-logo') }}" alt="{{ $appName ?? 'Teranga Pass' }}" />
            <div>
                <h1>@yield('page_heading')</h1>
                <p>{{ $appName ?? config('app.name', 'Teranga Pass') }}</p>
            </div>
        </div>
    </header>

    <main class="legal-wrap">
        <article class="legal-card">
            @yield('content')
        </article>

        <nav class="legal-nav" aria-label="@yield('nav_label', 'Legal')">
            @yield('legal_nav')
        </nav>

        <p class="legal-footer">&copy; {{ date('Y') }} {{ $publisher ?? 'Teranga Pass' }}</p>
    </main>
</body>
</html>
