# App Store — ASO Paketi (Tahmin Et!)

**Bundle ID:** `com.appliculture.tahminet`  
**App Store ID:** `6761040009` (projede `StoreUrls.iosReview`)  
**Birincil dil:** Türkçe (Türkiye storefront)  
**Doküman son güncelleme:** Mayıs 2026

---

## 1) Derin ASO analizi (özet)

### Google Play ile birlikte okuyun

Play Console’da **arama kanalı** net ölçülüyor; App Store’da aynı satır satır rapor yok. Yine de Play’de kanıtlanan **niyet (intent)** kelimeleri, iOS’ta da aynı kullanıcıları çeker: “ben kimim”, “tahmin et”, “ben kimim oyunu”, “tahmin etme oyunları”. Bu yüzden **ASO metinleri iki mağazada aynı hikâyeyi anlatmalı** (cümle yapısı farklı olabilir).

### Play Console verilerinden çıkan stratejik gerçekler

| Bulgu | Yorum | iOS aksiyonu |
|--------|--------|----------------|
| **“ben kimim”** En yüksek adlandırılmış terim hacmi | Kategori + format araması güçlü | Title veya subtitle’da “Ben Kimim” görünürlüğünü koru; açıklamanın ilk ekranında tekrarla |
| **“tahmin et”** Çok yüksek dönüşüm | Marka / yüksek niyet araması | Marka adını title’da koru; gereksiz kelime harcaması yapma |
| **“tahmin etme oyunları”** Üçüncü sırada, kategori araması | Generic ama Play’de kanıtlanmış | Uzun açıklamada doğal biçimde geçir (keyword stuffing yok) |
| **“ben kimim oyunu”** Daha az hacim, yüksek CR | Uzun kuyruk ama kaliteli | Subtitle veya ilk paragrafta “oyunu” ile eşle |
| **“Other” (long-tail)** İndirmelerin çoğu | Binlerce farklı ifade | Açıklamada aile, parti, arkadaş, canlandırma, kelime tahmin varyasyonları |

### App Store’a özgü teknik kurallar

- **Title (30)** ve **Subtitle (30)** arama indeksine girer; **Keywords (100)** gizli alandır, virgülle **boşluksuz** ayrılır. Title/subtitle’da zaten olan kelimeleri keywords’te **tekrar etmek karakter israfıdır**.
- **“Tabu”** ve rakip markalar keywords’te risklidir: yanlış kullanıcı beklentisi veya **marka ihlali / inceleme** riski. Tercihen **kullanmayın**; ayrışma metnini açıklama gövdesinde “kelimeyi tahmin et, yasak kelime kartı yok” gibi nötr cümlelerle verin.
- **Screenshot caption** ve **In-App Event** isimleri ek indeks sinyali olabilir (OCR); ilk 3 ekran görüntüsüne güçlü Türkçe başlık eklemeyi düşünün.

### Funnel düşüncesi (Türkiye)

1. **Keşfet / Browse** → kategori + editorial (kontrol sizde değil)
2. **Arama** → title, subtitle, keywords kombinasyonları
3. **Ürün sayfası** → ilk 2–3 satır açıklama + ilk ekran görüntüsü → **dönüşüm**
4. **İndir** → güçlü sosyal kanıt (yorum) ve güncel “What’s New” güveni

iOS’ta arama terimlerini Play kadar göremeseniz bile, **yüksek CR’lı Play terimleri** genelde ürün sayfası metnine yansıtıldığında dönüşümü de destekler.

---

## 2) Mevcut canlı listeleme — App Store Connect (kopya, Mayıs 2026)

Aşağıdaki alanlar panelden alınmıştır; optimizasyon karşılaştırması için referans.

### Promotional Text (canlı)

```
Arkadaşlarınla eğlenceli bir tahmin oyunu! Deste seç, telefonu alnına koy, ipuçlarıyla kelimeyi tahmin et. Hızlı turlar, bol kahkaha.
```

### Description — ilk cümleler (canlı özeti)

- Giriş: Arkadaşlarla oynanan eğlenceli kelime tahmin oyunu.
- 50+ deste; nasıl oynanır ve özellikler maddeler halinde.
- EULA Apple standart linki ekli.

### Keywords — canlı (panelde görüldüğü gibi; uzunluk Apple limitiyle kısıtlanmalı)

```
tahmin,kelime,oyun,arkadaş,parti,tabu,ben kimim,eğlence,aile,grup,quiz,kelime oyunu
```

**Not:** Bu dize **100 karakter üzerinde** (boşluklu “ben kimim”, “kelime oyunu” iki kelime gibi yazılmış). App Store Connect’te ya kesilmiş ya da sistem reddeder/alanı kısar. **Tekrar:** `tabu` ve gereksiz tekrarlar optimize edilmeli.

### What's New — canlı

```
Performans iyileştirmeleri ve hata düzeltmeleri.
```

---

## 3) Önerilen güncellenmiş mağaza metinleri (yayına taşınabilir)

### Uygulama adı / Title (max 30 karakter)

```
Tahmin Et! - Ben Kimim?
```

**Karakter:** 23/30  

**Alternatif A/B (daha güçlü “oyunu” niyeti — Play’de “ben kimim oyunu” kanıtlı):**

```
Tahmin Et: Ben Kimim Oyunu
```

**Karakter:** 26/30  

**Strateji:** Mevcut başlık marka + “ben kimim” için güçlü. A/B: “Oyunu” ekleyerek uzun kuyruk indir (daha az marka şıklığı, daha fazla arama eşleşmesi).

### Alt başlık / Subtitle (max 30 karakter)

