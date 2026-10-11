# Tahmin Et — Firebase Analiz (detaylı)

**Dönem:** 12 Eylül – 9 Ekim 2026 (28 gün)  
**Kaynak:** `firebase-veriler.md`  
**Ölçek:** ~3.1–3.7K aktif · ~2.5K yeni · ~623K event · GA gelir $0  
**Platform:** Android %91.7 · iOS %8.3 · Crash-free %100

---

## A. Yönetici özeti

| Alan | Durum | Tek cümle |
|---|---|---|
| Oyun deneyimi | İyi | Kullanıcılar uzun oynuyor, bitirme %73 |
| Tutundurma | Zayıf | 1. hafta retention %14.6 |
| Reklam | Riskli | Fail yüksek + reklamda app kapatma |
| Premium | Çok zayıf | Paywall 6 sn, başarı 7 user |
| Büyüme | Organik TR | %82 TR, Play organic baskın |
| Ölçüm | Kör | 0 custom dimension → parametre kırılımı yok |

**Ana tez:** Ürün “bir oturumda eğlendiriyor”; “ertesi gün geri getirmiyor”, “reklamda yıpratıyor”, “premium sattırmıyor”.

---

## 1. Genel sağlık & engagement

### Bulgular
- Kullanıcı başı ortalama **15 dk 28 sn** engagement; session **~8 dk**.
- Event / aktif kullanıcı **~198** → yoğun etkileşim.
- Engagement rate **%45.8**; engaged sessions / user **0.89**.
- Crash-free **%100** → teknik çökme engeli yok.
- 30g / 7g / 1g aktif: **3.4K / 943 / 143** → günlük taban küçük ama canlı.

### Neden
Oyun döngüsü (forehead → kart → doğru/pass) oturum içi değeri yüksek tutuyor. Stabilite sorunu olmadığı için düşük retention “ürün bozuk” değil, “alışkanlık yok” tarafına işaret ediyor.

### Yapılacak
- Engagement’ı koru; müdahaleleri (reklam/paywall) oyun akışını bozmayacak şekilde yerleştir.
- DAU/WAU oranını (143/943 ≈ %15) takip metriği yap.

---

## 2. Retention & churn

### Bulgular
| Metrik | Değer |
|---|---|
| New users | ~2.5K |
| Returning | ~1.3K |
| Week 1 retention | **%14.6** |
| Week 2–5 | %6.8 → %3.0 → %3.8 |
| app_remove | **1.730** event · **1.727** user (~aktiflerin yarısı bandı) |

### Değerlendirme
- Büyüme **yeni indirmeye bağımlı**; cohort hızla sönüyor.
- Week 5’te hafif toparlama (%3.8) kalıcı çekirdek (az sayıda sadık) olduğunu gösterir; ölçek küçük.
- `app_remove` yüksek → mağaza silme / deneme-bırakma yaygın.

### Neden
- Parti/forehead formatı sosyal anlık; yalnız tekrar gelme motivasyonu zayıf.
- Günlük hedef, streak, “yeni deste” bildirimi yok veya yetersiz görünüyor.
- İlk oturumda güçlü “neden yarın açayım?” kancası net değil.

### Yapılacak
1. D0/D1 local notification (yeni deste / “arkadaşlarla tekrar dene”).
2. İlk açılışta 1–2 star deste + kısa how-to (how_to_play zaten az kullanılıyor — §5).
3. `game_abandoned` sonrası “kaldığın yerden” soft hatırlatma.
4. Remove sonrası ASOya bak: yorum + screenshot vaadi ile gerçek deneyim uyumu.

---

## 3. Oyun funnel’ı

### Funnel sayıları
| Adım | Event | User | Oran |
|---|---:|---:|---|
| deck_opened | 19.749 | 2.708 | — |
| game_started | 23.688 | 2.576 | opened user’ın ~%95’i oyuna giriyor |
| game_finished | 17.197 | 2.044 | started’a göre **%72.6** (event) |
| game_abandoned | 5.759 | 1.900 | started’a göre **%24.3** |
| play_again | 8.534 | 1.463 | finished’a göre **%49.6** |

### Kart ekonomisi
| | Sayı | User |
|---|---:|---:|
| card_correct | 86.755 | 1.940 |
| card_pass | 68.271 | 2.346 |
| Doğru oranı | **%56** | — |
| Correct / finished user | ~42 kart | — |

### Diğer oyun sinyalleri
- `timer_changed` **26.5K** · 1.860 user → kullanıcıların yarısı süreyi kurcalıyor.
- `deck_play_blocked` **2.668** · 1.021 user → kilit/engel sık yaşanıyor.
- `vip_locked_tap` sadece **46** → VIP kilit UI’ı neredeyse hiç tetiklenmiyor veya görünmüyor.

