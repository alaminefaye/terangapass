<?php

namespace App\Models;

use Carbon\CarbonInterface;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

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
        'rating',
        'opening_hours',
        'logo_url',
        'icon_path',
        'photos',
        'is_sponsor',
        'visit_count',
        'is_active',
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'rating' => 'decimal:1',
        'photos' => 'array',
        'is_sponsor' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function getIsOpenNowAttribute(): ?bool
    {
        return self::computeIsOpenNow($this->opening_hours);
    }

    public function getOpeningStatusLabelAttribute(): string
    {
        $open = $this->is_open_now;
        if ($open === true) {
            return 'Ouvert';
        }
        if ($open === false) {
            return 'Fermé';
        }

        return 'Horaires non renseignés';
    }

    public static function computeIsOpenNow(?string $openingHours, ?CarbonInterface $now = null): ?bool
    {
        if ($openingHours === null) {
            return null;
        }

        $raw = trim($openingHours);
        if ($raw === '' || $raw === '—' || $raw === '-') {
            return null;
        }

        $text = Str::lower(Str::ascii($raw));
        $text = preg_replace('/\s+/', ' ', $text) ?? $text;
        $now = $now ?? now('Africa/Dakar');
        $minutesNow = ((int) $now->format('H')) * 60 + (int) $now->format('i');

        $segments = array_filter(array_map('trim', preg_split('/\+/', $text) ?: []));
        if (empty($segments)) {
            $segments = [$text];
        }

        $anyDayMatched = false;
        $anyTimeParsed = false;

        foreach ($segments as $segment) {
            $dayMatches = self::segmentMatchesToday($segment, $now);
            if (! $dayMatches) {
                continue;
            }
            $anyDayMatched = true;

            if (str_contains($segment, '24h/24') || preg_match('/\b24h\b/', $segment)) {
                return true;
            }

            $range = self::extractTimeRange($segment);
            if ($range === null && count($segments) === 1) {
                $range = self::extractTimeRange($text);
            }
            if ($range === null) {
                continue;
            }
            $anyTimeParsed = true;

            [$start, $end] = $range;
            if ($start === $end) {
                return true;
            }
            if ($start < $end && $minutesNow >= $start && $minutesNow < $end) {
                return true;
            }
            if ($start > $end && ($minutesNow >= $start || $minutesNow < $end)) {
                return true;
            }
        }

        if (! $anyDayMatched) {
            return false;
        }
        if (! $anyTimeParsed) {
            return null;
        }

        return false;
    }

    private static function segmentMatchesToday(string $segment, CarbonInterface $now): bool
    {
        if (str_contains($segment, 'ts les jours') || str_contains($segment, 'tous les jours')) {
            return true;
        }

        $dayMap = [
            'lun' => 1,
            'mar' => 2,
            'mer' => 3,
            'jeu' => 4,
            'ven' => 5,
            'sam' => 6,
            'dim' => 7,
        ];
        $today = (int) $now->isoWeekday();

        if (preg_match('/\b(dim)\s+seulement\b/', $segment, $m)) {
            return $today === $dayMap[$m[1]];
        }

        if (preg_match_all('/\b(lun|mar|mer|jeu|ven|sam|dim)\s*-\s*(lun|mar|mer|jeu|ven|sam|dim)\b/', $segment, $ranges, PREG_SET_ORDER)) {
            foreach ($ranges as $r) {
                $start = $dayMap[$r[1]];
                $end = $dayMap[$r[2]];
                if ($start <= $end && $today >= $start && $today <= $end) {
                    return true;
                }
                if ($start > $end && ($today >= $start || $today <= $end)) {
                    return true;
                }
            }
        }

        if (preg_match_all('/\b(lun|mar|mer|jeu|ven|sam|dim)\b/', $segment, $days)) {
            foreach ($days[1] as $d) {
                if ($today === $dayMap[$d]) {
                    return true;
                }
            }

            return false;
        }

        return true;
    }

    /**
     * @return array{int,int}|null
     */
    private static function extractTimeRange(string $text): ?array
    {
        if (! preg_match('/(\d{1,2})(?:h(\d{1,2}))?\s*-\s*(\d{1,2})(?:h(\d{1,2}))?/', $text, $m)) {
            return null;
        }
        $h1 = (int) $m[1];
        $m1 = isset($m[2]) && $m[2] !== '' ? (int) $m[2] : 0;
        $h2 = (int) $m[3];
        $m2 = isset($m[4]) && $m[4] !== '' ? (int) $m[4] : 0;

        return [$h1 * 60 + $m1, $h2 * 60 + $m2];
    }
}
