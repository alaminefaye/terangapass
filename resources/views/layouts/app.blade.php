<!DOCTYPE html>
<html lang="en" class="light-style layout-menu-fixed" dir="ltr" data-theme="theme-default" data-assets-path="{{ asset('assets/') }}" data-template="vertical-menu-template-free">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0" />
    <title>@yield('title', 'Dashboard') - {{ config('app.name') }}</title>
    <meta name="description" content="@yield('description', '')" />
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="{{ asset('assets/img/favicon/favicon.ico') }}" />
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Public+Sans:ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet" />
    
    <!-- Icons -->
    <link rel="stylesheet" href="{{ asset('assets/vendor/fonts/boxicons.css') }}" />
    
    <!-- Core CSS -->
    <link rel="stylesheet" href="{{ asset('assets/vendor/css/core.css') }}" class="template-customizer-core-css" />
    <link rel="stylesheet" href="{{ asset('assets/vendor/css/theme-default.css') }}" class="template-customizer-theme-css" />
    <link rel="stylesheet" href="{{ asset('assets/css/demo.css') }}" />
    
    <!-- Vendors CSS -->
    <link rel="stylesheet" href="{{ asset('assets/vendor/libs/perfect-scrollbar/perfect-scrollbar.css') }}" />
    @stack('vendor-css')
    
    <!-- Page CSS -->
    @stack('page-css')
    
    <!-- Helpers -->
    <script src="{{ asset('assets/vendor/js/helpers.js') }}"></script>
    <script src="{{ asset('assets/js/config.js') }}"></script>
</head>

