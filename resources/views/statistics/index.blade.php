@extends('layouts.app')

@section('title', 'Statistiques Détaillées - Teranga Pass')

@push('vendor-css')
<link rel="stylesheet" href="{{ asset('assets/vendor/libs/apex-charts/apex-charts.css') }}" />
@endpush

@section('content')
<div class="container-xxl flex-grow-1 container-p-y">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="fw-bold py-3 mb-4">
            <span class="text-muted fw-light">Gestion /</span> Statistiques Détaillées
        </h4>
        <div class="d-flex gap-2">
            <form method="GET" action="{{ route('admin.statistics.index') }}" class="d-flex gap-2">
                <select name="period" class="form-select" style="width: auto;" onchange="this.form.submit()">
                    <option value="7" {{ $period == '7' ? 'selected' : '' }}>7 derniers jours</option>
                    <option value="30" {{ $period == '30' ? 'selected' : '' }}>30 derniers jours</option>
                    <option value="90" {{ $period == '90' ? 'selected' : '' }}>3 derniers mois</option>
                    <option value="365" {{ $period == '365' ? 'selected' : '' }}>1 an</option>
                </select>
            </form>
        </div>
    </div>

    <!-- Statistiques globales -->
    <div class="row mb-4">
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <div class="metric-label">Total Utilisateurs</div>
                    <div class="metric-value">{{ number_format($stats['total_users']) }}</div>
                    <div class="small text-muted">Actifs: {{ number_format($stats['active_users']) }}</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <div class="metric-label">Total Alertes</div>
                    <div class="metric-value">{{ number_format($stats['total_alerts']) }}</div>
                    <div class="small text-muted">SOS: {{ number_format($stats['sos_alerts']) }} | Médicale: {{ number_format($stats['medical_alerts']) }}</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <div class="metric-label">Signalements</div>
                    <div class="metric-value">{{ number_format($stats['total_incidents']) }}</div>
                </div>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card">
                <div class="card-body">
                    <div class="metric-label">Notifications</div>
                    <div class="metric-value">{{ number_format($stats['total_notifications']) }}</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Graphiques -->
    <div class="row mb-4">
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Alertes par jour</h5>
                </div>
                <div class="card-body">
                    <div id="alertsChart" style="height: 300px;"></div>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Signalements par jour</h5>
                </div>
                <div class="card-body">
                    <div id="incidentsChart" style="height: 300px;"></div>
                </div>
            </div>
        </div>
    </div>

    <div class="row mb-4">
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Alertes par type</h5>
                </div>
                <div class="card-body">
                    <div id="alertsByTypeChart" style="height: 300px;"></div>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Signalements par type</h5>
                </div>
                <div class="card-body">
                    <div id="incidentsByTypeChart" style="height: 300px;"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Répartition par pays -->
    <div class="row mb-4">
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Utilisateurs par pays</h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Pays</th>
                                    <th>Nombre</th>
                                    <th>Pourcentage</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($usersByCountry as $country)
                                <tr>
                                    <td>{{ $country->country }}</td>
                                    <td>{{ number_format($country->count) }}</td>
                                    <td>
                                        @php
                                        $percentage = $country->count > 0 ? ($country->count / $stats['total_users']) * 100 : 0;
                                        @endphp
                                        {{ number_format($percentage, 1) }}%
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-6 mb-4">
            <div class="card">
                <div class="card-header">
                    <h5>Partenaires par catégorie</h5>
                </div>
                <div class="card-body">
                    <div id="partnersChart" style="height: 300px;"></div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('vendor-js')
<script src="{{ asset('assets/vendor/libs/apex-charts/apexcharts.js') }}"></script>
@endpush

@push('page-js')
<script>
    // Graphique Alertes par jour
    var alertsOptions = {
        series: [{
            name: 'Alertes',
            data: [
                @for($i = 0; $i < 30; $i++)
                @php
                $date = now()->subDays(30 - $i)->format('Y-m-d');
                $count = $alertsByDay[$date] ?? 0;
                @endphp
                {{ $count }},
                @endfor
            ]
        }],
        chart: {
            type: 'line',
            height: 300
        },
        xaxis: {
            categories: [
                @for($i = 0; $i < 30; $i++)
                '{{ now()->subDays(30 - $i)->format("d/m") }}',
                @endfor
            ]
        },
        colors: ['#CE1126'],
        stroke: {
            curve: 'smooth'
        }
    };
    var alertsChart = new ApexCharts(document.querySelector("#alertsChart"), alertsOptions);
    alertsChart.render();

    // Graphique Signalements par jour
    var incidentsOptions = {
        series: [{
            name: 'Signalements',
            data: [
                @for($i = 0; $i < 30; $i++)
                @php
                $date = now()->subDays(30 - $i)->format('Y-m-d');
                $count = $incidentsByDay[$date] ?? 0;
                @endphp
                {{ $count }},
                @endfor
            ]
        }],
        chart: {
            type: 'line',
            height: 300
        },
        xaxis: {
            categories: [
                @for($i = 0; $i < 30; $i++)
                '{{ now()->subDays(30 - $i)->format("d/m") }}',
                @endfor
            ]
        },
        colors: ['#00853F'],
        stroke: {
            curve: 'smooth'
        }
    };
    var incidentsChart = new ApexCharts(document.querySelector("#incidentsChart"), incidentsOptions);
    incidentsChart.render();

    // Graphique Alertes par type
    var alertsByTypeOptions = {
        series: [{{ $alertsByType['sos'] ?? 0 }}, {{ $alertsByType['medical'] ?? 0 }}],
        chart: {
            type: 'donut',
            height: 300
        },
        labels: ['SOS', 'Médicale'],
        colors: ['#CE1126', '#FCD116']
    };
    var alertsByTypeChart = new ApexCharts(document.querySelector("#alertsByTypeChart"), alertsByTypeOptions);
    alertsByTypeChart.render();

    // Graphique Signalements par type
    var incidentsByTypeOptions = {
        series: [
            {{ $incidentsByType['perte'] ?? 0 }},
            {{ $incidentsByType['accident'] ?? 0 }},
            {{ $incidentsByType['suspect'] ?? 0 }}
        ],
        chart: {
            type: 'donut',
            height: 300
        },
        labels: ['Perte', 'Accident', 'Suspect'],
        colors: ['#FCD116', '#CE1126', '#00853F']
    };
    var incidentsByTypeChart = new ApexCharts(document.querySelector("#incidentsByTypeChart"), incidentsByTypeOptions);
    incidentsByTypeChart.render();

    // Graphique Partenaires par catégorie
    var partnersOptions = {
        series: [
            {{ $partnersByCategory['hotel'] ?? 0 }},
            {{ $partnersByCategory['restaurant'] ?? 0 }},
            {{ $partnersByCategory['pharmacy'] ?? 0 }},
            {{ $partnersByCategory['hospital'] ?? 0 }},
            {{ $partnersByCategory['embassy'] ?? 0 }}
        ],
        chart: {
            type: 'pie',
            height: 300
        },
        labels: ['Hôtel', 'Restaurant', 'Pharmacie', 'Hôpital', 'Ambassade'],
        colors: ['#00853F', '#FCD116', '#CE1126', '#FF6B6B', '#4ECDC4']
    };
    var partnersChart = new ApexCharts(document.querySelector("#partnersChart"), partnersOptions);
    partnersChart.render();
</script>
@endpush
