<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OfflineBundleEndpointsTest extends TestCase
{
    use RefreshDatabase;

    public function test_offline_bundle_poi_returns_json_with_data_key(): void
    {
        $response = $this->get('/api/v1/utility/offline-bundle/poi');

        $response->assertOk();
        $response->assertJsonStructure(['data']);
    }

    public function test_offline_bundle_competition_sites_returns_json_with_data_key(): void
    {
        $response = $this->get('/api/v1/utility/offline-bundle/competition-sites');

        $response->assertOk();
        $response->assertJsonStructure(['data']);
    }

    public function test_offline_bundle_embassies_returns_json_with_data_key(): void
    {
        $response = $this->get('/api/v1/utility/offline-bundle/embassies');

        $response->assertOk();
        $response->assertJsonStructure(['data']);
    }

    public function test_offline_bundle_competition_calendar_returns_json_with_data_key(): void
    {
        $response = $this->get('/api/v1/utility/offline-bundle/competition-calendar');

        $response->assertOk();
        $response->assertJsonStructure(['data']);
    }

    public function test_offline_bundle_audio_announcements_returns_json_with_data_key(): void
    {
        $response = $this->get('/api/v1/utility/offline-bundle/audio-announcements');

        $response->assertOk();
        $response->assertJsonStructure(['data']);
    }
}
