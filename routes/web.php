<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Web\NotificationManagementController;
use App\Http\Controllers\Web\AudioAnnouncementManagementController;
use App\Http\Controllers\Web\AlertManagementController;
use App\Http\Controllers\Web\IncidentManagementController;
use App\Http\Controllers\Web\PartnerManagementController;
use App\Http\Controllers\Web\TourismManagementController;
use App\Http\Controllers\Web\MobileUserController;
use App\Http\Controllers\Web\CompetitionSiteManagementController;
use App\Http\Controllers\Web\TransportManagementController;
use App\Http\Controllers\Web\StatisticsController;
use App\Http\Controllers\Web\ContactController;
use App\Http\Controllers\Web\ProfileController;
use App\Http\Controllers\Web\SettingsController;

// Authentication Routes
Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware(['auth'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    // Notifications
    Route::resource('notifications', NotificationManagementController::class);
    Route::post('notifications/{notification}/send', [NotificationManagementController::class, 'send'])->name('notifications.send');

    // Annonces Audio
    Route::resource('audio-announcements', AudioAnnouncementManagementController::class);

    // Alertes
    Route::get('alerts', [AlertManagementController::class, 'index'])->name('alerts.index');
    Route::get('alerts/{alert}', [AlertManagementController::class, 'show'])->name('alerts.show');
    Route::put('alerts/{alert}/status', [AlertManagementController::class, 'updateStatus'])->name('alerts.updateStatus');
    Route::post('alerts/{alert}/assign', [AlertManagementController::class, 'assign'])->name('alerts.assign');

    // Signalements
    Route::get('incidents', [IncidentManagementController::class, 'index'])->name('incidents.index');
    Route::get('incidents/{incident}', [IncidentManagementController::class, 'show'])->name('incidents.show');
    Route::post('incidents/{incident}/validate', [IncidentManagementController::class, 'validateIncident'])->name('incidents.validate');
    Route::post('incidents/{incident}/reject', [IncidentManagementController::class, 'reject'])->name('incidents.reject');
    Route::put('incidents/{incident}/status', [IncidentManagementController::class, 'updateStatus'])->name('incidents.updateStatus');

    // Partenaires
    Route::resource('partners', PartnerManagementController::class);

    // Tourisme
    Route::resource('tourism', TourismManagementController::class);

    // Utilisateurs Mobile
    Route::get('mobile-users', [MobileUserController::class, 'index'])->name('mobile-users.index');
    Route::get('mobile-users/{user}', [MobileUserController::class, 'show'])->name('mobile-users.show');
    Route::put('mobile-users/{user}/status', [MobileUserController::class, 'updateStatus'])->name('mobile-users.updateStatus');

    // Sites de Compétition
    Route::resource('competition-sites', CompetitionSiteManagementController::class);

    // Transport & Navettes
    Route::resource('transport', TransportManagementController::class);

    // Statistiques
    Route::get('statistics', [StatisticsController::class, 'index'])->name('statistics.index');

    // Contact
    Route::get('contact', [ContactController::class, 'index'])->name('contact.index');
    Route::post('contact', [ContactController::class, 'store'])->name('contact.store');

    // Profil
    Route::get('profile', [ProfileController::class, 'index'])->name('profile.index');
    Route::put('profile', [ProfileController::class, 'update'])->name('profile.update');

    // Paramètres
    Route::get('settings', [SettingsController::class, 'index'])->name('settings.index');
    Route::put('settings', [SettingsController::class, 'update'])->name('settings.update');
});

// Redirect root to admin dashboard
Route::get('/', function () {
    return redirect()->route('admin.dashboard');
});
