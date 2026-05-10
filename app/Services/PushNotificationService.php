<?php

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\Notification as NotificationModel;
use App\Models\NotificationLog;
use App\Models\User;
use Google\Auth\Credentials\ServiceAccountCredentials;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Throwable;

class PushNotificationService
{
    /** Canal Android utilisé pour les pushes FCM (doit exister dans l’app). */
    private const ANDROID_DEFAULT_FCM_CHANNEL_ID = 'teranga_pass_channel';

    /**
     * Envoyer une notification push à tous les utilisateurs
     */
    public function sendToAll(NotificationModel $notification): array
    {
        $tokens = DeviceToken::where('is_active', true)
            ->with('user')
            ->get();

        return $this->sendToTokens($notification, $tokens);
    }

    /**
     * Envoyer une notification push à une zone spécifique
     */
    public function sendToZone(NotificationModel $notification, string $zone): array
    {
        // Pour l'instant, on envoie à tous les utilisateurs actifs
        // TODO: Filtrer par zone géographique basé sur les coordonnées de l'utilisateur
        $tokens = DeviceToken::where('is_active', true)
            ->with('user')
            ->get();

        return $this->sendToTokens($notification, $tokens);
    }

    /**
     * Envoyer une notification push à un utilisateur spécifique
     */
    public function sendToUser(NotificationModel $notification, User $user): array
    {
        $tokens = $user->deviceTokens()
            ->where('is_active', true)
            ->get();

        return $this->sendToTokens($notification, $tokens);
    }

    /**
     * Envoyer une notification push à des tokens spécifiques
     */
    protected function sendToTokens(NotificationModel $notification, $tokens): array
    {
        $results = [
            'success' => 0,
            'failed' => 0,
            'total' => $tokens->count(),
        ];

        foreach ($tokens as $deviceToken) {
            try {
                $sent = $this->sendToSingleToken($notification, $deviceToken);

                if ($sent) {
                    $results['success']++;
                } else {
                    $results['failed']++;
                }
            } catch (\Exception $e) {
                Log::error('Error sending push notification: '.$e->getMessage());
                $results['failed']++;
            }
        }

        // Mettre à jour le compteur dans la notification
        $notification->increment('sent_count', $results['success']);

        return $results;
    }

    /**
     * Envoyer une notification push à un seul token
     */
    protected function sendToSingleToken(NotificationModel $notification, DeviceToken $deviceToken): bool
    {
        $payload = [
            'notification' => [
                'title' => $notification->title,
                'body' => $notification->description,
                'sound' => 'default',
            ],
            'data' => [
                'notification_id' => (string) $notification->id,
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                'type' => 'admin_broadcast',
                'campaign_type' => (string) ($notification->type ?? 'general'),
            ],
            'priority' => 'high',
        ];

        try {
            return $this->dispatchFcm($deviceToken->token, $payload);
        } catch (\Exception $e) {
            Log::error('Error sending push to device: '.$e->getMessage());

            // Créer un log d'erreur
            NotificationLog::create([
                'notification_id' => $notification->id,
                'user_id' => $deviceToken->user_id,
                'device_token' => $deviceToken->token,
                'status' => 'failed',
                'sent_at' => now(),
                'error_message' => $e->getMessage(),
            ]);

            return false;
        }
    }

    /**
     * Notification opérationnelle (SOS / suivi) sans lien vers la table notifications.
     */
    public function notifyOperational(User $user, string $title, string $body, array $data = []): array
    {
        $data = array_merge([
            'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
        ], $data);

        $flatData = [];
        foreach ($data as $key => $value) {
            $flatData[is_string($key) ? $key : (string) $key] = is_scalar($value)
                ? (string) $value
                : json_encode($value, JSON_UNESCAPED_UNICODE);
        }

        $payload = [
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default',
            ],
            'data' => $flatData,
            'priority' => 'high',
            'content_available' => true,
        ];

        $results = ['success' => 0, 'failed' => 0, 'total' => 0];

        foreach ($user->deviceTokens()->where('is_active', true)->cursor() as $deviceToken) {
            $results['total']++;
            try {
                if ($this->dispatchFcm($deviceToken->token, $payload)) {
                    $results['success']++;
                } else {
                    $results['failed']++;
                }
            } catch (\Throwable $e) {
                Log::warning('Operational FCM failure: '.$e->getMessage());
                $results['failed']++;
            }
        }

