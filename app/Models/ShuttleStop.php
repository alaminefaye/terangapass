<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ShuttleStop extends Model
{
    use HasFactory;

    protected $fillable = [
        'shuttle_id',
        'name',
        'latitude',
        'longitude',
        'address',
        'order',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function shuttle(): BelongsTo
    {
        return $this->belongsTo(Shuttle::class);
    }
}
