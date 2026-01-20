<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AlertController;
use App\Http\Controllers\Api\IncidentController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\AudioAnnouncementController;
use App\Http\Controllers\Api\CompetitionSiteController;
use App\Http\Controllers\Api\TransportController;
use App\Http\Controllers\Api\TourismController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\DeviceTokenController;

// Routes publiques
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes protégées - Pour l'instant sans authentification API (à ajouter Sanctum plus tard)
Route::middleware([])->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/user/profile', [UserController::class, 'profile']);
    Route::put('/user/profile', [UserController::class, 'updateProfile']);

    // Device Tokens
    Route::post('/device-tokens/register', [DeviceTokenController::class, 'register']);
    Route::post('/device-tokens/unregister', [DeviceTokenController::class, 'unregister']);

    // SOS & Alertes
    Route::post('/sos/alert', [AlertController::class, 'sendSOS']);
    Route::post('/medical/alert', [AlertController::class, 'sendMedical']);
    Route::get('/alerts/history', [AlertController::class, 'history']);

    // Signalements
    Route::post('/incidents/report', [IncidentController::class, 'report']);
    Route::get('/incidents/history', [IncidentController::class, 'history']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::put('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);

    // Annonces Audio
    Route::get('/announcements/audio', [AudioAnnouncementController::class, 'index']);

    // Sites JOJ
    Route::get('/sites/competitions', [CompetitionSiteController::class, 'index']);
    Route::get('/sites/calendar', [CompetitionSiteController::class, 'calendar']);

    // Transport
    Route::get('/transport/shuttles', [TransportController::class, 'shuttles']);

    // Tourisme
    Route::get('/tourism/points-of-interest', [TourismController::class, 'pointsOfInterest']);
});
