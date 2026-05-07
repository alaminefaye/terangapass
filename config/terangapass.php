<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Pack hors ligne — catalogue (étape 7)
    |--------------------------------------------------------------------------
    |
    | Version logique du manifeste : incrémenter lors d’un changement de contenu
    | embarqué (POI, sites JOJ, annonces critiques). L’app peut comparer à la
    | copie locale et proposer un téléchargement.
    |
    */
    'offline_catalog_version' => env('TERANGA_OFFLINE_CATALOG_VERSION', '2026.1.0'),

];
