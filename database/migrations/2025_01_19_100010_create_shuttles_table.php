<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shuttles', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Ex: "Navettes Gratuites JOJ 2026", "Ligne Express-JOJ"
            $table->text('description')->nullable();
            $table->string('type')->default('regular'); // regular, express
            $table->date('start_date');
            $table->date('end_date');
            $table->string('start_location'); // Point de départ
            $table->string('end_location')->nullable(); // Point d'arrivée
            $table->decimal('start_latitude', 10, 8)->nullable();
            $table->decimal('start_longitude', 11, 8)->nullable();
            $table->decimal('end_latitude', 10, 8)->nullable();
            $table->decimal('end_longitude', 11, 8)->nullable();
            $table->integer('frequency_minutes')->nullable(); // Fréquence en minutes
            $table->time('first_departure')->nullable(); // Premier départ
            $table->time('last_departure')->nullable(); // Dernier départ
            $table->json('operating_days')->nullable(); // Jours de fonctionnement
            $table->boolean('is_secure_route')->default(true); // Itinéraire sécurisé
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('shuttle_stops', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shuttle_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->string('address')->nullable();
            $table->integer('order')->default(0); // Ordre sur l'itinéraire
            $table->timestamps();
        });

        Schema::create('shuttle_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shuttle_id')->constrained()->onDelete('cascade');
            $table->time('departure_time');
            $table->integer('day_of_week')->nullable(); // 0 = Dimanche, 6 = Samedi
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shuttle_schedules');
        Schema::dropIfExists('shuttle_stops');
        Schema::dropIfExists('shuttles');
    }
};
