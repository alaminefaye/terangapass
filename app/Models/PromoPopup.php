<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Carbon;

class PromoPopup extends Model
{
    protected $fillable = [
        'title',
        'sponsor_name',
        'image_path',
        'link_url',
        'link_label',
        'placement',
        'priority',
        'starts_at',
        'ends_at',
        'frequency',
        'impression_count',
        'click_count',
        'is_active',
    ];

    protected $casts = [
        'starts_at' => 'datetime',
        'ends_at' => 'datetime',
        'is_active' => 'boolean',
        'priority' => 'integer',
        'impression_count' => 'integer',
        'click_count' => 'integer',
    ];

    public function scopeActive(Builder $query): Builder
    {
        $now = Carbon::now();

        return $query
            ->where('is_active', true)
            ->where(function (Builder $q) use ($now) {
                $q->whereNull('starts_at')->orWhere('starts_at', '<=', $now);
            })
            ->where(function (Builder $q) use ($now) {
                $q->whereNull('ends_at')->orWhere('ends_at', '>=', $now);
            });
    }

    public function scopeForPlacement(Builder $query, string $placement): Builder
    {
        return $query->where(function (Builder $q) use ($placement) {
            $q->where('placement', $placement)->orWhere('placement', 'all');
        });
    }

    public function imageUrl(): ?string
    {
        if ($this->image_path === '') {
            return null;
        }

        if (str_starts_with($this->image_path, 'http://') || str_starts_with($this->image_path, 'https://')) {
            return $this->image_path;
        }

        $path = str_starts_with($this->image_path, '/')
            ? $this->image_path
            : '/storage/'.ltrim($this->image_path, '/');

        return url($path);
    }
}
