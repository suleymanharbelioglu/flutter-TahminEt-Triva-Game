# Tahmin Et — Yükseltme Planı

**Amaç:** Daha fazla gelir + daha iyi tutundurma (oyun döngüsüne zarar vermeden)  
**Dayanak:** `analytics/firebase-analiz.md` (28 gün, Eyl–Eki 2026)  
**İlke:** Önce ölçüm ve yıpratmayı kes → sonra para → sonra alışkanlık

---

## Faz 0 — Temel (1–3 gün) · Ölçümü aç

Ölçüm körken optimize etmek rastgele denemedir.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 0.1 | Custom dimension’lar | GA4’te aç: `deck_name`, `category`, `placement`, `ad_format`, `reason`, `product_id`, `source`, `action`, `status`, user: `is_premium` | Hangi deste/placement/ürün para veya terk getiriyor bilinmiyor (0 custom dim) |
| 0.2 | Ads çift log düzelt | `interstitial_shown` ayrıca `ads_shown` atmasın (tek kaynak) | Metrik şişiyor; karar yanlış çıkar |
| 0.3 | Gelir görünürlüğü | AdMob + IAP’nin Firebase/GA’da revenue olarak düştüğünü doğrula | Şu an GA revenue $0 — kör uçuş |

**Bitiş kriteri:** Explore’da `deck_name` / `placement` ile 24–48 saat veri akıyor.

---

## Faz 1 — Reklam (1 hafta) · Geliri kurtar, churn’ü kes

En büyük risk: fail + reklamda app kapatma. Daha çok basmak değil, daha temiz basmak.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 1.1 | Interstitial frekansı | Her oyun değil; örn. her **2–3 biten oyun**da 1 kez | `ads_closed_app` 1.4K user; agresif full-screen silmeye götürüyor |
| 1.2 | Interstitial yeri | Mümkünse oyun ortasından çıkar → **game_result / oyun sonu** | Oyun 11 dk değer üretiyor; ortada kesmek terk + kapatma riski |
| 1.3 | Fill / fail | AdMob mediation + geo (öz. AZ, TM, CA, AU) waterfall gözden geçir; `reason` logla | `ads_failed` ~33K ≈ shown’un yarısı; gösterilemeyen reklam = 0 gelir + kötü UX |
| 1.4 | Rewarded görünürlük | Kilitli deste / ekstra süre / “1 oyun daha” = rewarded izle | Rewarded user sadece %23.5; skip düşük → sunulunca izleniyor, az sunuluyor |
| 1.5 | KPI | Haftalık: `ads_closed_app` user ↓, fail oranı ↓, rewarded_watched ↑ | İyileşmeyi sayı ile doğrula |

**Bitiş kriteri:** closed_app user oranı belirgin düşer; fail/shown oranı geriler.

---

## Faz 2 — Premium / IAP (1–2 hafta) · Gerçekten sat

28 günde ~7 success → yol kırık. Ads’e bağımlılığı azaltır.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 2.1 | Engel → paywall | `deck_play_blocked` (2.7K) anında soft paywall veya net “Premium / Rewarded” seçimi | Engel var ama premium’a bağlanmıyor (`vip_locked_tap` ≈ 0) |
| 2.2 | Paywall içeriği | 3 net fayda (reklamsız, tüm desteler, …) + fiyat; 6 sn’de anlaşılır ekran | Premium ekran ort. **6 sn** — okunmadan çıkılıyor |
| 2.3 | Result CTA | `game_result`’ta “Reklamsız oyna” / Premium | Result 32 sn kısa; play_again %50 — aynı anda IAP fırsatı |
| 2.4 | Fiyat testi | Mümkünse haftalık + ömürlük (veya tek seferlik) karşılaştır | Tek fiyat + düşük traffic; hangisi dönüşür bilinmiyor |
| 2.5 | En iyi desteleri kilitle | 2–3 popüler desteyi VIP/reklamsız kapı yap | Değer hissi yoksa kimse ödemez; kilit “acı” üretmeli |
| 2.6 | purchase_failed | `reason` + store log incele (iptal mi hata mı) | started→failed event oranı yüksek (~%56) |

