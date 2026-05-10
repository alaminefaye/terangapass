<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use App\Models\UserNotification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $query = Notification::where('is_active', true)
            ->orderBy('created_at', 'desc');

        if ($request->has('zone')) {
            $query->where('zone', $request->zone);
        }

        $notifications = $query->get()->map(fn ($n) => [
            'id' => 'admin_'.$n->id,
            'source' => 'admin',
            'type' => $n->type,
            'title' => $n->title,
            'description' => $n->description,
            'zone' => $n->zone,
            'is_read' => false,
            'created_at' => $n->created_at,
        ]);

        // Fusionner avec les notifications personnelles de l'utilisateur connecté
        $user = $this->getAuthUser($request);
        $personal = collect();

        if ($user) {
            $personal = UserNotification::where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->limit(50)
                ->get()
                ->map(fn ($n) => [
                    'id' => 'user_'.$n->id,
                    'source' => 'personal',
                    'type' => $n->type,
                    'title' => $n->title,
                    'description' => $n->body,
                    'zone' => null,
                    'is_read' => $n->is_read,
                    'extra_data' => $n->extra_data,
                    'created_at' => $n->created_at,
                ]);
        }

        $merged = $personal->concat($notifications)
            ->sortByDesc('created_at')
            ->values();

        return response()->json(['data' => $merged]);
    }

    public function markAsRead(Request $request, $id)
    {
        // Support id prefixé (admin_X) ou entier brut
        $rawId = ltrim((string) $id, 'admin_');
        $notification = Notification::find((int) $rawId);
        if ($notification) {
            $notification->increment('viewed_count');
        }

        return response()->json(['message' => 'Notification marked as read']);
    }

    public function myNotifications(Request $request)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['data' => []]);
        }

        $notifications = UserNotification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get()
            ->map(fn ($n) => [
                'id' => 'user_'.$n->id,
                'source' => 'personal',
                'type' => $n->type,
                'title' => $n->title,
                'description' => $n->body,
                'zone' => null,
                'is_read' => $n->is_read,
                'extra_data' => $n->extra_data,
                'created_at' => $n->created_at,
            ]);

        return response()->json(['data' => $notifications]);
    }

    public function markMyNotificationAsRead(Request $request, $id)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        UserNotification::where('id', $this->rawId($id))
            ->where('user_id', $user->id)
            ->update(['is_read' => true]);

        return response()->json(['message' => 'Notification marked as read']);
    }

    public function markMyNotificationAsUnread(Request $request, $id)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        UserNotification::where('id', $this->rawId($id))
            ->where('user_id', $user->id)
            ->update(['is_read' => false]);

        return response()->json(['message' => 'Notification marked as unread']);
    }

    public function markAllMyNotificationsAsRead(Request $request)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        UserNotification::where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json(['message' => 'All notifications marked as read']);
    }

    public function clearAllMyNotifications(Request $request)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        UserNotification::where('user_id', $user->id)->delete();

        return response()->json(['message' => 'All notifications cleared']);
    }

    public function deleteMyNotification(Request $request, $id)
    {
        $user = $this->getAuthUser($request);
        if (! $user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        UserNotification::where('id', $this->rawId($id))
            ->where('user_id', $user->id)
            ->delete();

        return response()->json(['message' => 'Notification deleted']);
    }

    private function rawId(mixed $id): int
    {
        return (int) preg_replace('/^(user_|admin_)/', '', (string) $id);
    }

    private function getAuthUser(Request $request): ?User
    {
        $token = $request->bearerToken() ?? $request->header('Authorization', '');
        $token = str_replace('Bearer ', '', (string) $token);
        if (! $token) {
            return null;
        }
        try {
            $decoded = base64_decode($token);
            $parts = explode('|', $decoded);
            if (count($parts) >= 3) {
                return User::find((int) $parts[0]);
            }
        } catch (\Throwable) {
        }

        return null;
    }
}
