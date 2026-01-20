<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AudioAnnouncement extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'content',
        'language',
        'audio_url',
        'duration',
        'target_locations',
        'play_count',
        'is_active',
    ];

    protected $casts = [
        'target_locations' => 'array',
        'is_active' => 'boolean',
    ];
}
