<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('user_type', ['admin', 'athlete', 'visitor', 'citizen', 'volunteer'])->default('visitor')->after('email');
            $table->string('country', 2)->default('SN')->after('user_type');
            $table->string('phone')->nullable()->after('country');
            $table->string('language', 5)->default('fr')->after('phone');
            $table->timestamp('last_active_at')->nullable()->after('language');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['user_type', 'country', 'phone', 'language', 'last_active_at']);
        });
    }
};
