<?php

namespace App\Services;

use App\Models\DeviceToken;
use App\Models\Notification as NotificationModel;
use App\Models\NotificationLog;
use App\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PushNotificationService
{
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
                Log::error('Error sending push notification: ' . $e->getMessage());
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
            return $this->dispatchLegacyFcm($deviceToken->token, $payload);
        } catch (\Exception $e) {
            Log::error('Error sending push to device: ' . $e->getMessage());
            
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
                if ($this->dispatchLegacyFcm($deviceToken->token, $payload)) {
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
     * Envoie un message FCM (legacy HTTP avec clé serveur).
     */
    protected function dispatchLegacyFcm(string $token, array $payload): bool
    {
        $fcmServerKey = config('services.fcm.server_key');

        if (! $fcmServerKey || $token === '') {
            if (! $fcmServerKey) {
                Log::warning('FCM server key not configured — operational push skipped');
            }

            return false;
        }

        return $this->postLegacyFcm($token, $fcmServerKey, $payload);
    }

    protected function postLegacyFcm(string $token, string $serverKey, array $payload): bool
    {
        $response = Http::withHeaders([
            'Authorization' => 'key='.$serverKey,
            'Content-Type' => 'application/json',
        ])->timeout(15)->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $token,
            ...$payload,
        ]);

        if (! $response->successful()) {
            Log::warning('FCM HTTP error: '.$response->body());

            return false;
        }

        return true;
    }
}
