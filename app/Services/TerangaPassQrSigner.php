<?php

namespace App\Services;

/**
 * Jeton compact TPASS1 pour QR : signature HMAC-SHA256 du JSON des claims.
 */
class TerangaPassQrSigner
{
    public function __construct(
        private readonly string $secret,
    ) {}

    public function makeToken(array $claims): string
    {
        ksort($claims);
        $payload = json_encode($claims, JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
        $sig = hash_hmac('sha256', $payload, $this->secret, true);
        $b64 = static function (string $raw): string {
            return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
        };

        return 'TPASS1.'.$b64($payload).'.'.$b64($sig);
    }

    /**
     * @return array<string, mixed>|null
     */
    public function parseAndVerify(string $token): ?array
    {
        if (! str_starts_with($token, 'TPASS1.')) {
            return null;
        }
        $rest = substr($token, strlen('TPASS1.'));
        $dot = strpos($rest, '.');
        if ($dot === false) {
            return null;
        }
        $b64Payload = substr($rest, 0, $dot);
        $b64Sig = substr($rest, $dot + 1);
        $pad = static fn (string $s): string => $s.str_repeat('=', (4 - strlen($s) % 4) % 4);
        $payloadJson = base64_decode(strtr($pad($b64Payload), '-_', '+/'), true);
        $sigRaw = base64_decode(strtr($pad($b64Sig), '-_', '+/'), true);
        if ($payloadJson === false || $payloadJson === '' || $sigRaw === false) {
            return null;
        }
        $expected = hash_hmac('sha256', $payloadJson, $this->secret, true);
        if (! hash_equals($expected, $sigRaw)) {
            return null;
        }
        $data = json_decode($payloadJson, true);

        return is_array($data) ? $data : null;
    }
}
