<?php

namespace Tests\Feature;

use Tests\TestCase;

class PublicGuestApiEndpointsTest extends TestCase
{
    public function test_nearby_and_tourism_are_public_without_bearer_token(): void
    {
        $this->getJson('/api/v1/nearby?latitude=14.69&longitude=-17.44&limit=5')
            ->assertSuccessful();

        $this->getJson('/api/v1/tourism/points-of-interest?limit=5')
            ->assertSuccessful();

        $this->getJson('/api/v1/places/recommended?limit=5')
            ->assertSuccessful();

        $this->getJson('/api/v1/joj/countdown')
            ->assertSuccessful();
    }
}
