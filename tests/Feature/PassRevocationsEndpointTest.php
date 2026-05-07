<?php

namespace Tests\Feature;

use App\Models\PassTicket;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class PassRevocationsEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_revocations_forbidden_without_valid_control_header(): void
    {
        config(['services.teranga_pass.control_key' => 'expected-control']);

        $this->getJson('/api/v1/pass/revocations')
            ->assertStatus(403)
            ->assertJsonFragment(['success' => false]);
    }

    public function test_revocations_lists_revoked_tickets_when_authorized(): void
    {
        config(['services.teranga_pass.control_key' => 'expected-control']);

        $user = User::factory()->create();
        $publicId = (string) Str::ulid();

        PassTicket::create([
            'user_id' => $user->id,
            'public_id' => $publicId,
            'type' => 'joj_visitor_pilot',
            'status' => 'revoked',
            'valid_until' => now()->addYear(),
            'revoked_at' => Carbon::parse('2026-02-15 10:00:00', 'UTC'),
        ]);

        $response = $this->withHeaders([
            'X-Teranga-Pass-Control' => 'expected-control',
        ])->getJson('/api/v1/pass/revocations');

        $response->assertOk()
            ->assertJsonPath('data.count', 1)
            ->assertJsonPath('data.revoked.0.public_id', $publicId)
            ->assertJsonStructure([
                'data' => [
                    'revoked',
                    'count',
                    'generated_at',
                ],
            ]);
    }

    public function test_revocations_since_filters_by_revoked_at(): void
    {
        config(['services.teranga_pass.control_key' => 'k']);

        $user = User::factory()->create();

        PassTicket::create([
            'user_id' => $user->id,
            'public_id' => (string) Str::ulid(),
            'type' => 'joj_visitor_pilot',
            'status' => 'revoked',
            'valid_until' => now()->addYear(),
            'revoked_at' => Carbon::parse('2026-01-10 12:00:00', 'UTC'),
        ]);

        $newerId = (string) Str::ulid();
        PassTicket::create([
            'user_id' => $user->id,
            'public_id' => $newerId,
            'type' => 'joj_visitor_pilot',
            'status' => 'revoked',
            'valid_until' => now()->addYear(),
            'revoked_at' => Carbon::parse('2026-06-01 12:00:00', 'UTC'),
        ]);

        $response = $this->withHeaders([
            'X-Teranga-Pass-Control' => 'k',
        ])->getJson('/api/v1/pass/revocations?since=2026-03-01T00:00:00Z');

        $response->assertOk()
            ->assertJsonPath('data.count', 1)
            ->assertJsonPath('data.revoked.0.public_id', $newerId);
    }

    public function test_revocations_invalid_since_returns_422(): void
    {
        config(['services.teranga_pass.control_key' => 'k']);

        $this->withHeaders(['X-Teranga-Pass-Control' => 'k'])
            ->getJson('/api/v1/pass/revocations?since=not-a-date')
            ->assertStatus(422)
            ->assertJsonFragment(['success' => false]);
    }

    public function test_revocations_unavailable_when_control_key_not_configured(): void
    {
        config(['services.teranga_pass.control_key' => '']);

        $this->withHeaders(['X-Teranga-Pass-Control' => 'anything'])
            ->getJson('/api/v1/pass/revocations')
            ->assertStatus(503);
    }
}
