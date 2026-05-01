<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE incidents MODIFY COLUMN type ENUM('perte','accident','suspect','autre') NOT NULL DEFAULT 'perte'"
        );
    }

    public function down(): void
    {
        DB::statement(
            "ALTER TABLE incidents MODIFY COLUMN type ENUM('perte','accident','suspect') NOT NULL DEFAULT 'perte'"
        );
    }
};
