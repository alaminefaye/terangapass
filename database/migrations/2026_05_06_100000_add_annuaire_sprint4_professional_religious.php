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
            . "'government','school','university','media',"
            . "'professional_service','religious_site',"
            . "'other'"
            . ") NOT NULL DEFAULT 'other'"
        );
    }

    public function down(): void
    {
        DB::statement(
            "UPDATE partners SET category = 'other' WHERE category IN ('professional_service','religious_site')"
        );
        DB::statement(
            "ALTER TABLE partners MODIFY COLUMN category ENUM("
            . "'hotel','restaurant','pharmacy','hospital','embassy','consulate',"
            . "'bank','gas_station','shop',"
            . "'notary','lawyer','doctor','clinic',"
            . "'government','school','university','media',"
            . "'other'"
            . ") NOT NULL DEFAULT 'other'"
        );
    }
};