        return $results;
    }

    public function notifyNewAlertCreated(\App\Models\Alert $alert): void
    {
        $user = $alert->user;
        if (! $user) {
            return;
        }

        $lang = strtolower((string) ($user->language ?? 'fr'));
        if ($alert->type === 'sos') {
            $titles = ['fr' => 'SOS envoyé', 'en' => 'SOS sent'];
            $bodies = [
                'fr' => 'Votre alerte a été transmise. Une équipe est informée.',
                'en' => 'Your alert was sent. A team has been notified.',
            ];
        } else {
            $titles = ['fr' => 'Alerte médicale envoyée', 'en' => 'Medical alert sent'];
            $bodies = [
                'fr' => 'Votre alerte médicale a été transmise aux secours.',
                'en' => 'Your medical alert was forwarded to responders.',
            ];
        }

        $title = $titles[$lang] ?? $titles['fr'];
        $body = $bodies[$lang] ?? $bodies['fr'];
        $type = $alert->type === 'sos' ? 'sos_sent' : 'medical_sent';

        $this->notifyOperational($user, $title, $body, [
            'type' => $type,
            'alert_id' => (string) $alert->id,
            'alert_type' => (string) $alert->type,
            'alert_status' => (string) $alert->status,
        ]);
    }

    public function notifyAlertStatusChanged(\App\Models\Alert $alert): void
    {
        $user = $alert->user;
        if (! $user) {
            return;
        }

        $lang = strtolower((string) ($user->language ?? 'fr'));
        $en = $lang === 'en';
        $status = $alert->status;
        $medical = $alert->type !== 'sos';

        [$title, $body] = match ($status) {
            'in_progress' => $medical
                ? ($en
                    ? ['Medical alert — in progress', 'Responders are handling your alert.']
                    : ['Alerte médicale prise en charge', 'Une équipe traite votre alerte médicale.'])
                : ($en
                    ? ['SOS in progress', 'Your emergency alert is being handled.']
                    : ['SOS pris en charge', 'Une équipe prend en charge votre alerte SOS.']),
            'resolved' => $medical
                ? ($en
                    ? ['Medical alert closed', 'Your alert has been closed.']
                    : ['Alerte médicale clôturée', 'Votre alerte médicale a été traitée.'])
                : ($en
                    ? ['SOS closed', 'Your alert has been resolved.']
                    : ['SOS clôturée', 'Votre alerte SOS a été traitée.']),
            'cancelled' => $medical
                ? ($en
                    ? ['Medical alert cancelled', 'Your alert was cancelled.']
                    : ['Alerte médicale annulée', 'Votre alerte a été annulée.'])
                : ($en
                    ? ['SOS cancelled', 'Your alert was cancelled.']
                    : ['SOS annulée', 'Votre alerte a été annulée.']),
            default => $medical
                ? ($en
                    ? ['Medical alert update', 'Status: '.$status]
                    : ['Suivi alerte médicale', 'Statut : '.trim(str_replace('_', ' ', $status))])
                : ($en
                    ? ['SOS status update', 'Status: '.trim(str_replace('_', ' ', $status))]
                    : ['Suivi SOS', 'Statut : '.trim(str_replace('_', ' ', $status))]),
        };

        $this->notifyOperational($user, $title, $body, [
            'type' => $medical ? 'medical_status_update' : 'sos_status_update',
            'alert_id' => (string) $alert->id,
            'alert_type' => (string) $alert->type,
            'alert_status' => (string) $alert->status,
        ]);
    }

    public function notifyIncidentStatus(\App\Models\Incident $incident): void
    {
        $user = $incident->user;
        if (! $user) {
            return;
        }

        $lang = strtolower((string) ($user->language ?? 'fr'));
        $status = $incident->status;
        [$title, $body] = match ($status) {
            'validated' => $lang === 'en'
                ? ['Report validated', 'Your incident report has been validated.']
                : ['Signalement validé', 'Votre signalement a été validé.'],
            'in_progress' => $lang === 'en'
                ? ['Report in progress', 'Your report is being processed.']
                : ['Suivi du signalement', 'Votre signalement est en cours de traitement.'],
            'resolved' => $lang === 'en'
                ? ['Report closed', 'Your report has been resolved.']
                : ['Signalement clôturé', 'Votre signalement a été traité.'],
            'rejected' => $lang === 'en'
                ? ['Report rejected', 'Your report could not be accepted.']
                : ['Signalement refusé', 'Votre signalement n’a pas été retenu.'],
            default => $lang === 'en'
                ? ['Report status', 'Updated status: '.$status]
                : ['Mise à jour signalement', 'Nouveau statut : '.$status],
        };

        $this->notifyOperational($user, $title, $body, [
            'type' => 'incident_status',
            'incident_id' => (string) $incident->id,
            'incident_status' => (string) $status,
        ]);
    }

    /**
     * Envoie un message FCM : HTTP v1 (fichier compte de service) si défini,
     * sinon ancienne API avec FCM_SERVER_KEY.
     */
    protected function dispatchFcm(string $token, array $payload): bool
    {
        if ($token === '') {
            return false;
        }

        $serviceAccountFullPath = $this->resolveFirebaseServiceAccountPath();

        if ($serviceAccountFullPath !== null) {
            return $this->postFcmV1($token, $serviceAccountFullPath, $payload);
        }

        $fcmServerKey = config('services.fcm.server_key');
        if (! empty($fcmServerKey)) {
            return $this->postLegacyFcm($token, (string) $fcmServerKey, $payload);
        }

        Log::warning('FCM non configuré : renseigner FIREBASE_SERVICE_ACCOUNT_PATH (fichier JSON) ou FCM_SERVER_KEY dans .env, puis php artisan config:clear');

        return false;
    }

    /**
     * Chemin absolu du JSON compte de service Firebase si lisible,
     * ou null. [FIREBASE_SERVICE_ACCOUNT_PATH] est relatif à la racine Laravel (pas public/).
     */
    protected function resolveFirebaseServiceAccountPath(): ?string
    {
        $path = config('services.fcm.service_account_path');

        if (! is_string($path) || trim($path) === '') {
            return null;
        }

        $trimmed = trim($path);
        $full = preg_match('#^/#', $trimmed) || preg_match('#^[A-Za-z]:\\\\#', $trimmed)
            ? $trimmed
            : base_path($trimmed);

        if (! is_readable($full)) {
            Log::warning('Fichier compte Firebase introuvable ou illisible', ['path_config' => $trimmed]);

            return null;
        }

        return $full;
    }

    /**
     * FCM HTTP v1 (OAuth2, fichier téléchargé depuis la console Firebase).
     */
    protected function postFcmV1(string $token, string $credentialsFullPath, array $payload): bool
    {
        $credentialsJson = json_decode((string) file_get_contents($credentialsFullPath), true);

        if (! is_array($credentialsJson) || empty($credentialsJson['project_id'])) {
            Log::warning('JSON compte Firebase invalide (project_id manquant)', ['path' => $credentialsFullPath]);

            return false;
        }

        $projectId = (string) $credentialsJson['project_id'];

        try {
            $oauthCreds = new ServiceAccountCredentials(
                ['https://www.googleapis.com/auth/firebase.messaging'],
                $credentialsJson
            );

            /** @var array{access_token: string}|array<mixed> $tokenInfo */
            $tokenInfo = $oauthCreds->fetchAuthToken();
            $accessToken = is_array($tokenInfo) && isset($tokenInfo['access_token'])
                ? (string) $tokenInfo['access_token']
                : '';
        } catch (Throwable $e) {
            Log::warning('OAuth Firebase (FCM v1): '.$e->getMessage());

            return false;
        }

        if ($accessToken === '') {
            Log::warning('OAuth Firebase : aucun access_token');

            return false;
        }

        $payload = $this->applyLegacyAndroidPayload($payload);

        $message = [
            'token' => $token,
        ];

        $notif = $payload['notification'] ?? [];
        if (is_array($notif) && (isset($notif['title']) || isset($notif['body']))) {
            $message['notification'] = array_filter([
                'title' => $notif['title'] ?? null,
                'body' => $notif['body'] ?? null,
            ], static fn ($v) => $v !== null && $v !== '');
        }

        $data = $payload['data'] ?? [];
        if (is_array($data) && $data !== []) {
            $flat = [];
            foreach ($data as $key => $value) {
                $flat[(string) $key] = is_scalar($value)
                    ? (string) $value
                    : (string) json_encode($value, JSON_UNESCAPED_UNICODE);
            }
            $message['data'] = $flat;
        }

        $priority = strtoupper((string) ($payload['priority'] ?? 'HIGH'));
        $android = [
            'priority' => $priority === 'NORMAL' ? 'NORMAL' : 'HIGH',
        ];

        $aNotif = is_array($payload['android']['notification'] ?? null)
            ? $payload['android']['notification']
            : [];

        if ($aNotif !== []) {
            $v1AndroidNotif = array_filter([
                'channel_id' => $aNotif['channel_id'] ?? null,
                'sound' => $aNotif['sound'] ?? null,
                'visibility' => $this->mapAndroidVisibilityForV1($aNotif['visibility'] ?? null),
            ], static fn ($v) => $v !== null && $v !== '');

            if ($v1AndroidNotif !== []) {
                $android['notification'] = $v1AndroidNotif;
            }
        }

        $message['android'] = $android;

        $url = sprintf('https://fcm.googleapis.com/v1/projects/%s/messages:send', rawurlencode($projectId));

        $response = Http::withToken($accessToken)
            ->timeout(20)
            ->acceptJson()
            ->post($url, ['message' => $message]);

        if (! $response->successful()) {
            Log::warning('FCM v1 HTTP erreur', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            return false;
        }

        $decoded = $response->json();

        if (is_array($decoded) && isset($decoded['error'])) {
            Log::warning('FCM v1 erreur API', ['error' => $decoded['error']]);

            return false;
        }

        return true;
    }

    protected function mapAndroidVisibilityForV1(mixed $visibility): ?string
    {
        if (! is_string($visibility) || $visibility === '') {
            return null;
        }

        $v = strtoupper($visibility);

        return match ($v) {
            'PUBLIC' => 'VISIBILITY_PUBLIC',
            'PRIVATE' => 'VISIBILITY_PRIVATE',
            'SECRET' => 'VISIBILITY_SECRET',
            default => null,
        };
    }

    protected function postLegacyFcm(string $token, string $serverKey, array $payload): bool
    {
        $payload = $this->applyLegacyAndroidPayload($payload);

        $response = Http::withHeaders([
            'Authorization' => 'key='.$serverKey,
            'Content-Type' => 'application/json',
        ])->timeout(15)->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $token,
            ...$payload,
        ]);

        if (! $response->successful()) {
            Log::warning('FCM HTTP error', ['status' => $response->status(), 'body' => $response->body()]);

            return false;
        }

        $decoded = $response->json();
        if (! is_array($decoded)) {
            Log::warning('FCM response not JSON', ['body' => $response->body()]);

            return false;
        }

        $failure = (int) ($decoded['failure'] ?? 0);
        if ($failure > 0) {
            Log::warning('FCM downstream failure', [
                'failure' => $failure,
                'success' => $decoded['success'] ?? null,
                'results' => $decoded['results'] ?? null,
                'canonical_ids' => $decoded['canonical_ids'] ?? null,
                'token_prefix' => substr($token, 0, 24).'…',
            ]);

            return false;
        }

        return true;
    }

    /**
     * Chaines « notification » FCM système sans canal valide ⇒ pas d’alerte lisible sous Android 8+.
     * Associe tous les payloads legacy à une priorité/châine alignées avec l’application Flutter.
     */
    protected function applyLegacyAndroidPayload(array $payload): array
    {
        $dataBlock = isset($payload['data']) && is_array($payload['data']) ? $payload['data'] : [];
        $channelId = $this->inferAndroidNotificationChannel($dataBlock['type'] ?? null);

        $payload['priority'] = $payload['priority'] ?? 'high';

        $existingAndroid = is_array($payload['android'] ?? null) ? $payload['android'] : [];
        $nestedNotif = is_array($existingAndroid['notification'] ?? null)
            ? $existingAndroid['notification']
            : [];

        unset($existingAndroid['notification']);

        $payload['android'] = array_merge([
            'priority' => 'high',
        ], $existingAndroid, [
            'notification' => array_merge([
                'channel_id' => $channelId,
                'sound' => 'default',
                'visibility' => 'PUBLIC',
            ], $nestedNotif),
        ]);

        return $payload;
    }

    protected function inferAndroidNotificationChannel(mixed $dataType): string
    {
        $type = is_string($dataType) ? strtolower($dataType) : '';

        return match (true) {
            $type !== '' && str_contains($type, 'sos') => 'sos_channel',
            $type !== '' && str_contains($type, 'medical') => 'medical_channel',
            $type === 'incident_status' => 'security_channel',
            default => self::ANDROID_DEFAULT_FCM_CHANNEL_ID,
        };
    }
}