**Bitiş kriteri:** premium_viewed artar; viewed→success %2’nin üzerine çıkar; paywall süresi yükselir.

---

## Faz 3 — Retention (1–2 hafta) · LTV

User 1. haftada gidiyor → reklam/IAP fırsatı bir kez geliyor.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 3.1 | D0/D1 bildirim | “Yeni deste” / “Arkadaşlarla tekrar oyna” local notification | W1 retention **%14.6**; new >> returning |
| 3.2 | İlk oturum onboarding | 1 star deste + kısa how-to (how_to_play şu an az: 393 user) | İlk deneyim güçlü olursa 2. gün ihtimali artar |
| 3.3 | Abandon soft hook | `game_abandoned` sonrası “Kaldığın yerden” / aynı deste teklifi | Terk %24; yarım kalan oyun geri getirme kancası |
| 3.4 | Hafif daily hook | Günlük 1 ücretsiz “öne çıkan deste” veya mini streak | Parti oyunu yalnız tekrar gelmiyor; hafif ritüel gerekir |

**Bitiş kriteri:** D1 / W1 retention artar; returning / new oranı düzelir.

---

## Faz 4 — Oyun & UX cilası (paralel / sonra)

Core loop iyi; ince ayar gelir ve tutundurmayı destekler.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 4.1 | Timer default A/B | Örn. 60 vs 90 sn; `timer_changed` + abandon izle | timer_changed 26.5K — default yetersiz/kararsız |
| 4.2 | game_result güçlendir | Büyük “Tekrar” + “Başka deste” + soft rate | Result 32 sn; play_again fırsatı |
| 4.3 | Splash hızlandır | 17s ort. süreyi kısalt | İlk izlenim / gereksiz bekleme |
| 4.4 | Rate `action` | rated vs dismissed ayır | Prompt var ama kalite bilinmiyor |

---

## Faz 5 — Büyüme (sonra)

Önce LTV düzelsin; sonra traffic.

| # | Adım | Somut iş | Sebep |
|---|---|---|---|
| 5.1 | ASO TR + AZ | Screenshot, subtitle, keywords | %82 TR + %9 AZ; trafik zaten organik Play |
| 5.2 | Rating koru | Result sonrası iyi skorlu user’a rate | Rate prompt %31 user’a gidiyor; ASO’yu besler |
| 5.3 | UA (opsiyonel) | Küçük bütçe + UTM; ancak Faz 1–2 sonrası | Şimdi paid açmak kötü LTV’ye para yakar |
| 5.4 | iOS deneyi | Küçük iOS ASO/UA | iOS %8 ama engagement rate %84 — kaliteli niş |

---

## Önerilen takvim (özet)

```
Hafta 1     → Faz 0 + Faz 1 (ölçüm + reklam)
Hafta 2–3   → Faz 2 (premium)
Hafta 3–4   → Faz 3 (retention) + Faz 4 ince ayar
Hafta 5+    → Faz 5 (büyüme), verilere göre iterasyon
```

---

## Bilerek yapma

| Yapma | Sebep |
|---|---|
| Interstitial’ı daha sık bas | closed_app + remove artar, gelir kısa vadede yükselip LTV düşer |
| Core gameplay’i kökten değiştir | Oyun zaten uzun oynanıyor ve bitiriliyor |
| Custom dim olmadan “hangi deste” kararı | Veri yok; yanlış kilit/premium seçimi |
| LTV bozukken büyük UA | Aynı churn’ü pahalıya alırsın |

---

## Başarı metrikleri (28g’lik yeni pencere)

| Metrik | Şimdi (yaklaşık) | Hedef yön |
|---|---|---|
| W1 retention | %14.6 | ↑ |
| ads_failed / ads_shown | ~0.46 | ↓ |
| ads_closed_app users | 1.4K | ↓ |
| rewarded_ad_watched users | %23.5 | ↑ |
| premium viewed→success | %2.4 | ↑ |
| purchase_success users | 7 | ↑ |
| GA/AdMob gelir | görünür/ölçülü | ↑ |

---

*Bu plan “uygulamayı yükseltir” çünkü önce para sızıntısını (reklam/churn) keser, sonra IAP kapısını açar, sonra user’ı 2. güne taşır — oyun zaten çalışıyor.*
