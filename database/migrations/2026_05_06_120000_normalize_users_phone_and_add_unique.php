<?php

use App\Models\User;
use App\Support\PhoneNormalizer;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        User::query()->whereNotNull('phone')->where('phone', '!=', '')->orderBy('id')->each(function (User $user): void {
            $normalized = PhoneNormalizer::normalize((string) $user->phone, $user->country);
            if ($normalized === null) {
                return;
            }

            $preferred = User::query()
                ->where('phone', $normalized)
                ->where('id', '!=', $user->id)
                ->doesntExist();

            $canonical = $preferred ? $normalized : $normalized.'_'.$user->id;

            if ($user->phone !== $canonical) {
                $user->forceFill(['phone' => $canonical])->saveQuietly();
            }
        });

        Schema::table('users', function (Blueprint $table): void {
            $table->unique('phone');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            $table->dropUnique(['phone']);
        });
    }
};
