<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->string('type'); // sécurité, météo, circulation, consignes_joj
            $table->string('title');
            $table->text('description');
            $table->string('zone')->nullable(); // Zone géographique ciblée
            $table->json('target_locations')->nullable(); // Coordonnées ciblées
            $table->boolean('is_active')->default(true);
            $table->timestamp('scheduled_at')->nullable();
            $table->integer('sent_count')->default(0);
            $table->integer('viewed_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
