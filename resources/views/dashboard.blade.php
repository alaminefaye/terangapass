@extends('layouts.app')

@section('title', 'Dashboard - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="{{ asset('assets/vendor/libs/apex-charts/apex-charts.css') }}" />
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<style>
    .metric-card {
        background: white;
        border-radius: 12px;
        padding: 16px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        margin-bottom: 0;
        height: 100%;
        display: flex;
        flex-direction: column;
    }
    .metric-card-wrapper {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        align-content: flex-start;
    }
    .metric-card-wrapper .col-md-6 {
        display: flex;
        flex-direction: column;
        flex: 0 0 calc(50% - 6px);
        margin-bottom: 0;
        min-height: 150px;
    }
    .metric-value {
        font-size: 28px;
        font-weight: bold;
        color: #1a1a1a;
        margin: 8px 0;
    }
    .metric-label {
        font-size: 14px;
        color: #6b7280;
        margin-bottom: 8px;
    }
    .metric-change {
        font-size: 12px;
        font-weight: 600;
    }
    .metric-change.positive { color: #10b981; }
    .metric-change.negative { color: #ef4444; }
    #map {
        height: 500px;
        border-radius: 12px;
        margin-top: 0;
    }
    .chart-container {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    .table-container {
        background: white;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
</style>
@endpush

@section('content')
<!-- Première ligne : Carte à gauche, Widgets à droite -->
<div class="row mb-4">
    <!-- Carte (colonne gauche) -->
    <div class="col-lg-6 mb-4">
        <div class="chart-container">
            <h5 class="mb-3">Carte de bord</h5>
            <div id="map"></div>
            <div class="d-flex justify-content-between align-items-center mt-3">
                <div class="d-flex gap-3">
                    <span><span class="badge bg-danger">SOS {{ count($mapData['sos']) }}</span></span>
                    <span><span class="badge bg-primary">Alertes</span></span>
                    <span><span class="badge bg-warning">Hôtels</span></span>
                    <span><span class="badge bg-success">Restos -{{ count($mapData['restaurants']) }}</span></span>
                </div>
                <div class="progress" style="width: 150px; height: 8px;">
                    <div class="progress-bar bg-success" style="width: 68.8%"></div>
                </div>
                <span class="small">68.8%</span>
            </div>
        </div>
    </div>

    <!-- Widgets de métriques (colonne droite) -->
    <div class="col-lg-6 mb-4">
        <div class="row metric-card-wrapper">
            <!-- Mesures audio -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Mesures audio</div>
                    <div class="metric-value">{{ number_format($stats['audio_announcements']) }}</div>
                    <div class="d-flex align-items-center">
                        <i class="bx bx-volume-full text-success fs-4 me-2"></i>
                        <span class="small text-muted">Audio notifications énctáir S-5%</span>
                    </div>
                </div>
            </div>

            <!-- Alertes SOS -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Alertes SOS</div>
                    <div class="metric-value">{{ number_format($stats['sos_alerts']) }}</div>
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="metric-change positive">+{{ $variations['sos_increase'] }}%</span>
                            <div class="small text-muted">Alertes ouvertes patte (Dakar: 3.3%)</div>
                        </div>
                        <i class="bx bx-error-circle text-danger fs-4"></i>
                    </div>
                </div>
            </div>

            <!-- Notifications envoyées -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Notifications envoyées</div>
                    <div class="metric-value">{{ number_format($stats['notifications_sent']) }}</div>
                    <div class="d-flex align-items-center">
                        <i class="bx bx-bell text-primary fs-4 me-2"></i>
                        <span class="small text-muted">Notifications envoyées</span>
                    </div>
                </div>
            </div>

            <!-- Signalements d'incidents -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Signalements d'incidents</div>
                    <div class="metric-value">{{ number_format($stats['incidents']) }}</div>
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <span class="metric-change positive">+{{ $variations['incidents_increase'] }}%</span>
                            <div class="small text-muted">Perte, accident, attucatión suspecte</div>
                        </div>
                        <i class="bx bx-right-arrow-alt text-primary"></i>
                    </div>
                </div>
            </div>

            <!-- Publicité sponsors -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Publicité sponsors</div>
                    <div class="metric-value">{{ number_format($stats['sponsor_ads']) }}</div>
                    <div class="small text-muted">CTR: 11%</div>
                    <div class="progress mt-2" style="height: 4px;">
                        <div class="progress-bar bg-warning" style="width: 11%"></div>
                    </div>
                </div>
            </div>

            <!-- Utilisateurs JOJ -->
            <div class="col-md-6 mb-3">
                <div class="metric-card">
                    <div class="metric-label">Utilisateurs JOJ</div>
                    <div class="metric-value">{{ number_format($stats['total_users']) }}</div>
                    <div class="small text-muted">
                        @foreach($usersByCountry->take(2) as $country)
                        {{ $country->country }}: {{ number_format($country->count) }}@if(!$loop->last), @endif
                        @endforeach
                    </div>
                </div>
            </div>
        </div>
    </div>
                            </div>

<!-- Deuxième ligne : Tableaux et Graphiques -->
<div class="row mb-4">
    <!-- Notifications/Signalements géolocalisés -->
    <div class="col-lg-6 mb-4">
        <div class="table-container">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">Notifications / Signalements géolocalisés</h5>
                <button class="btn btn-sm btn-outline-primary">Voir Carte</button>
                                </div>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Localisation</th>
                            <th>Incidents</th>
                            <th>Alertes</th>
                            <th>Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($geolocatedData as $data)
                        <tr>
                            <td>{{ $data['site'] }}</td>
                            <td>{{ $data['incidents'] }}</td>
                            <td>{{ $data['alerts'] }}</td>
                            <td class="fw-bold">{{ $data['total'] }}</td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            <div class="d-flex justify-content-center mt-3">
                <nav>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                    </ul>
                </nav>
                                </div>
                            </div>
                        </div>

<!-- Graphiques -->
<div class="row mb-4">
    <!-- Annonces et alertes -->
    <div class="col-lg-6 mb-4">
        <div class="chart-container">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">Annonces et alertes (sem)</h5>
                <button class="btn btn-sm btn-link"><i class="bx bx-refresh"></i></button>
            </div>
            <div id="announcementsChart" style="height: 300px;"></div>
                    </div>
                </div>

    <!-- Sources de trafic -->
    <div class="col-lg-6 mb-4">
        <div class="chart-container">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="mb-0">Sources de trafic (hebdo -noki AOZ):1</h5>
                <button class="btn btn-sm btn-outline-primary">Serdiós</button>
            </div>
            <div id="trafficChart" style="height: 300px;"></div>
        </div>
    </div>
</div>
@endsection

@push('vendor-js')
<script src="{{ asset('assets/vendor/libs/apex-charts/apexcharts.js') }}"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
@endpush

@push('page-js')
<script>
    // Initialiser la carte
    var map = L.map('map').setView([14.7167, -17.4677], 12); // Dakar
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // Ajouter les marqueurs
    @foreach($mapData['sos'] as $sos)
    L.marker([{{ $sos->latitude }}, {{ $sos->longitude }}], {
        icon: L.divIcon({
            className: 'sos-marker',
            html: '<div style="background: red; width: 20px; height: 20px; border-radius: 50%; border: 2px solid white;"></div>',
            iconSize: [20, 20]
        })
    }).addTo(map);
    @endforeach

    @foreach($mapData['hotels'] as $hotel)
    L.marker([{{ $hotel->latitude }}, {{ $hotel->longitude }}], {
        icon: L.divIcon({
            className: 'hotel-marker',
            html: '<div style="background: orange; width: 15px; height: 15px; border-radius: 50%; border: 2px solid white;"></div>',
            iconSize: [15, 15]
        })
    }).addTo(map);
    @endforeach

    @foreach($mapData['restaurants'] as $restaurant)
    L.marker([{{ $restaurant->latitude }}, {{ $restaurant->longitude }}], {
        icon: L.divIcon({
            className: 'restaurant-marker',
            html: '<div style="background: green; width: 15px; height: 15px; border-radius: 50%; border: 2px solid white;"></div>',
            iconSize: [15, 15]
        })
    }).addTo(map);
    @endforeach

    // Graphique Annonces et alertes
    var announcementsOptions = {
        series: [{
            name: 'Messages audio',
            data: [@foreach($chartData['announcements_week'] as $day){{ $day['audio'] }},@endforeach]
        }, {
            name: 'Alertes / emails',
            data: [@foreach($chartData['announcements_week'] as $day){{ $day['alerts'] }},@endforeach]
        }],
        chart: {
            type: 'line',
            height: 300
        },
        colors: ['#FCD116', '#00853F'],
        xaxis: {
            categories: [@foreach($chartData['announcements_week'] as $day)'{{ $day['date'] }}',@endforeach]
        },
        stroke: {
            curve: 'smooth'
        }
    };
    var announcementsChart = new ApexCharts(document.querySelector("#announcementsChart"), announcementsOptions);
    announcementsChart.render();

    // Graphique Sources de trafic
    var trafficOptions = {
        series: [
            @foreach($chartData['traffic_sources']['sources'] as $index => $source)
            {
                name: '{{ $source }}',
                data: [@foreach($chartData['traffic_sources']['data'] as $day){{ $day[$source] }},@endforeach]
            }@if(!$loop->last),@endif
            @endforeach
        ],
        chart: {
            type: 'line',
            height: 300
        },
        colors: ['#00853F', '#CE1126', '#0066CC', '#FCD116'],
        xaxis: {
            categories: [@foreach($chartData['traffic_sources']['data'] as $day)'{{ $day['date'] }}',@endforeach]
        },
        stroke: {
            curve: 'smooth'
        }
    };
    var trafficChart = new ApexCharts(document.querySelector("#trafficChart"), trafficOptions);
    trafficChart.render();
</script>
@endpush
