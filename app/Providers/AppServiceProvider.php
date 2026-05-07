<?php

namespace App\Providers;

use App\Models\Incident;
use App\Services\TerangaPassQrSigner;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(TerangaPassQrSigner::class, function (): TerangaPassQrSigner {
            $secret = config('services.teranga_pass.qr_secret');
            if ($secret === null || $secret === '') {
                $secret = hash('sha256', (string) config('app.key'), true);
            }

            return new TerangaPassQrSigner($secret);
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Ensure all pagination links match Bootstrap dashboard styles.
        Paginator::useBootstrapFive();

        View::composer('layouts.app', function ($view) {
            $pendingIncidentsCount = Incident::where('status', 'pending')->count();
            $view->with('pendingIncidentsCount', $pendingIncidentsCount);
        });
    }
}
