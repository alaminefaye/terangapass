<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zones', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Ex: "Dakar Plateau", "Ouakam", etc.
            $table->text('description')->nullable();
            $table->json('polygon_coordinates'); // Coordonnées du polygone de la zone
            $table->decimal('center_latitude', 10, 8)->nullable();
            $table->decimal('center_longitude', 11, 8)->nullable();
            $table->boolean('is_active')->default(true);
            $table->integer('population_estimate')->nullable(); // Estimation population
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('zones');
    }
};
