<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('audio_announcements', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('content');
            $table->string('language', 5)->default('fr'); // fr, en, es
            $table->string('audio_url');
            $table->integer('duration')->nullable(); // Durée en secondes
            $table->json('target_locations')->nullable(); // Zones géographiques ciblées
            $table->integer('play_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audio_announcements');
    }
};
