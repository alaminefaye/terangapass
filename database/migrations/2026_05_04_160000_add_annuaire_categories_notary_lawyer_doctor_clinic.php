<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM("
            . "'hotel','restaurant','pharmacy','hospital','embassy','consulate',"
            . "'bank','gas_station','shop',"
            . "'notary','lawyer','doctor','clinic',"
            . "'other'"
            . ") NOT NULL DEFAULT 'other'"
        );
    }

    public function down(): void
    {
        DB::statement(
            "UPDATE partners SET category = 'other' WHERE category IN ('notary','lawyer','doctor','clinic')"
        );
        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM("
            . "'hotel','restaurant','pharmacy','hospital','embassy','consulate',"
            . "'bank','gas_station','shop','other'"
            . ") NOT NULL DEFAULT 'other'"
        );
    }
};
