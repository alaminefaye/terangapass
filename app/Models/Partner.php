<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Partner extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'category',
        'description',
        'address',
        'latitude',
        'longitude',
        'phone',
        'email',
        'website',
        'logo_url',
        'is_sponsor',
        'visit_count',
        'is_active',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'is_sponsor' => 'boolean',
        'is_active' => 'boolean',
    ];
}
