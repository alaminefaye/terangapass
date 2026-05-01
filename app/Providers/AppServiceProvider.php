<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\View;
use Illuminate\Pagination\Paginator;
use App\Models\Incident;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
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
