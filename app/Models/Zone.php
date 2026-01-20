<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Zone extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'polygon_coordinates',
        'center_latitude',
        'center_longitude',
        'is_active',
        'population_estimate',
    ];

    protected $casts = [
        'polygon_coordinates' => 'array',
        'center_latitude' => 'decimal:8',
        'center_longitude' => 'decimal:8',
        'is_active' => 'boolean',
    ];
}
