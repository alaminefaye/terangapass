<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'mysql') {
            return;
        }

        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM('hotel','restaurant','pharmacy','hospital','embassy','consulate','other') NOT NULL DEFAULT 'other'"
        );
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'mysql') {
            return;
        }

        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM('hotel','restaurant','pharmacy','hospital','embassy','other') NOT NULL DEFAULT 'other'"
        );
    }
};
