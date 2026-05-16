<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->text('logo_url')->nullable()->change();
            $table->text('icon_path')->nullable()->change();
            $table->text('opening_hours')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('partners', function (Blueprint $table) {
            $table->string('logo_url')->nullable()->change();
            $table->string('icon_path')->nullable()->change();
            $table->string('opening_hours')->nullable()->change();
        });
    }
};