### Değerlendirme
- **Core loop sağlam:** aç → oyna → bitir → yarısı tekrar.
- **Kritik sızıntı:** ~1/4 terk; abandon user sayısı (1.9K) finished user’a (2.0K) yakın → birçok kişi hem terk hem bitirmiş olabilir (çoklu oyun).
- Pass > doğru user (2.3K vs 1.9K) ama doğru event daha fazla → bilenler daha çok kart çözüyor.
- Timer kurcalama yoğun → default süre suboptimal veya belirsizlik var.

### Neden
Terk: süre yetmemesi, zor deste, reklam kesintisi, forehead yorgunluğu, bağlantı kopması.  
Blocked yüksek / vip_locked düşük → engel “VIP tap” değil başka reason (reklam destesi, net yokluğu vb.) olabilir — `reason` boyutu olmadan kesin değil.

### Yapılacak
1. Custom dim: `deck_name`, `remaining_seconds`, `reason` → abandon & blocked kırılımı.
2. Timer default A/B (örn. 60 vs 90 sn).
3. Oyun içi interstitial’ı terk korelasyonuyla gözden geçir.
4. `deck_play_blocked` reason’larını ürün kararına bağla (reklam vs premium vs net).

---

## 4. Ekran akışı (UX)

### Ana akış (views)
`splash` 8K → `decks` 20K → `deck_detail` 20K → `phone_to_forehead` 24K → `game` 24K → `game_result` 17K

### Süre / dikkat
| Ekran | Ort. süre | Yorum |
|---|---|---|
| game | **10m 43s** | Değer burada üretiliyor |
| AdActivity | 2m 22s | Reklam ciddi zaman yiyor |
| decks / MainActivity | ~1m | Liste gezinme normal |
| phone_to_forehead | 58s | Hazırlık makul |
| deck_detail | 50s | Timer ayarı burada (timer_changed ile uyumlu) |
| game_result | **32s** | Kısa — tekrar CTA güçlendirilebilir |
| premium | **6s** | Teklif okunmuyor |
| how_to_play | 13s · 393 user | Az kişi görüyor |
| splash | 17s | Biraz uzun olabilir |

### Sistem / SDK ekranları
- `AdActivity` + `GADFullScreenAdViewController` + webview’lar → reklam yüzeyi geniş.
- `SKStoreProductViewController` 1.3K view · 134 user → App Store sheet açılıyor (rate/cross-promo?).
- `UMPConsentViewController` 156 → consent az dokunuş (çoğu eski user / ATT yolu).
- `ProxyBillingActivity` 24 → IAP sheet çok nadir (premium funnel ile uyumlu).
- `(not set)` screen 2.9K user → ölçüm gürültüsü / background.

### Değerlendirme
Funnel ekranları dengeli; darboğaz **premium** ve **reklam süresi**. Result ekranı kısa → play_again fırsatı kaçıyor olabilir.

### Yapılacak
- game_result’a net “Tekrar” + “Başka deste” + soft rate.
- splash’i hızlandır (17s yüksek).
- how_to_play’i ilk oturuma opsiyonel chip olarak bağla (393 user az).

---

## 5. Reklam (öncelikli risk)

### Ölçek
| Event | Sayı | User | / user |
|---|---:|---:|---:|
| ads_shown | 72.525 | 2.736 | 26.6 |
| ads_failed | 33.431 | 2.223 | 15.1 |
| interstitial_shown | 21.485 | 2.539 | 8.5 |
| interstitial_failed | 6.799 | 372 | 18.5 |
| ads_closed_app | 3.371 | **1.426** | 2.4 |
| rewarded_ad_watched | 2.384 | 863 | 2.8 |
| ads_incomplete | 506 | 104 | 4.9 |
| rewarded_ad_skipped | 235 | 83 | 2.8 |

### Oransal okuma
- Fail, shown’un **~%46’sı** kadar (33K/73K) — fill/yükleme sorunu ciddi.
- Aktiflerin **%74’ü** reklam görüyor; **%39’u** (`ads_closed_app` user / aktif bandı) reklam sırasında uygulamayı kapatmış.
- Rewarded sadece **%23.5** user — opsiyonel unlock az kullanılıyor veya az sunuluyor.
- Rewarded skip düşük (235) → sunulunca çoğu izliyor; sorun sunum sıklığı.
- Realtime örnek: shown’da banner>interstitial; closed_app’te interstitial — kapatma full-screen’e bağlı.

### Ülke ipuçları (fail vs shown)
- `ads_failed` görece şişkin: **Azerbaijan, Turkmenistan, Canada, Australia**.
- `ads_shown` baskın: **Türkiye**.
→ Düşük fill / geo / network kalitesi fail’i şişiriyor olabilir.

