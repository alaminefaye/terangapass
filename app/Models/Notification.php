<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'title',
        'description',
        'zone',
        'target_locations',
        'is_active',
        'scheduled_at',
        'sent_count',
        'viewed_count',
    ];

    protected $casts = [
        'target_locations' => 'array',
        'is_active' => 'boolean',
        'scheduled_at' => 'datetime',
    ];

    public function logs(): HasMany
    {
        return $this->hasMany(NotificationLog::class);
    }
}
