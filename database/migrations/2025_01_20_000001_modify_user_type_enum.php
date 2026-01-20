<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Pour MySQL, on doit modifier l'ENUM en recréant la colonne
        DB::statement("ALTER TABLE `users` MODIFY COLUMN `user_type` ENUM('admin', 'athlete', 'visitor', 'citizen', 'volunteer') DEFAULT 'visitor'");
        
        // Mettre à jour l'utilisateur admin si il existe
        DB::table('users')
            ->where('email', 'admin@terangapass.com')
            ->update(['user_type' => 'admin']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revenir à l'ancien ENUM
        DB::statement("ALTER TABLE `users` MODIFY COLUMN `user_type` ENUM('athlete', 'visitor', 'citizen') DEFAULT 'visitor'");
        
        // Mettre à jour l'admin en 'visitor'
        DB::table('users')
            ->where('email', 'admin@terangapass.com')
            ->update(['user_type' => 'visitor']);
    }
};
