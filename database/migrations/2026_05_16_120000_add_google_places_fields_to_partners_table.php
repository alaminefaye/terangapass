<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->string('google_place_id', 128)->nullable()->unique()->after('id');
            $table->json('google_types')->nullable()->after('category');
            $table->timestamp('google_synced_at')->nullable()->after('google_types');
        });
    }

    public function down(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->dropColumn(['google_place_id', 'google_types', 'google_synced_at']);
        });
    }
};
