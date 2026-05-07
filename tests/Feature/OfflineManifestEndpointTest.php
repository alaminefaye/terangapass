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
        $this->assertGreaterThanOrEqual(2, count($bundles));
        $this->assertSame('poi', $bundles[0]['id'] ?? null);
        $this->assertSame('competition_sites', $bundles[1]['id'] ?? null);

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
