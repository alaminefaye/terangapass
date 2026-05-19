<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\View\View;

class LegalController extends Controller
{
    public function termsOfUse(): View
    {
        return view('legal.terms-of-use', $this->legalContext('fr'));
    }

    public function termsOfUseEn(): View
    {
        return view('legal.terms-of-use-en', $this->legalContext('en'));
    }

    public function privacyPolicy(): View
    {
        return view('legal.privacy-policy', $this->legalContext('fr'));
    }

    public function privacyPolicyEn(): View
    {
        return view('legal.privacy-policy-en', $this->legalContext('en'));
    }

    /**
     * @return array<string, mixed>
     */
    private function legalContext(string $locale): array
    {
        return [
            'locale' => $locale,
            'contactEmail' => config('legal.contact_email'),
            'publisher' => config('legal.publisher'),
            'lastUpdated' => config('legal.last_updated'),
            'appName' => config('app.name', 'Teranga Pass'),
        ];
    }
}
