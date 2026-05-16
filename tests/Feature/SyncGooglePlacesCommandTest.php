<?php

namespace Tests\Feature;

use App\Models\Partner;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class SyncGooglePlacesCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_command_imports_place_from_nearby_search(): void
    {
        config(['google.maps_api_key' => 'test-key']);

        Http::fake([
            'maps.googleapis.com/maps/api/place/nearbysearch/json*' => Http::response([
                'status' => 'OK',
                'results' => [
                    [
                        'place_id' => 'ChIJ_test_restaurant',
                        'name' => 'Restaurant Test',
                        'vicinity' => 'Plateau, Dakar',
                        'types' => ['restaurant', 'food'],
                        'rating' => 4.2,
                        'geometry' => ['location' => ['lat' => 14.69, 'lng' => -17.44]],
                    ],
                ],
            ]),
            'maps.googleapis.com/maps/api/place/details/json*' => Http::response([
                'status' => 'OK',
                'result' => [
                    'formatted_address' => 'Plateau, Dakar, Sénégal',
                    'formatted_phone_number' => '+221 33 000 00 00',
                    'opening_hours' => ['weekday_text' => ['lundi: 09:00–18:00']],
                ],
            ]),
            'maps.googleapis.com/maps/api/place/textsearch/json*' => Http::response([
                'status' => 'ZERO_RESULTS',
                'results' => [],
            ]),
        ]);

        $this->artisan('places:sync-google', ['--type' => 'restaurant'])
            ->assertSuccessful();

        $this->assertDatabaseHas('partners', [
            'google_place_id' => 'ChIJ_test_restaurant',
            'name' => 'Restaurant Test',
            'category' => 'restaurant',
        ]);

        $partner = Partner::query()->where('google_place_id', 'ChIJ_test_restaurant')->first();
        $this->assertNotNull($partner);
        $this->assertSame('+221 33 000 00 00', $partner->phone);
    }
}
