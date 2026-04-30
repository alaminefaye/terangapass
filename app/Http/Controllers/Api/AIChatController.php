<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AudioAnnouncement;
use App\Models\CompetitionSite;
use App\Models\Notification;
use App\Models\Partner;
use App\Models\Shuttle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class AIChatController extends Controller
{
    public function chat(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'message' => 'required|string|min:1|max:2000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Message invalide.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $apiKey = config('services.anthropic.api_key');
        $model = config('services.anthropic.model', 'claude-3-5-sonnet-latest');

        if (empty($apiKey) || str_contains($apiKey, 'ta_cle_claude_ici')) {
            return response()->json([
                'success' => false,
                'message' => 'Configuration IA invalide: merci de definir une vraie ANTHROPIC_API_KEY dans .env.',
            ], 500);
        }

        try {
            $message = $request->string('message')->toString();
            $appContext = $this->buildAppContext();
            $systemPrompt = $this->buildSystemPrompt($appContext);

            $response = Http::timeout(45)
                ->withHeaders([
                    'x-api-key' => $apiKey,
                    'anthropic-version' => '2023-06-01',
                    'content-type' => 'application/json',
                ])
                ->post('https://api.anthropic.com/v1/messages', [
                    'model' => $model,
                    'max_tokens' => 400,
                    'messages' => [
                        [
                            'role' => 'user',
                            'content' => $message,
                        ],
                    ],
                    'system' => $systemPrompt,
                ]);

            if (!$response->successful()) {
                $rawBody = $response->body();
                $lowerBody = Str::lower($rawBody);
                $isCreditIssue = Str::contains($lowerBody, [
                    'credit balance is too low',
                    'purchase credits',
                    'plans & billing',
                    'insufficient',
                ]);

                return response()->json([
                    'success' => false,
                    'message' => $isCreditIssue
                        ? 'Le service IA est indisponible: credits Claude insuffisants. Merci de recharger votre compte Anthropic.'
                        : 'Le service IA est temporairement indisponible.',
                    'error' => config('app.debug') ? $rawBody : null,
                ], $isCreditIssue ? 503 : 502);
            }

            $data = $response->json();
            $parts = $data['content'] ?? [];

            $text = collect($parts)
                ->where('type', 'text')
                ->pluck('text')
                ->filter()
                ->implode("\n\n");

            if (empty($text)) {
                $text = 'Je n ai pas pu generer de reponse. Merci de reessayer.';
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'reply' => Str::of($text)->trim()->toString(),
                    'model' => $data['model'] ?? $model,
                ],
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la generation de la reponse IA.',
                'error' => config('app.debug') ? $e->getMessage() : null,
            ], 500);
        }
    }

    private function buildSystemPrompt(array $appContext): string
    {
        $contextJson = json_encode(
            $appContext,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
        );

        return <<<PROMPT
Tu es l assistant IA officiel de TerangaPass.
Ta mission:
- Repondre en francais de facon claire, utile, concrete et courte.
- Utiliser en priorite les donnees APP_CONTEXT ci-dessous.
- Si la question porte sur un lieu, donner nom + adresse + coordonnees si disponibles.
- Si une information n est pas disponible dans APP_CONTEXT, dire explicitement qu elle n est pas disponible et proposer une action utile dans l application.
- Ne jamais inventer de fonctionnalite, horaire, prix, position ou numero.

Fonctionnalites principales de l app Home:
- Annonces audio officielles
- Infos touristiques
- Sites de competition (avec carte)
- Calendrier/competitions
- Transport/navettes
- Signalement d incident
- Boutons urgence: SOS et alerte medicale
- Notifications
- Assistant IA

APP_CONTEXT:
{$contextJson}
PROMPT;
    }

    private function buildAppContext(): array
    {
        $announcements = AudioAnnouncement::query()
            ->where('is_active', true)
            ->latest()
            ->limit(8)
            ->get(['id', 'title', 'content', 'language', 'duration', 'audio_url'])
            ->map(function (AudioAnnouncement $item) {
                return [
                    'id' => $item->id,
                    'title' => $item->title,
                    'content' => Str::limit((string) $item->content, 300),
                    'language' => $item->language,
                    'duration' => $item->duration,
                    'audio_url' => $item->audio_url,
                ];
            })
            ->values()
            ->toArray();

        $sites = CompetitionSite::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->limit(40)
            ->get([
                'id',
                'name',
                'location',
                'address',
                'latitude',
                'longitude',
                'start_date',
                'end_date',
                'sports',
                'access_info',
            ])
            ->map(function (CompetitionSite $site) {
                return [
                    'id' => $site->id,
                    'name' => $site->name,
                    'location' => $site->location,
                    'address' => $site->address,
                    'latitude' => $site->latitude !== null ? (float) $site->latitude : null,
                    'longitude' => $site->longitude !== null ? (float) $site->longitude : null,
                    'start_date' => optional($site->start_date)->format('Y-m-d'),
                    'end_date' => optional($site->end_date)->format('Y-m-d'),
                    'sports' => $site->sports,
                    'access_info' => $site->access_info,
                ];
            })
            ->values()
            ->toArray();

        $transports = Shuttle::query()
            ->where('is_active', true)
            ->with(['stops:id,shuttle_id,name,latitude,longitude'])
            ->orderBy('name')
            ->limit(20)
            ->get([
                'id',
                'name',
                'type',
                'description',
                'start_location',
                'end_location',
                'start_latitude',
                'start_longitude',
                'end_latitude',
                'end_longitude',
                'first_departure',
                'last_departure',
                'frequency_minutes',
                'operating_days',
            ])
            ->map(function (Shuttle $shuttle) {
                return [
                    'id' => $shuttle->id,
                    'name' => $shuttle->name,
                    'type' => $shuttle->type,
                    'description' => $shuttle->description,
                    'start_location' => $shuttle->start_location,
                    'end_location' => $shuttle->end_location,
                    'start_latitude' => $shuttle->start_latitude !== null ? (float) $shuttle->start_latitude : null,
                    'start_longitude' => $shuttle->start_longitude !== null ? (float) $shuttle->start_longitude : null,
                    'end_latitude' => $shuttle->end_latitude !== null ? (float) $shuttle->end_latitude : null,
                    'end_longitude' => $shuttle->end_longitude !== null ? (float) $shuttle->end_longitude : null,
                    'first_departure' => optional($shuttle->first_departure)->format('H:i'),
                    'last_departure' => optional($shuttle->last_departure)->format('H:i'),
                    'frequency_minutes' => $shuttle->frequency_minutes,
                    'operating_days' => $shuttle->operating_days,
                    'stops' => $shuttle->stops->map(function ($stop) {
                        return [
                            'name' => $stop->name,
                            'latitude' => $stop->latitude !== null ? (float) $stop->latitude : null,
                            'longitude' => $stop->longitude !== null ? (float) $stop->longitude : null,
                        ];
                    })->values()->toArray(),
                ];
            })
            ->values()
            ->toArray();

        $tourism = Partner::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->limit(40)
            ->get([
                'id',
                'name',
                'category',
                'address',
                'phone',
                'website',
                'latitude',
                'longitude',
                'description',
            ])
            ->map(function (Partner $partner) {
                return [
                    'id' => $partner->id,
                    'name' => $partner->name,
                    'category' => $partner->category,
                    'address' => $partner->address,
                    'phone' => $partner->phone,
                    'website' => $partner->website,
                    'latitude' => $partner->latitude !== null ? (float) $partner->latitude : null,
                    'longitude' => $partner->longitude !== null ? (float) $partner->longitude : null,
                    'description' => Str::limit((string) $partner->description, 220),
                ];
            })
            ->values()
            ->toArray();

        $notifications = Notification::query()
            ->where('is_active', true)
            ->latest()
            ->limit(10)
            ->get(['id', 'title', 'description', 'zone', 'created_at'])
            ->map(function (Notification $notification) {
                return [
                    'id' => $notification->id,
                    'title' => $notification->title,
                    'message' => Str::limit((string) $notification->description, 220),
                    'zone' => $notification->zone,
                    'created_at' => optional($notification->created_at)->toIso8601String(),
                ];
            })
            ->values()
            ->toArray();

        return [
            'generated_at' => now()->toIso8601String(),
            'announcements' => $announcements,
            'competition_sites' => $sites,
            'transport_shuttles' => $transports,
            'tourism_points' => $tourism,
            'latest_notifications' => $notifications,
        ];
    }
}
