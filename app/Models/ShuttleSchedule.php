<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShuttleSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'shuttle_id',
        'departure_time',
        'day_of_week',
        'is_active',
    ];

    protected $casts = [
        'departure_time' => 'datetime:H:i',
        'is_active' => 'boolean',
    ];

    public function shuttle(): BelongsTo
    {
        return $this->belongsTo(Shuttle::class);
    }
}