<body>
    <!-- Layout wrapper -->
    <div class="layout-wrapper layout-content-navbar">
        <div class="layout-container">
            <!-- Menu -->
            <aside id="layout-menu" class="layout-menu menu-vertical menu bg-menu-theme">
                <div class="app-brand demo">
                    <a href="{{ route('admin.dashboard') }}" class="app-brand-link">
                        <span class="app-brand-logo demo">
                            <div class="senegal-flag" style="display: inline-flex; width: 30px; height: 20px; border-radius: 2px; overflow: hidden; margin-right: 8px;">
                                <div class="stripe" style="flex: 1; background: #00853F;"></div>
                                <div class="stripe" style="flex: 1; background: #FCD116; display: flex; align-items: center; justify-content: center;">
                                    <span style="color: #00853F; font-size: 8px;">★</span>
                                </div>
                                <div class="stripe" style="flex: 1; background: #CE1126;"></div>
                            </div>
                        </span>
                        <span class="app-brand-text demo menu-text fw-bolder ms-2" style="color: #00853F;">Teranga Pass</span>
                    </a>
                    <a href="javascript:void(0);" class="layout-menu-toggle menu-link text-large ms-auto d-block d-xl-none">
                        <i class="bx bx-chevron-left bx-sm align-middle"></i>
                    </a>
                </div>
                
                <div class="menu-inner-shadow"></div>
                
                <ul class="menu-inner py-1">
                    <!-- Accueil -->
                    <li class="menu-item {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                        <a href="{{ route('admin.dashboard') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-home-circle"></i>
                            <div data-i18n="Analytics">Accueil</div>
                        </a>
                    </li>
                    
                    <!-- Alertes -->
                    <li class="menu-item {{ request()->routeIs('admin.alerts.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.alerts.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-bell"></i>
                            <div data-i18n="Alerts">Alertes</div>
                        </a>
                    </li>
                    
                    <!-- Signalements -->
                    <li class="menu-item {{ request()->routeIs('admin.incidents.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.incidents.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-flag"></i>
                            <div data-i18n="Reports">Signalements</div>
                        </a>
                    </li>
                    
                    <!-- Notifications Push -->
                    <li class="menu-item {{ request()->routeIs('admin.notifications.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.notifications.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-notification"></i>
                            <div data-i18n="Notifications">Notifications Push</div>
                        </a>
                    </li>
                    
                    <!-- Annonces Audio -->
                    <li class="menu-item {{ request()->routeIs('admin.audio-announcements.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.audio-announcements.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-volume-full"></i>
                            <div data-i18n="Audio">Annonces Audio</div>
                        </a>
                    </li>
                    
                    <!-- Statistiques -->
                    <li class="menu-item {{ request()->routeIs('admin.statistics.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.statistics.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-bar-chart-alt-2"></i>
                            <div data-i18n="Statistics">Statistiques</div>
                        </a>
                    </li>
                    
                    <!-- Utilisateurs -->
                    <li class="menu-item {{ request()->routeIs('admin.mobile-users.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.mobile-users.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-user"></i>
                            <div data-i18n="Users">Utilisateurs</div>
                        </a>
                    </li>
                    
                    <!-- Partenaires -->
                    <li class="menu-item {{ request()->routeIs('admin.partners.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.partners.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-briefcase"></i>
                            <div data-i18n="Partners">Partenaires</div>
                        </a>
                    </li>
                    
                    <!-- Tourisme -->
                    <li class="menu-item {{ request()->routeIs('admin.tourism.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.tourism.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-map"></i>
                            <div data-i18n="Tourism">Tourisme</div>
                        </a>
                    </li>
                    
                    <!-- Sites de Compétition -->
                    <li class="menu-item {{ request()->routeIs('admin.competition-sites.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.competition-sites.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-map-alt"></i>
                            <div data-i18n="Competition Sites">Sites JOJ</div>
                        </a>
                    </li>
                    
                    <!-- Transport -->
                    <li class="menu-item {{ request()->routeIs('admin.transport.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.transport.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-bus"></i>
                            <div data-i18n="Transport">Transport</div>
                        </a>
                    </li>
                    
                    <!-- Joindre -->
                    <li class="menu-item {{ request()->routeIs('admin.contact.*') ? 'active' : '' }}">
                        <a href="{{ route('admin.contact.index') }}" class="menu-link">
                            <i class="menu-icon tf-icons bx bx-plus-circle"></i>
                            <div data-i18n="Join">Joindre</div>
                        </a>
                    </li>
                    
                    @yield('menu-items')
                </ul>
            </aside>
            <!-- / Menu -->
            
            <!-- Layout container -->
            <div class="layout-page">
                <!-- Navbar -->
                <nav class="layout-navbar container-xxl navbar navbar-expand-xl navbar-detached align-items-center bg-navbar-theme" id="layout-navbar">
                    <div class="layout-menu-toggle navbar-nav align-items-xl-center me-3 me-xl-0 d-xl-none">
                        <a class="nav-item nav-link px-0 me-xl-4" href="javascript:void(0)">
                            <i class="bx bx-menu bx-sm"></i>
                        </a>
                    </div>
                    
                    <div class="navbar-nav-right d-flex align-items-center" id="navbar-collapse">
                        <!-- Search -->
                        <div class="navbar-nav align-items-center">
                            <div class="nav-item d-flex align-items-center">
                                <i class="bx bx-search fs-4 lh-0"></i>
                                <input type="text" class="form-control border-0 shadow-none" placeholder="Search..." aria-label="Search..." />
                            </div>
                        </div>
                        <!-- /Search -->
                        
                        <ul class="navbar-nav flex-row align-items-center ms-auto">
                            <!-- User -->
                            <li class="nav-item navbar-dropdown dropdown-user dropdown">
                                <a class="nav-link dropdown-toggle hide-arrow" href="javascript:void(0);" data-bs-toggle="dropdown">
                                    <div class="avatar avatar-online">
                                        <img src="{{ asset('assets/img/avatars/1.png') }}" alt class="w-px-40 h-auto rounded-circle" />
                                    </div>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li>
                                        <a class="dropdown-item" href="#">
                                            <div class="d-flex">
                                                <div class="flex-shrink-0 me-3">
                                                    <div class="avatar avatar-online">
                                                        <img src="{{ asset('assets/img/avatars/1.png') }}" alt class="w-px-40 h-auto rounded-circle" />
                                                    </div>
                                                </div>
                                                <div class="flex-grow-1">
                                                    <span class="fw-semibold d-block">{{ Auth::check() ? Auth::user()->name : 'User' }}</span>
                                                    <small class="text-muted">Admin</small>
                                                </div>
                                            </div>
                                        </a>
                                    </li>
                                    <li>
                                        <div class="dropdown-divider"></div>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="{{ route('admin.profile.index') }}">
                                            <i class="bx bx-user me-2"></i>
                                            <span class="align-middle">Mon Profil</span>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item" href="{{ route('admin.settings.index') }}">
                                            <i class="bx bx-cog me-2"></i>
                                            <span class="align-middle">Paramètres</span>
                                        </a>
                                    </li>
                                    <li>
                                        <div class="dropdown-divider"></div>
                                    </li>
                                    <li>
                                        <form method="POST" action="{{ route('logout') }}">
                                            @csrf
                                            <button type="submit" class="dropdown-item">
                                                <i class="bx bx-power-off me-2"></i>
                                                <span class="align-middle">Log Out</span>
                                            </button>
                                        </form>
                                    </li>
                                </ul>
                            </li>
                            <!--/ User -->
                        </ul>
                    </div>
                </nav>
                <!-- / Navbar -->
                
                <!-- Content wrapper -->
                <div class="content-wrapper">
                    <!-- Content -->
                    <div class="container-xxl flex-grow-1 container-p-y">
                        @if(session('success'))
                            <div class="alert alert-success alert-dismissible" role="alert">
                                {{ session('success') }}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        @endif
                        
                        @if(session('error'))
                            <div class="alert alert-danger alert-dismissible" role="alert">
                                {{ session('error') }}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        @endif
                        
                        @yield('content')
                    </div>
                    <!-- / Content -->
                    
                    <!-- Footer -->
                    <footer class="content-footer footer bg-footer-theme">
                        <div class="container-xxl d-flex flex-wrap justify-content-between py-2 flex-md-row flex-column">
                            <div class="mb-2 mb-md-0">
                                © <script>document.write(new Date().getFullYear());</script>, made with ❤️ by
                                <a href="https://themeselection.com" target="_blank" class="footer-link fw-bolder">ThemeSelection</a>
                            </div>
                            <div>
                                <a href="https://themeselection.com/license/" class="footer-link me-4" target="_blank">License</a>
                                <a href="https://themeselection.com/" target="_blank" class="footer-link me-4">More Themes</a>
                                <a href="https://themeselection.com/demo/sneat-bootstrap-html-admin-template/documentation/" target="_blank" class="footer-link me-4">Documentation</a>
                                <a href="https://github.com/themeselection/sneat-html-admin-template-free/issues" target="_blank" class="footer-link me-4">Support</a>
                            </div>
                        </div>
                    </footer>
                    <!-- / Footer -->
                    
                    <div class="content-backdrop fade"></div>
                </div>
                <!-- Content wrapper -->
            </div>
            <!-- / Layout page -->
        </div>
        
        <!-- Overlay -->
        <div class="layout-overlay layout-menu-toggle"></div>
    </div>
    <!-- / Layout wrapper -->
    
    <!-- Core JS -->
    <script src="{{ asset('assets/vendor/libs/jquery/jquery.js') }}"></script>
    <script src="{{ asset('assets/vendor/libs/popper/popper.js') }}"></script>
    <script src="{{ asset('assets/vendor/js/bootstrap.js') }}"></script>
    <script src="{{ asset('assets/vendor/libs/perfect-scrollbar/perfect-scrollbar.js') }}"></script>
    <script src="{{ asset('assets/vendor/js/menu.js') }}"></script>
    
    <!-- Vendors JS -->
    @stack('vendor-js')
    
    <!-- Main JS -->
    <script src="{{ asset('assets/js/main.js') }}"></script>
    
    <!-- Page JS -->
    @stack('page-js')
</body>
</html>

