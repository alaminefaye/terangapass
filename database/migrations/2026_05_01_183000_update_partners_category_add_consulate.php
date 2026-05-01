<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM('hotel','restaurant','pharmacy','hospital','embassy','consulate','other') NOT NULL DEFAULT 'other'"
        );
    }

    public function down(): void
    {
        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM('hotel','restaurant','pharmacy','hospital','embassy','other') NOT NULL DEFAULT 'other'"
        );
    }
};
