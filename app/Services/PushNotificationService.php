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
                'type' => $notification->type,
                'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
            ],
            'priority' => 'high',
        ];

        try {
            if ($deviceToken->platform === 'android') {
                return $this->sendToAndroid($deviceToken->token, $payload);
            } else {
                return $this->sendToIOS($deviceToken->token, $payload);
            }
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
     * Envoyer une notification push Android via FCM
     */
    protected function sendToAndroid(string $token, array $payload): bool
    {
        $fcmServerKey = config('services.fcm.server_key');
        
        if (!$fcmServerKey) {
            Log::warning('FCM server key not configured');
            return false;
        }

        $response = Http::withHeaders([
            'Authorization' => 'key=' . $fcmServerKey,
            'Content-Type' => 'application/json',
        ])->post('https://fcm.googleapis.com/fcm/send', [
            'to' => $token,
            ...$payload,
        ]);

        return $response->successful();
    }

    /**
     * Envoyer une notification push iOS via APNs
     */
    protected function sendToIOS(string $token, array $payload): bool
    {
        // TODO: Implémenter l'envoi via APNs
        // Pour l'instant, on utilise aussi FCM pour iOS
        return $this->sendToAndroid($token, $payload);
    }
}