```
Kelime Tahmin · Alnına Koy
```

**Karakter:** 27/30  

**Alternatif:** `Parti Oyunu · Alnına Koy` (26) — parti/niyet vurgusu.

### Keywords alanı (max 100 karakter, virgül ayırıcı, boşluksuz)

Title/subtitle ile **çakışmayı** minimize et (Tahmin, Ben, Kimim, Kelime, Alnına — title/subtitle tercihinize göre güncelleyin):

```
charades,headsup,canlandirma,mimik,cizim,muzik,dizi,spor,grup,aile,arkadas,quiz,offline,tahminetme
```

**Karakter:** 98/100 — `tahminetme` Play’de işe yarayan “tahmin etme oyunları” kökünü karşılar.

**Çıkarılanlar:** `tabu` (risk + yanlış kitle); `ben kimim` / `tahmin` (çoğu title varyantında zaten var).

### Promotional Text (max 170 karakter, sık güncellenebilir)

```
50+ deste! Tahmin etme oyunu sevenler: alnına koy, ben kimim tarzı parti. Doğru aşağı, pas yukarı. Arkadaşlarla oyna.
```

**Karakter:** 117/170  

Play’de yüksek CR’lı terimler **doğal** biçimde gömülü: **tahmin etme**, **ben kimim**, **alnına koy**, **parti**.

### Açıklama / Description — önerilen taslak (ilk satırlar fold için kritik)

```
Tahmin Et! — arkadaşlarla oynanan ben kimim tarzı kelime tahmin ve parti oyunu. Telefonu alnına koy; tahmin etme oyunları ve canlandırma sevenler için ideal. En az iki kişi; aile ve arkadaş buluşmalarında kahkaha garantisi.

50+ DESTE (TÜRKÇE)
Hayvanlar, meyveler, markalar, ünlüler, filmler, diziler, müzik, spor, ülkeler, meslekler, çizgi film, çizim, canlandırma ve daha fazlası.

NASIL OYNANIR?
• Deste seç — destenin oynanışını oku
• Oyna — telefonu alnına yerleştir
• İpuçlarıyla kelimeyi tahmin et; doğruysa telefonu aşağı, pas için yukarı eğ
• Süre bitince özet: doğru ve geçilenler

NEDEN TAHMİN ET?
• Telefon hareketiyle kontrol — hızlı turlar
• Türkçe içerik; parti, grup ve aile oyunu olarak tasarlandı
• İsteğe bağlı VIP: tüm desteler ve reklamsız deneyim (uygulama içi paywall’da detay)

İndir, desteni seç, alnına koy!
```

Apple EULA cümlesi policy gereği kalabilir; mevcut standart linki koruyun:

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

---

## 4) App Store Connect — kategori ve uyumluluk

| Alan | Öneri |
|------|--------|
| **Birincil kategori** | Games |
| **İkincil kategori** | Word veya Entertainment |
| **Yaş derecelendirmesi** | Reklam + IAP ile güncel anket |
| **App Privacy** | AdMob, RevenueCat vb. güncel |

---

## 5) What's New — şablon (daha “canlı” görünüm)

```
• Daha akıcı oynanış ve performans iyileştirmeleri
• Arayüz ve kararlılık düzeltmeleri
```

Uzun “yasal metin” sürüm notunda gerekmez; kullanıcı güveni için somut fayda yazın.

---

## 6) IAP / abonelik görünen ad

- **Tahmin Et VIP** — Tüm desteler + reklamsız (mevcut ile uyumlu)

---

## 7) Görsel varlıklar — öncelik sırası

| Öğe | Öneri |
|-----|--------|
| **App Preview** | 15–30 sn; 0–2 sn “Alnına koy” + tilt |
| **İlk 3 screenshot** | 1) Alnında telefon + UI 2) 50+ deste ızgarası 3) Müzik/canlandırma veya grup sahnesi |
| **Başlıklar (ekran üstü)** | Türkçe 2–4 kelime: “Ben Kimim Tarzı”, “50+ Deste”, “Parti Modu” |

---

## 8) A/B ve ölçüm

| Test | A | B | KPI |
|------|---|---|-----|
| Subtitle | Kelime Tahmin · Alnına Koy | Parti Oyunu · Alnına Koy | Ürün sayfası görüntüleme → indirme |
| Title | Tahmin Et! - Ben Kimim? | Tahmin Et: Ben Kimim Oyunu | Gösterim → indirme |

App Store Connect **Product Page Optimization** ile screenshot/test.

---

## 9) Yerelleştirme (opsiyonel)

| Locale | Title | Subtitle |
|--------|-------|----------|
| **en-US** | Guess It! Who Am I Game | Word Party · On Your Forehead |
| **en-US Keywords** | charades,headsup,guessing,party,words,family,friends,acting,offline |

---

## 10) Karakter özeti

| Alan | Limit | Önerilen taslak |
|------|-------|------------------|
| Title | 30 | 23 veya 26 (varyant) |
| Subtitle | 30 | 27 |
| Keywords | 100 | 98 ✅ |
| Promotional | 170 | 117 ✅ |
| Description | 4000 | Yukarıdaki gövde + EULA satırı |

---

## 11) Yayın öncesi kontrol listesi

- [ ] Title ≤ 30  
- [ ] Subtitle ≤ 30  
- [ ] Keywords ≤ 100, boşluksuz virgül, title ile tekrar yok  
- [ ] İlk 3 satır: ben kimim / tahmin etme / alnına koy  
- [ ] Keywords’ten `tabu` çıkarıldı (öneri)  
- [ ] IAP ve reklam açıklamaları review notlarıyla uyumlu  
