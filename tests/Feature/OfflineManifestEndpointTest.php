<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OfflineManifestEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_offline_manifest_returns_expected_shape(): void
    {
        config(['terangapass.offline_catalog_version' => 'test-9.9.9']);

        $response = $this->getJson('/api/v1/utility/offline-manifest');

        $response->assertOk()
            ->assertJsonPath('data.schema_version', 1)
            ->assertJsonPath('data.pack_version', 'test-9.9.9');
        $bundles = $response->json('data.bundles');
        $this->assertIsArray($bundles);
        $this->assertGreaterThanOrEqual(5, count($bundles));
        $ids = array_column($bundles, 'id');
        $this->assertContains('poi', $ids);
        $this->assertContains('competition_sites', $ids);
        $this->assertContains('embassies', $ids);
        $this->assertContains('competition_calendar', $ids);
        $this->assertContains('audio_announcements', $ids);

        $response->assertJsonStructure([
            'data' => [
                'schema_version',
                'pack_version',
                'generated_at',
                'min_app_semver',
                'bundles' => [
                    '*' => ['id', 'kind', 'url', 'sha256', 'byte_size'],
                ],
            ],
        ]);
    }
}