### Ölçüm uyarısı
Kodda `interstitial_shown` ayrıca `ads_shown` da atıyor → **çift sayım**. “Ads/user” şişmiş olabilir.

### Neden
Mediation fill eksikliği, sık interstitial, zayıf ağ (`no_internet` ile örtüşebilir), full-screen yorgunluğu, çift log.

### Yapılacak
1. Çift log’u düzelt (tek `ads_shown` kaynağı).
2. Custom dim: `ad_format`, `placement`, `reason`.
3. Interstitial’ı oyun sonu / result’a kaydır; oyun ortasını azalt.
4. Fail geo’larında mediation waterfall gözden geçir.
5. Rewarded’ı `deck_play_blocked` noktasına daha görünür bağla.
6. `ads_closed_app` KPI olarak izle; eşik üstünde frekans düşür.

---

## 6. Premium & IAP

### Funnel
| Adım | Event | User |
|---|---:|---:|
| premium_viewed | 435 | 292 (~%8 aktif) |
| purchase_started | 27 | 14 |
| purchase_failed | 15 | 11 |
| purchase_success | 10 | **7** |
| restore_started / success | 37 / 31 | 5 / 2 |

| Dönüşüm | Oran |
|---|---|
| viewed → started | **%4.8** |
| started → success | %50 |
| viewed → success | **%2.4** |
| failed / started (event) | 15/27 ≈ **%56** fail |

### Ekran
premium: **432 view · 290 user · 6 sn** — teklif okunmadan çıkılıyor.

### Değerlendirme
- Ürün **görülmüyor** (traffic yok) ve **ikna etmiyor** (6 sn + düşük start).
- Checkout’a girenlerde yarı başarı var ama hacim çok küçük.
- Fail oranı start’a göre yüksek → fiyat/ödeme/iptal veya test hesabı gürültüsü.
- GA **Total revenue $0** → IAP GA’ya purchase olarak düşmüyor veya gerçekten ihmal edilebilir.
- `vip_locked_tap` 46 vs `deck_play_blocked` 2.7K → kilit deneyimi premium’a bağlanmıyor.

### Neden
Zayıf discoverability, belirsiz değer önerisi, kısa paywall, engel anlarında premium CTA yok/yanlış, ölçüm kopukluğu.

### Yapılacak
1. `deck_play_blocked` / reklam skip sonrası soft paywall.
2. Paywall’da 3 net fayda + sosyal kanıt; 6 sn’yi 20+ sn’ye çıkaracak içerik.
3. purchase_failed `reason` custom dim + store log.
4. GA4 purchase / AdMob revenue bağlantısını doğrula.
5. Restore UI’ı az kişi kullanıyor (5 user) — ayarlardan erişilebilir tut.

---

## 7. Coğrafya & pazar

### Dağılım
- **Türkiye %82**, **Azerbaijan %9** → geri kalan diaspora/Avrupa ince kuyruk.
- Avrupa TR diasporası (DE, FR, NL, AT, UK…) küçük ama engagement süreleri çoğu yerde 7–15 dk — içerik rezonansı var.
- North Macedonia / Kazakhstan gibi ülkelerde süre çok yüksek (küçük örneklem, dikkatli yorum).
- ABD süre düşük (4m 31s) → dil/ürün uyumsuzluğu veya yanlış indirme.

### Event bazlı
- Oyun ve reklam event’leri TR ağırlıklı (beklenen).
- `att_result`’ta DE oranı görece yüksek (iOS/ATT coğrafyası).
- `ads_failed` AZ/TM/CA/AU şişkin → fill.
- Purchase success çoğunluk TR (9/10).

### Şehir (7g)
İstanbul > Ankara > İzmir > Bakü → büyük şehir + Bakü (AZ) doğrulanıyor. Adana 7g’de hızlı büyümüş (+%58) — kampanya/ASO dalgası olabilir.

### Yapılacak
- Yol haritası: **TR + AZ** içerik ve ASO.
- DE/FR/NL için Türkçe yeterli; ayrı lokalizasyon acil değil.
- Fail yüksek ülkelerde reklam config ayır (veya waterfall).

---

## 8. Platform & versiyon

| | Android | iOS |
|---|---|---|
| User | %91.7 | %8.3 |
| Engagement rate | %43 | **%84** |
| Ort. süre | 15m 39s | 13m 31s |

- iOS az ama **daha engaged session oranı yüksek** — kaliteli niş.
- Versiyon: **1.2.8** baskın (Android), **1.2.9** iOS bandı; 1.2.10 ihmal edilebilir.
- FlutterViewController ~263 user ≈ iOS kitlesi — tutarlı.

### Yapılacak
- iOS’ta ATT + premium denemeleri (küçük ama engaged).
- Android’de reklam agresyonunu yumuşat (hacim burada).

---

## 9. Kazanım (acquisition)

