<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('competition_sites', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // Ex: "Stade Olympique", "Dakar Arena"
            $table->text('description')->nullable();
            $table->string('location'); // Ex: "Dakar Centre"
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('address')->nullable();
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->json('sports')->nullable(); // Liste des sports pratiqués
            $table->text('access_info')->nullable(); // Informations d'accès
            $table->json('facilities')->nullable(); // Équipements disponibles
            $table->integer('capacity')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('competition_sites');
    }
};
