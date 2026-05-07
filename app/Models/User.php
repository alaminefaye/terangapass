<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'user_type',
        'country',
        'phone',
        'language',
        'last_active_at',
        'is_blocked',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'last_active_at' => 'datetime',
            'is_blocked' => 'boolean',
        ];
    }

    public function alerts()
    {
        return $this->hasMany(Alert::class);
    }

    public function incidents()
    {
        return $this->hasMany(Incident::class);
    }

    public function deviceTokens()
    {
        return $this->hasMany(DeviceToken::class);
    }

    public function passTickets()
    {
        return $this->hasMany(PassTicket::class);
    }

    /**
     * Indique si le compte est bloqué côté admin (API + app).
     * Lecture des attributs bruts : reste fiable si la colonne `is_blocked` n’existe pas encore (avant migration).
     */
    public function isBlockedAccount(): bool
    {
        $attrs = $this->getAttributes();
        if (! array_key_exists('is_blocked', $attrs)) {
            return false;
        }
        $v = $attrs['is_blocked'];

        return $v === true || $v === 1 || $v === '1'
            || (is_string($v) && strtolower($v) === 'true');
    }
}