### 7g (Home)
- First user: **google-play / organic** 823 · direct 84 · google organic 4.
- Session: Play organic ~1.2K · direct 157.
- Paid UA görünmüyor (veya Unassigned’a kaçıyor).

### Değerlendirme
Büyüme organik Play’e bağlı; ücretli kanal yok/ölçülmüyor. ASO ve rating kritik.

### Yapılacak
- ASO (TR/AZ) + rating funnel’ı koru.
- UA açılacaksa UTM + campaign custom dim şart.
- Unassigned 158 session → attribution boşluklarını kapat.

---

## 10. Rate, ATT, ağ, diğer

### Rate
- shown 1.284 · 1.154 user (%31 aktif)
- action 1.219 · 1.116 user → **~%97 aksiyon** (rated veya dismissed)
- Parametre `action` custom dim olmadığı için rated/dismissed ayrılamıyor.

**Yorum:** Prompt sık ve çoğu yanıtlıyor — iyi; kalite için `action` kırılımı şart.

### ATT
- 851 event · 254 user · /user 3.35 → bir user birden fazla status (notDetermined→denied/authorized).
- DE’de görece yoğun.

**Yapılacak:** `status` custom dim; pre-prompt ekranı test et.

### Ağ
- `no_internet_shown` 2.5K · 663 user (%18) · /user 3.8
- Fail reklamla birlikte düşünülmeli (offline/zayıf net → ad fail).

### Yapılacak
- Offline moda net mesaj; reklamı net yokken deneme.
- Rate prompt’ta `action` boyutunu aç; negatif dismiss oranını izle.

---

## 11. Ölçüm & veri kalitesi

### Kritik boşluk
- **0 custom dimension** → `deck_name`, `placement`, `product_id`, `reason`, `action`, `status` için 28g rapor yok.
- Parametreler kodda var; GA4 tarihsel raporlamıyor.
- BigQuery export yok.

### Diğer sorunlar
- `interstitial_shown` + `ads_shown` çift sayım.
- Aktif user Events (3.673) vs Tech (3.150) farkı → tanım/filtre farkı; kıyaslarken tek tablo kullan.
- Gender/Age “No data”.
- GA revenue $0 — IAP/ads geliri GA’da görünmüyor.
- `(not set)` screen gürültüsü.

### Yapılacak (ölçüm backlog)
| Öncelik | Dimension | Scope |
|---|---|---|
| P0 | deck_name, category | Event |
| P0 | placement, ad_format, reason | Event |
| P0 | product_id, source | Event |
| P0 | is_premium | User |
| P1 | action (rate), status (ATT), direction (timer) | Event |
| P1 | BigQuery export | — |
| P0 | Çift ads log düzelt | Kod |

---

## 12. Çelişkiler & dikkat notları

1. **Oyun sevilmiş ≠ ürün sticky** — session uzun, week-1 düşük.
2. **Blocked yüksek, VIP tap yok** — engel tipi premium itch yaratmıyor.
3. **Rewarded skip düşük, izleyen az** — problem sunum; kalite değil.
4. **Purchase fail ≈ start** — checkout sürtünmesi veya test gürültüsü.
5. **iOS small & engaged** — büyütülürse reklam/ATT dengesi ayrı tasarlanmalı.

---

## 13. Yapılacaklar — öncelik listesi

### P0 (hemen)
1. Custom dimension setini aç (deck, ads, product, is_premium).
2. Ads çift log’unu kaldır.
3. Interstitial frekansını düşür / oyun sonuna al; `ads_closed_app` izle.
4. Ad fail reason + geo’ya göre mediation düzelt.

### P1 (1–2 sprint)
5. D0/D1 retention kancası (notification + onboarding deste).
6. `deck_play_blocked` → soft paywall.
7. Paywall metin/değer A/B; premium ekran süresini artır.
8. game_result CTA güçlendir (play_again).
9. Rate `action` kırılımı.

### P2
10. Timer default A/B.
11. ASO TR/AZ + rating.
12. BigQuery / GA revenue bağlantısı.
13. iOS büyüme deneyi (küçük budget).

---

## 14. Tek bakışta skor

| Boyut | Skor (1–5) | Gerekçe |
|---|:---:|---|
| Core gameplay | 4 | Süre + bitirme + play_again |
| Retention | 2 | W1 %14.6, remove yüksek |
| Ads UX / fill | 2 | Fail + closed_app |
| Monetization IAP | 1 | 7 success, 6 sn paywall |
| Acquisition | 3 | Organik TR sağlam, paid yok |
| Data maturity | 1 | 0 custom dim |
| Stability | 5 | %100 crash-free |

---

*Sonuç: Önce ölçümü aç ve reklamı yumuşat; sonra retention ve premium. Oyun döngüsüne dokunma — o taraf çalışıyor.*
