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
            'ALTER TABLE partners MODIFY COLUMN category ENUM('
            ."'hotel','restaurant','pharmacy','hospital','embassy','consulate',"
            ."'bank','gas_station','shop','other'"
            .") NOT NULL DEFAULT 'other'"
        );
    }

    public function down(): void
    {
        if (Schema::getConnection()->getDriverName() !== 'mysql') {
            return;
        }

        DB::statement(
            "UPDATE partners SET category = 'other' WHERE category IN ('bank','gas_station','shop')"
        );
        DB::statement(
            'ALTER TABLE partners MODIFY COLUMN category ENUM('
            ."'hotel','restaurant','pharmacy','hospital','embassy','consulate','other'"
            .") NOT NULL DEFAULT 'other'"
        );
    }
};
