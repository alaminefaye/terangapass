<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CompetitionSite extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'location',
        'latitude',
        'longitude',
        'address',
        'start_date',
        'end_date',
        'sports',
        'access_info',
        'facilities',
        'capacity',
        'is_active',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'start_date' => 'date',
        'end_date' => 'date',
        'sports' => 'array',
        'facilities' => 'array',
        'is_active' => 'boolean',
    ];
}
