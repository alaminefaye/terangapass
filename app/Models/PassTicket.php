<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
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

    /** Pass actuellement utilisable (non révoqué, dans la fenêtre de validité). */
    public static function queryActiveForUser(int $userId): Builder
    {
        return static::query()
            ->where('user_id', $userId)
            ->where('status', 'active')
            ->whereNull('revoked_at')
            ->where(function ($q): void {
                $q->whereNull('valid_until')->orWhere('valid_until', '>', now());
            });
    }

    public static function findActiveForUser(int $userId): ?self
    {
        return static::queryActiveForUser($userId)->orderByDesc('id')->first();
    }

    /** Au moins un billet révoqué dans l’historique (blocage nouvelle auto-émission). */
    public static function userHasRevokedHistory(int $userId): bool
    {
        return static::query()
            ->where('user_id', $userId)
            ->where(function ($q): void {
                $q->where('status', 'revoked')
                    ->orWhereNotNull('revoked_at');
            })
            ->exists();
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
