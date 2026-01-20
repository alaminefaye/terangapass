<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\Zone;
use App\Services\PushNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotificationManagementController extends Controller
{
    protected $pushService;

    public function __construct(PushNotificationService $pushService)
    {
        $this->pushService = $pushService;
    }

    public function index(Request $request)
    {
        $query = Notification::query();

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('zone')) {
            $query->where('zone', $request->zone);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        $notifications = $query->orderBy('created_at', 'desc')->paginate(20);
        $zones = Zone::where('is_active', true)->get();

        return view('notifications.index', compact('notifications', 'zones'));
    }

    public function create()
    {
        $zones = Zone::where('is_active', true)->get();
        return view('notifications.create', compact('zones'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|in:sécurité,météo,circulation,consignes_joj',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'zone' => 'nullable|string',
            'scheduled_at' => 'nullable|date',
            'is_active' => 'boolean',
        ]);

        $notification = Notification::create($validated);

        // Si pas de date programmée et actif, envoyer immédiatement
        if (!$notification->scheduled_at && $notification->is_active) {
            $this->pushService->sendToAll($notification);
        }

        return redirect()->route('admin.notifications.index')
            ->with('success', 'Notification créée avec succès.');
    }

    public function show(Notification $notification)
    {
        $notification->load('logs.user');
        return view('notifications.show', compact('notification'));
    }

    public function edit(Notification $notification)
    {
        $zones = Zone::where('is_active', true)->get();
        return view('notifications.edit', compact('notification', 'zones'));
    }

    public function update(Request $request, Notification $notification)
    {
        $validated = $request->validate([
            'type' => 'required|in:sécurité,météo,circulation,consignes_joj',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'zone' => 'nullable|string',
            'scheduled_at' => 'nullable|date',
            'is_active' => 'boolean',
        ]);

        $notification->update($validated);

        return redirect()->route('admin.notifications.index')
            ->with('success', 'Notification mise à jour avec succès.');
    }

    public function destroy(Notification $notification)
    {
        $notification->delete();
        return redirect()->route('admin.notifications.index')
            ->with('success', 'Notification supprimée avec succès.');
    }

    public function send(Notification $notification)
    {
        if ($notification->zone) {
            $results = $this->pushService->sendToZone($notification, $notification->zone);
        } else {
            $results = $this->pushService->sendToAll($notification);
        }

        return redirect()->back()
            ->with('success', "Notification envoyée à {$results['success']} appareils sur {$results['total']}.");
    }
}
