<?php

namespace App\Support;

class PhoneNormalizer
{
    /**
     * Canonicaliser un numéro pour stockage et détection des doublons.
     * Par défaut, les entrées sans indicatif sont interprétées comme numéros sénégalais (country SN).
     */
    public static function normalize(?string $raw, ?string $defaultCountry = 'SN'): ?string
    {
        if ($raw === null) {
            return null;
        }
        $trimmed = trim($raw);
        if ($trimmed === '') {
            return null;
        }

        $digits = preg_replace('/\D/', '', $trimmed) ?? '';
        if ($digits === '') {
            return null;
        }

        if (str_starts_with($digits, '00')) {
            $digits = substr($digits, 2);
        }

        $cc = strtoupper((string) $defaultCountry);

        if ($cc === 'SN') {
            // Déjà avec indicatif SN
            if (str_starts_with($digits, '221') && strlen($digits) === 12) {
                return '+'.$digits;
            }
            // 221 + quelque chose (conserver tant que plausible)
            if (str_starts_with($digits, '221') && strlen($digits) > 12) {
                return '+'.substr($digits, 0, 15);
            }
            // Format national courant : 771234567, 761234567, etc.
            if (strlen($digits) === 9 && preg_match('/^7[0678]\d{7}$/', $digits)) {
                return '+221'.$digits;
            }
            // 0771234567
            if (strlen($digits) === 10 && str_starts_with($digits, '0')) {
                $rest = substr($digits, 1);
                if (strlen($rest) === 9 && preg_match('/^7[0678]\d{7}$/', $rest)) {
                    return '+221'.$rest;
                }
            }
        }

        return '+'.$digits;
    }

    /** Digits utilisés pour la comparaison d’unicité (sans le +). */
    public static function digitsKey(?string $normalizedPhone): ?string
    {
        if ($normalizedPhone === null || $normalizedPhone === '') {
            return null;
        }
        $d = preg_replace('/\D/', '', $normalizedPhone) ?? '';

        return $d === '' ? null : $d;
    }
}
