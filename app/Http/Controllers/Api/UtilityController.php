<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Carbon\Carbon;
use Illuminate\Http\Request;

class UtilityController extends Controller
{
    public function jojCountdown()
    {
        // Date d'ouverture JOJ Dakar 2026 (référence cahier des charges).
        $startDate = Carbon::create(2026, 10, 31, 0, 0, 0, 'Africa/Dakar');
        $today = Carbon::now('Africa/Dakar')->startOfDay();

        $days = $today->diffInDays($startDate, false);

        return response()->json([
            'data' => [
                'target_date' => $startDate->toDateString(),
                'days_remaining' => max(0, $days),
                'status' => $days < 0 ? 'started' : 'upcoming',
                'label' => 'Dakar 2026 - 31 oct -> 13 nov',
            ],
        ]);
    }

    public function convertCurrency(Request $request)
    {
        $validated = $request->validate([
            'amount' => ['required', 'numeric', 'min:0'],
            'from' => ['required', 'string', 'size:3'],
            'to' => ['required', 'string', 'size:3'],
        ]);

        $from = strtoupper($validated['from']);
        $to = strtoupper($validated['to']);
        $amount = (float) $validated['amount'];

        // MVP: taux fixes robustes pour XOF/EUR/USD.
        $baseRates = [
            'XOF' => 1.0,
            'EUR' => 655.957,
            'USD' => 600.0,
        ];

        if (!isset($baseRates[$from]) || !isset($baseRates[$to])) {
            return response()->json([
                'message' => 'Devise non supportée. Utiliser XOF, EUR ou USD.',
            ], 422);
        }

        // Conversion via base XOF.
        $amountInXof = $from === 'XOF' ? $amount : $amount * $baseRates[$from];
        $converted = $to === 'XOF' ? $amountInXof : $amountInXof / $baseRates[$to];

        return response()->json([
            'data' => [
                'from' => $from,
                'to' => $to,
                'amount' => $amount,
                'converted_amount' => round($converted, 2),
                'rate' => $from === $to
                    ? 1.0
                    : round(
                        ($to === 'XOF' ? 1.0 : 1.0 / $baseRates[$to]) /
                        ($from === 'XOF' ? 1.0 : 1.0 / $baseRates[$from]),
                        6
                    ),
                'source' => 'internal_fallback_rates',
            ],
        ]);
    }
}

