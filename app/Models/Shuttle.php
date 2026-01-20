<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Shuttle extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'type',
        'start_date',
        'end_date',
        'start_location',
        'end_location',
        'start_latitude',
        'start_longitude',
        'end_latitude',
        'end_longitude',
        'frequency_minutes',
        'first_departure',
        'last_departure',
        'operating_days',
        'is_secure_route',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'start_latitude' => 'decimal:8',
        'start_longitude' => 'decimal:8',
        'end_latitude' => 'decimal:8',
        'end_longitude' => 'decimal:8',
        'first_departure' => 'datetime:H:i',
        'last_departure' => 'datetime:H:i',
        'operating_days' => 'array',
        'is_secure_route' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function stops(): HasMany
    {
        return $this->hasMany(ShuttleStop::class)->orderBy('order');
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(ShuttleSchedule::class);
    }
}
