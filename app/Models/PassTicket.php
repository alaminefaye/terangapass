<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PassTicket extends Model
{
    protected $fillable = [
        'user_id',
        'public_id',
        'type',
        'status',
        'valid_until',
        'revoked_at',
    ];

    protected function casts(): array
    {
        return [
            'valid_until' => 'datetime',
            'revoked_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isActive(): bool
    {
        if ($this->status !== 'active') {
            return false;
        }
        if ($this->revoked_at !== null) {
            return false;
        }
        if ($this->valid_until !== null && $this->valid_until->isPast()) {
            return false;
        }

        return true;
    }
}
