<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AudioStorageService
{
    /**
     * Stocker un fichier audio
     */
    public function store(UploadedFile $file, string $directory = 'audio-announcements'): string
    {
        $filename = Str::uuid() . '.' . $file->getClientOriginalExtension();
        $path = $file->storeAs($directory, $filename, 'public');
        
        return Storage::url($path);
    }

    /**
     * Supprimer un fichier audio
     */
    public function delete(string $url): bool
    {
        // Extraire le chemin du fichier depuis l'URL
        $path = str_replace('/storage/', '', parse_url($url, PHP_URL_PATH));
        
        return Storage::disk('public')->delete($path);
    }

    /**
     * Obtenir la durée d'un fichier audio (en secondes)
     */
    public function getDuration(UploadedFile $file): ?int
    {
        // TODO: Utiliser une bibliothèque comme getID3 ou ffmpeg pour obtenir la durée
        // Pour l'instant, retourner null
        return null;
    }
}
