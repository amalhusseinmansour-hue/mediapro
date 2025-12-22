# > /DJD '3*./'E Gemini H Claude AI

##  *E 'D*A9JD (F,'-!

*E %6'A) H*A9JD 'D0C'! 'D'57F'9J AJ *7(JBC:

### 1. **Google Gemini AI** =â
-  *E 'D*A9JD
- =Í API Key: `GEMINI_API_KEY`
- =° E,'FJ *E'E'K
- <¯ 'D'3*./'E: *HDJ/ 'DF5H5 Captions *-3JF 'DE-*HI

### 2. **Anthropic Claude AI** =ã
-  *E 'D*A9JD
- =Í API Key: `CLAUDE_API_KEY`
- =° E/AH9 (,H/) 9'DJ) ,/'K)
- <¯ 'D'3*./'E: E-*HI '-*1'AJ 7HJD C*'() %(/'9J)

---

##   *-0J1 #EFJ EGE ,/'K!

**DB/ 4'1C* 'DEA'*J- 9DF'K AJ 'DE-'/+)!**

### J,( 9DJC 'D"F:
1. L **%D:'! 'DEA'*J- 'D-'DJ) AH1'K**
2.  **%F4'! EA'*J- ,/J/)**:
   - Gemini: https://ai.google.dev ’ Get API Key
   - Claude: https://console.anthropic.com ’ API Keys ’ Create Key
3.  ***-/J+ 'DEDA'* 'D*'DJ)**:
   - `.env` (E-DJ)
   - `/home/u126213189/domains/mediaprosocial.io/public_html/.env` (3J1A1)
4.  E3- 'DC'4: `php artisan config:clear && php artisan cache:clear`

---

## =Í 'DEHB9 'D-'DJ DDEA'*J-

### AJ 'DEDA 'DE-DJ (`.env`):
```env
GEMINI_API_KEY=AIzaSyBLA_SRIy50VCg_xyjlH9Oe-igIybLYAKs
CLAUDE_API_KEY=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
```

### 9DI 'D3J1A1:
-  *E 'D*-/J+
-  *E E3- 'DC'4

---

## =€ CJAJ) 'D'3*./'E

### E+'D 31J9 - Gemini API

```php
<?php
// AJ Laravel Controller

use Illuminate\Support\Facades\Http;

class AIController extends Controller
{
    public function generateCaption(Request $request)
    {
        $apiKey = env('GEMINI_API_KEY');
        $topic = $request->input('topic');

        $response = Http::post(
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key={$apiKey}",
            [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => "'C*( caption ,0'( 9F: {$topic}"]
                        ]
                    ]
                ]
            ]
        );

        if ($response->successful()) {
            $text = $response->json()['candidates'][0]['content']['parts'][0]['text'];

            return response()->json([
                'success' => true,
                'caption' => $text
            ]);
        }

        return response()->json(['success' => false], 500);
    }
}
```

### E+'D - Claude API

```php
<?php

use Illuminate\Support\Facades\Http;

class AIController extends Controller
{
    public function writeArticle(Request $request)
    {
        $apiKey = env('CLAUDE_API_KEY');
        $topic = $request->input('topic');

        $response = Http::withHeaders([
            'x-api-key' => $apiKey,
            'anthropic-version' => '2023-06-01',
            'content-type' => 'application/json',
        ])->post('https://api.anthropic.com/v1/messages', [
            'model' => 'claude-3-sonnet-20240229',
            'max_tokens' => 1024,
            'messages' => [
                [
                    'role' => 'user',
                    'content' => "'C*( EB'D'K '-*1'AJ'K 9F: {$topic}"
                ]
            ]
        ]);

        if ($response->successful()) {
            $text = $response->json()['content'][0]['text'];

            return response()->json([
                'success' => true,
                'article' => $text
            ]);
        }

        return response()->json(['success' => false], 500);
    }
}
```

---

## =¡ #AC'1 DD'3*./'E AJ 'D*7(JB

### 1. *HDJ/ Captions *DB'&J'K
- 'DE3*./E JC*( EH6H9 'DEF4H1
- 21 "( *HDJ/ ('D0C'! 'D'57F'9J"
- J8G1 caption ,'G2 E9 G'4*'B'*

### 2. *-3JF 'DF5H5
- 'DE3*./E JC*( F5
- 21 "<¨ *-3JF 'DF5"
- 'DF5 J*-3F *DB'&J'K

### 3. 'B*1'- E-*HI
- "'B*1- DJ 5 #AC'1 DEF4H1'* 9F..."
- 'D0C'! 'D'57F'9J J97J #AC'1

### 4. *1,E) 0CJ)
- *1,E) 'DF5H5 (JF 'DD:'*
- E9 'D-A'8 9DI 'D3J'B H'DE9FI

### 5. *-DJD 'DE4'91
- *-DJD *9DJB'* 'DE*'(9JF
- E91A) GD %J,'(J) #E 3D(J)

---

## =° 'D*C'DJA

### Google Gemini:
-  **E,'FJ 100%**
- =Ê 'D-/: 60 7D(//BJB)
- =Ý 'D-/: 1,500 7D(/JHE
- <¯ **E+'DJ DD(/'J)**

### Anthropic Claude:
- =µ E/AH9
- =° $3 / 1M tokens (%/.'D)
- =° $15 / 1M tokens (%.1',)
- <¯ **DDE-*HI 'D'-*1'AJ**

### 'D*H5J):
'3*./E **Gemini** #HD'K (E,'FJ) +E **Claude** DDE-*HI 'DEGE ,/'K

---

## =Ú EH'1/ EAJ/)

### Google Gemini:
- =Ö https://ai.google.dev/docs
- <“ https://ai.google.dev/tutorials
- =» https://ai.google.dev/api

### Claude:
- =Ö https://docs.anthropic.com
- <“ https://github.com/anthropics/anthropic-cookbook
- =» https://docs.anthropic.com/claude/reference

---

##  'DED.5

### E' *E %F,'2G:
1.  %6'A) `GEMINI_API_KEY` AJ `.env` (E-DJ)
2.  %6'A) `CLAUDE_API_KEY` AJ `.env` (E-DJ)
3.  *-/J+ `.env` 9DI 'D3J1A1
4.  E3- 'DC'4 9DI 'D3J1A1
5.  %F4'! G0' 'D/DJD

### 'D.7H'* 'D*'DJ):
1.   **%D:'! 'DEA'*J- 'D-'DJ) H%F4'! ,/J/)** (EGE ,/'K!)
2. %F4'! ./E) AI AJ Laravel
3. %6'A) Routes DD@ API
4. /E,G' AJ Flutter
5. 'D'3*E*'9 ('D0C'! 'D'57F'9J! <‰

---

***E 'D*A9JD (F,'-! >(**

ED'-8): **D' *F3I *:JJ1 'DEA'*J-!** G0' EGE ,/'K DD#E'F.
