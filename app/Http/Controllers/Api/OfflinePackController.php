<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

/**
 * JSON publics alignés sur les endpoints tourisme / sites JOJ pour mise en cache hors ligne.
 */
class OfflinePackController extends Controller
{
    public function poiBundle()
    {
        $request = Request::create('/api/v1/tourism/points-of-interest', 'GET');

        return app(TourismController::class)->pointsOfInterest($request);
    }

    public function competitionSitesBundle()
    {
        return app(CompetitionSiteController::class)->index();
    }

    public function embassiesBundle()
    {
        $request = Request::create('/api/v1/tourism/embassies', 'GET');

        return app(TourismController::class)->embassies($request);
    }

    public function competitionCalendarBundle()
    {
        return app(CompetitionSiteController::class)->calendar();
    }

    public function audioAnnouncementsBundle()
    {
        $request = Request::create('/api/v1/announcements/audio', 'GET');

        return app(AudioAnnouncementController::class)->index($request);
    }
}
