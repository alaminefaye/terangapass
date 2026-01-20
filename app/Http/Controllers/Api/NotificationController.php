<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
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

        $notifications = $query->get();

        return response()->json(['data' => $notifications]);
    }

    public function markAsRead(Request $request, $id)
    {
        $notification = Notification::findOrFail($id);
        $notification->increment('viewed_count');

        return response()->json(['message' => 'Notification marked as read']);
    }
}
