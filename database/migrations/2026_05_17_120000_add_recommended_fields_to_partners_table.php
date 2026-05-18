<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->boolean('is_recommended')->default(false)->after('is_sponsor');
            $table->unsignedSmallInteger('recommendation_priority')->default(0)->after('is_recommended');
            $table->string('recommendation_pitch', 200)->nullable()->after('recommendation_priority');
        });
    }

    public function down(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->dropColumn([
                'is_recommended',
                'recommendation_priority',
                'recommendation_pitch',
            ]);
        });
    }
};
