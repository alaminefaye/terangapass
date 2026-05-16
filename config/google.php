<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Google Maps Platform (Places, Directions, etc.)
    |--------------------------------------------------------------------------
    |
    | Activer dans Google Cloud Console : Places API, Directions API,
    | Maps SDK (Android/iOS). Facturation requise.
    |
    */
    'maps_api_key' => env('GOOGLE_MAPS_API_KEY', ''),

  /*
    | Centre par défaut (diagnostic / secours) — Dakar.
    */
    'places_sync_lat' => (float) env('GOOGLE_PLACES_SYNC_LAT', 14.6928),
    'places_sync_lng' => (float) env('GOOGLE_PLACES_SYNC_LNG', -17.4467),
    'places_sync_radius' => (int) env('GOOGLE_PLACES_SYNC_RADIUS', 50000),

    /*
    | Zones d’import : tout le Sénégal (régions + grandes villes).
    | Voir config/google_places_zones.php
    */
    'places_sync_zones' => require __DIR__.'/google_places_zones.php',

    'places_base_url' => 'https://maps.googleapis.com/maps/api/place',

];
