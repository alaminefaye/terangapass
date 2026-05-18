<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('promo_popups', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->string('sponsor_name')->nullable();
            $table->string('image_path');
            $table->string('link_url')->nullable();
            $table->string('link_label')->nullable();
            $table->string('placement')->default('home'); // home, map, tourism, all
            $table->unsignedSmallInteger('priority')->default(0);
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('ends_at')->nullable();
            $table->string('frequency')->default('once_per_day'); // once_per_day, every_open, always
            $table->unsignedBigInteger('impression_count')->default(0);
            $table->unsignedBigInteger('click_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['is_active', 'placement', 'priority']);
            $table->index(['starts_at', 'ends_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('promo_popups');
    }
};
