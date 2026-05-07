<?php

namespace App\Support;

class EmailNormalizer
{
    /**
     * Canonicaliser une adresse pour comparaisons / contraintes d’unicité
     * (émojis espaces Unicode, BOM, NFC).
     */
    public static function normalize(string $email): string
    {
        $email = preg_replace('/[\x{200B}-\x{200D}\x{FEFF}\x{00A0}]/u', '', $email) ?? $email;
        $email = trim($email);
        $email = strtolower($email);

        if (function_exists('normalizer_normalize') && class_exists(\Normalizer::class)) {
            $norm = normalizer_normalize($email, \Normalizer::FORM_C);
            if ($norm !== false && $norm !== '') {
                $email = $norm;
            }
        }

        return $email;
    }
}
