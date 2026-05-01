<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AudioAnnouncement;
use App\Models\CompetitionSite;
use App\Models\Notification;
use App\Models\Partner;
use App\Models\Shuttle;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class AIChatController extends Controller
{
    public function chat(Request $request)
    {
        $validator = \Validator::make($request->all(), [
            'message' => 'required|string|min:1|max:2000',
            'conversation_history' => 'nullable|array|max:40',
            'conversation_history.*.role' => 'required|string|in:user,assistant',
            'conversation_history.*.content' => 'required|string|max:4000',
            'latitude' => 'nullable|required_with:longitude|numeric|between:-90,90',
            'longitude' => 'nullable|required_with:latitude|numeric|between:-180,180',
            'accuracy' => 'nullable|numeric|min:0|max:50000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Message invalide.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $apiKey = config('services.anthropic.api_key');
        $model = config('services.anthropic.model', 'claude-sonnet-4-6');

        if (empty($apiKey) || str_contains($apiKey, 'ta_cle_claude_ici')) {
            return response()->json([
                'success' => false,
                'message' => 'Configuration IA invalide: merci de definir une vraie ANTHROPIC_API_KEY dans .env.',
            ], 500);
        }

        try {
            $message = $request->string('message')->toString();
            $user = $this->getUserFromToken($request);
            $participantName = $user && filled($user->name)
                ? trim((string) $user->name)
                : null;

            $appContext = $this->buildAppContext(
                $request->input('latitude'),
                $request->input('longitude'),
                $request->input('accuracy'),
            );
            $systemPrompt = $this->buildSystemPrompt($appContext, $participantName);

            $anthropicMessages = $this->buildAnthropicMessages(
                $request->input('conversation_history', []),
                $message
            );

            $response = Http::timeout(45)
                ->withHeaders([
                    'x-api-key' => $apiKey,
                    'anthropic-version' => '2023-06-01',
                    'content-type' => 'application/json',
                ])
                ->post('https://api.anthropic.com/v1/messages', [
                    'model' => $model,
                    'max_tokens' => 400,
                    'messages' => $anthropicMessages,
                    'system' => $systemPrompt,
                ]);

            if (!$response->successful()) {
                $rawBody = $response->body();

                return response()->json([
                    'success' => false,
                    'message' => 'Le service IA est temporairement indisponible.',
                    'error' => config('app.debug') ? $rawBody : null,
                ], 502);
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

    /**
     * @param  array<string, mixed>  $appContext
     */
    private function buildSystemPrompt(array $appContext, ?string $participantName): string
    {
        $contextJson = json_encode(
            $appContext,
            JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
        );

        $userBlock = $participantName !== null && $participantName !== ''
            ? <<<USERBLOCK

CONTEXTE_UTILISATEUR:
- La personne connectee s appelle: "{$participantName}" (champ name du compte TerangaPass).
- Tu peux la saluer ou l interpeller avec ce nom quand c est naturel, sans exagerer.
- Ne deduis aucune autre donnee personnelle (age, adresse, telephone) a partir de ce seul nom.
USERBLOCK
            : <<<'USERBLOCK'

CONTEXTE_UTILISATEUR:
- Aucun nom de compte transmis: adresse la personne de facon neutre (vous / visiteur).
USERBLOCK;

        return <<<PROMPT
Tu es l assistant IA officiel de TerangaPass.
Ta mission:
- Repondre en francais de facon claire, utile, concrete et courte.
- Utiliser en priorite les donnees APP_CONTEXT ci-dessous.
- Si la question porte sur un lieu, donner nom + adresse + coordonnees si disponibles.
- Si une information n est pas disponible dans APP_CONTEXT, dire explicitement qu elle n est pas disponible et proposer une action utile dans l application.
- Ne jamais inventer de fonctionnalite, horaire, prix ou numero. Ne jamais inventer de coordonnees pour un lieu absent de APP_CONTEXT.

POSITION ET LOCALISATION:
- Si APP_CONTEXT contient "client_geolocation" (latitude, longitude), c est la position transmise volontairement par l application mobile au moment du message. Utilise-la comme reference utilisateur: points APP_CONTEXT les plus proches, distances relatives, formulations du type "pres de vous" quand c est pertinent.
- Dans ce cas, ne dis pas que tu nas pas acces au GPS ou que tu ne peux pas localiser: tu disposes de coordonnees fournies par l app; indique que la precision depend du telephone et du champ accuracy_meters si present.
- Si "client_geolocation" est absente, tu peux dire poliment qu sans localisation activee dans l app les conseils de proximite restent generaux.
- Formate les reponses en Markdown simple (titres ##, listes -, **gras**). Pour les numeros de telephone, utilise toujours le format international +221 suivi des chiffres (ex. +221 33 123 45 67).
- Evite les blocs de code (triple backticks) sauf si indispensable; ne jamais mettre de numeros ou d URLs uniquement dans un bloc de code car l utilisateur ne pourrait pas les utiliser d un tap.

{$userBlock}
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

    /**
     * @param  array<int, array<string, string>>  $history
     * @return array<int, array{role: string, content: string}>
     */
    private function buildAnthropicMessages(array $history, string $latestUserMessage): array
    {
        $messages = [];

        foreach ($history as $item) {
            if (! is_array($item)) {
                continue;
            }
            $role = $item['role'] ?? '';
            $content = $item['content'] ?? '';
            if (! in_array($role, ['user', 'assistant'], true)) {
                continue;
            }
            $content = Str::limit((string) $content, 4000, '');
            if ($content === '') {
                continue;
            }
            $messages[] = ['role' => $role, 'content' => $content];
        }

        if (count($messages) > 24) {
            $messages = array_slice($messages, -24);
        }

        while (count($messages) > 0 && $messages[0]['role'] !== 'user') {
            array_shift($messages);
        }

        $messages[] = ['role' => 'user', 'content' => $latestUserMessage];

        return $messages;
    }

    private function getUserFromToken(Request $request): ?User
    {
        $token = $request->bearerToken() ?? $request->header('Authorization');
        if ($token) {
            $token = str_replace('Bearer ', '', $token);
            $decoded = base64_decode($token);
            $parts = explode('|', $decoded);
            if (count($parts) >= 3) {
                return User::find($parts[0]);
            }
        }

        return null;
    }

    /**
     * @param  mixed  $clientLatitude
     * @param  mixed  $clientLongitude
     * @param  mixed  $clientAccuracy
     */
    private function buildAppContext(
        $clientLatitude = null,
        $clientLongitude = null,
        $clientAccuracy = null,
    ): array {
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

        $out = [
            'generated_at' => now()->toIso8601String(),
            'announcements' => $announcements,
            'competition_sites' => $sites,
            'transport_shuttles' => $transports,
            'tourism_points' => $tourism,
            'latest_notifications' => $notifications,
        ];

        if ($this->isPresentNumeric($clientLatitude) && $this->isPresentNumeric($clientLongitude)) {
            $geo = [
                'latitude' => round((float) $clientLatitude, 6),
                'longitude' => round((float) $clientLongitude, 6),
                'source' => 'mobile_app',
                'hint' => 'Position envoyee par l application avec le consentement de l utilisateur pour ce message.',
            ];
            if ($this->isPresentNumeric($clientAccuracy)) {
                $geo['accuracy_meters'] = round((float) $clientAccuracy, 1);
            }
            $out['client_geolocation'] = $geo;
        }

        return $out;
    }

    private function isPresentNumeric(mixed $v): bool
    {
        if ($v === null || $v === '') {
            return false;
        }

        return is_numeric($v);
    }
}
