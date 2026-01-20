<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\AudioAnnouncement;
use App\Services\AudioStorageService;
use Illuminate\Http\Request;

class AudioAnnouncementManagementController extends Controller
{
    protected $audioService;

    public function __construct(AudioStorageService $audioService)
    {
        $this->audioService = $audioService;
    }

    public function index(Request $request)
    {
        $query = AudioAnnouncement::query();

        if ($request->filled('language')) {
            $query->where('language', $request->language);
        }

        if ($request->filled('is_active')) {
            $query->where('is_active', $request->is_active);
        }

        $announcements = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('audio-announcements.index', compact('announcements'));
    }

    public function create()
    {
        return view('audio-announcements.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'language' => 'required|in:fr,en,es',
            'audio_file' => 'required|file|mimes:mp3,wav,ogg,m4a|max:10240', // 10MB max
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('audio_file')) {
            $audioUrl = $this->audioService->store($request->file('audio_file'));
            $duration = $this->audioService->getDuration($request->file('audio_file'));
            
            $validated['audio_url'] = $audioUrl;
            $validated['duration'] = $duration;
        }

        AudioAnnouncement::create($validated);

        return redirect()->route('admin.audio-announcements.index')
            ->with('success', 'Annonce audio créée avec succès.');
    }

    public function show(AudioAnnouncement $audioAnnouncement)
    {
        return view('audio-announcements.show', compact('audioAnnouncement'));
    }

    public function edit(AudioAnnouncement $audioAnnouncement)
    {
        return view('audio-announcements.edit', compact('audioAnnouncement'));
    }

    public function update(Request $request, AudioAnnouncement $audioAnnouncement)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'language' => 'required|in:fr,en,es',
            'audio_file' => 'nullable|file|mimes:mp3,wav,ogg,m4a|max:10240',
            'is_active' => 'boolean',
        ]);

        if ($request->hasFile('audio_file')) {
            // Supprimer l'ancien fichier
            if ($audioAnnouncement->audio_url) {
                $this->audioService->delete($audioAnnouncement->audio_url);
            }

            $audioUrl = $this->audioService->store($request->file('audio_file'));
            $duration = $this->audioService->getDuration($request->file('audio_file'));
            
            $validated['audio_url'] = $audioUrl;
            $validated['duration'] = $duration;
        }

        $audioAnnouncement->update($validated);

        return redirect()->route('admin.audio-announcements.index')
            ->with('success', 'Annonce audio mise à jour avec succès.');
    }

    public function destroy(AudioAnnouncement $audioAnnouncement)
    {
        if ($audioAnnouncement->audio_url) {
            $this->audioService->delete($audioAnnouncement->audio_url);
        }

        $audioAnnouncement->delete();

        return redirect()->route('admin.audio-announcements.index')
            ->with('success', 'Annonce audio supprimée avec succès.');
    }
}
