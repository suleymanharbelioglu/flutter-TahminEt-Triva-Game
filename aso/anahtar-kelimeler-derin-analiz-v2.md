# Tahmin Et! — Derin ASO Anahtar Kelime Analizi (Google Play Öncelikli)

**Uygulama:** Tahmin Et! — Ben Kimim tarzı kelime tahmin / parti oyunu
**Paket:** `com.appliculture.tahmin_et`
**Pazar:** Türkiye (tr-TR)
**Doküman:** Mayıs 2026 — Play Console verisi + rakip araştırması

---

## 0) Temel felsefe: Bu doküman neyi farklı yapıyor?

Önceki versiyon 1–5 arasında elle girilmiş tahmin skorları kullanıyordu. Bu versiyon üç katmanlı gerçek veri üzerine kurulu:

1. **Play Console "Search terms" raporu** — gerçek indirme ve dönüşüm sayıları
2. **Rakip mağaza sayfaları araştırması** — Türkiye'deki aynı niyet alanındaki uygulamaların başlık, açıklama ve keyword seçimleri
3. **Kullanıcı niyeti (intent) haritalaması** — arama teriminin arkasındaki beklenti ve "yanlış kitle" riski

Hiçbir skor tabloya "çünkü sezgi" ile girmedi.

---

## 1) Play Console Verisi — Ham Gerçek (Mayıs 2026)

### Genel tablo

| Metrik | Değer | Önceki dönem |
|--------|------:|-------------|
| Arama ziyaretçisi | 4.318 | +%131 |
| Arama indirmesi | 1.571 | +%177 |
| Dönüşüm oranı | %36,4 | +6,05 puan |

### Adlandırılmış terimler (görüntüden okunan)

| Sıra | Arama terimi | İndirme | Büyüme |
|:----:|-------------|--------:|--------|
| 1 | **ben kimim** | 349 | — (ilk dönem veya karşılaştırma yok) |
| 2 | **tahmin etme oyunları** | 69 | +%1,47 |
| 3 | **tahmin et** | 77 | +%60,42 |
| 4 | **ben kimim oyunu** | 32 | — |
| — | **Other (long-tail)** | 1.014 | +%144,93 |

**Toplam adlandırılmış:** 527 indirme (%33,5)
**Toplam long-tail (Other):** 1.014 indirme (%64,5)

### Kritik çıkarım: Asıl para long-tail'de

Adlandırılmış 4 terim toplam indirmenin yalnızca üçte birini oluşturuyor. Geri kalan %64,5 yüzlerce küçük aramadan geliyor. Bu "Other" kümesini anlamak stratejinin merkezinde olmalı.

**"Other" kümesinde büyük ihtimalle ne var?**
Play Console'un göstermediği ama kullanıcıların büyük olasılıkla yaptığı aramalar (rakip araştırması + kullanıcı niyeti mantığıyla türetildi):

- "alnına koy oyunu", "telefonu alnına koy"
- "kelime oyunu arkadaşlarla", "arkadaşlarla oyun"
- "sessiz sinema oyunu", "canlandırma oyunu"
- "aile oyunu", "grup oyunu"
- "çizim oyunu", "mırıldanma oyunu"
- "türkçe kelime oyunu", "türk dizileri oyunu"
- "eğlenceli oyun", "parti oyunu ücretsiz"

**Öneri:** Play Console → Store performance → Search terms → "Explore" butonuna tıkla. Bu liste genişletilebilir ve en az top 30 terimi görebilirsin. Bu analizi güncellemek için o raporu CSV olarak indir.

---

## 2) Rakip Haritası — Türkiye (Mayıs 2026 Araştırması)

"Ben kimim" ve "alnına koy" aramalarında karşına çıkan gerçek rakipler:

### Ana rakipler

| Rakip | Mekanik | Başlıkta ne söylüyor | Güçlü yönü | Senin fırsatın |
|-------|---------|---------------------|------------|----------------|
| **Nebuu** (iOS ağırlıklı) | Alnına koy, kelime tahmin | "Kelime Oyunu kategorisi 1.si" | Türkçe içerik, 88+ deste | Play'de zayıf varlık; Play'deki boşlukta sen varsın |
| **Guess Up / Charades** (global) | Alnına koy, charades | "Heads up guessing games for parties" | 25 dil, global kitle | Türkçe içerik yok; sen bunu kapatıyorsun |
| **Ben Kimim? Alındaki Kelime** (`com.handsUp.rondi.app`) | Aynı mekanik | "Ben Kimim? Alındaki Kelime" | Arama terimini doğrudan başlığa almış | İçerik kalitesi ve deste çeşitliliğiyle geç |
| **Ben Kimim? Tahmin Oyunu** (Tosson Gaming) | Ünlü tahmini | "Ben Kimim? Tahmin Oyunu" | Uzun süreli mağazada var | 2020'den güncelleme yok; rating düşük (3,49); ölü rakip |
| **Tahmin et - Ben kimim?** (`com.rot.tahminEtBenKimim`) | Benzer | "Fun specials, categories. Turkish culture." | İsim benzerliği | İngilizce açıklama = Türkçe kullanıcıya zayıf sinyal |
| **Tabu Resmi Oyunu** | Farklı mekanik (yasak kelime) | "The famous party game on mobile" | Marka gücü | Farklı niyet; hedefleme riski |
| **Heads Up!** (Warner Bros) | Global alnına koy | "Get the Party Started" | Dev marka ve global deste | Türkçe içerik eksik; Türkiye'de yetersiz |

### Rakip boşluklardan fırsat özeti

- "Ben kimim" aramasında hem **doğru niyet** hem **Türkçe deste** birleşimini en kapsamlı sunan uygulama sen olabilirsin.
- Nebuu iOS'ta güçlü, Play'de zayıf. Play'deki "Türkçe alnına koy" araması senin ana alanın.
- Güncellenmemiş rakipler (Tosson Gaming, 2020) hâlâ sıralarda duruyor ama kullanıcı gözünde güven kaybetmiş; "What's New" ve güncel içerik sinyalleri seni ayırt eder.

---

## 3) Kullanıcı Niyeti Haritası

Her arama terimi bir **niyet** taşır. Yanlış niyeti çeken kelime, indirme sağlasa bile düşük rating ve yüksek uninstall'a yol açar.

| Arama terimi | Niyet | Uyum skoru (1-5) | Risk |
|-------------|-------|:-----------------:|------|
| ben kimim | "Alnına koy, birini tahmin et" formatı arıyor | 5 | Yok |
| tahmin et | Markanı doğrudan arıyor veya genel tahmin oyunu | 5 | Yok |
| tahmin etme oyunları | Genel kategori, çok oyunculu olsun istiyor | 5 | Yok |
| ben kimim oyunu | Yukarıdakinin "oyunu" eklenmiş versiyonu | 5 | Yok |
| alnına koy oyunu | Tam mekanik araması | 5 | Yok |
| kelime oyunu | Geniş alan; tek kişilik kelime oyunu da buraya giriyor | 3 | Yanlış kitle riski |
| tabu oyunu | "Yasak kelime" mekaniği arıyor | 1 | YÜKSEK — farklı mekanik |
| sessiz sinema | Hareketsiz canlandırma arıyor | 4 | Düşük; deste varsa uyumlu |
| parti oyunu | Çok geniş; çeşitli oyunlar burada | 4 | Orta; ilk ekran görüntüsü netlik sağlamalı |
| aile oyunu | Tüm yaşlar için oyun arıyor | 4 | Düşük; içerik uyumlu |
| canlandırma oyunu | Mimik/acting arıyor | 5 | Yok; deste varsa güçlü |
| çizim oyunu | "Çiz anlat" mekaniği arıyor | 4 | Orta; çizim destesi varsa uyumlu |
| mırıldanma oyunu | Şarkı tahmini arıyor | 5 | Yok; müzik destesi varsa güçlü |
| bilgi yarışması / trivia | Soru-cevap, tek kişilik | 1 | YÜKSEK — tamamen farklı niyet |
| online multiplayer | İnternette eşleşme arıyor | 1 | YÜKSEK — offline mekanik |

---

## 4) Anahtar Kelime Stratejik Tablosu (Gerçek Veriyle)

### Metodoloji (revize)

| Kriter | Kaynak | Ölçek |
|--------|--------|-------|
| **İndirme kanıtı** | Play Console ekran görüntüsü | Gerçek sayı |
| **Büyüme** | Play Console "vs previous period" | % değişim |
| **Rakip yoğunluğu** | Mağaza araştırması (Mayıs 2026) | 1=az, 5=çok yoğun |
| **Niyet uyumu** | Bölüm 3 tablosu | 1–5 |
| **ASO önceliği** | Kanıt × uyum ÷ risk | P0/P1/P2/Kaçın |

### Tam tablo (kanıta göre sıralı)

| # | Anahtar kelime | İndirme kanıtı | Büyüme | Rakip yoğunluk | Niyet uyumu | Öncelik | Nereye koy |
|---|----------------|:--------------:|:------:|:--------------:|:-----------:|:-------:|------------|
| 1 | **ben kimim** | 349 ✅ Console | Yeni | Yüksek (4/5) | 5/5 | **P0** | Başlık + açıklama ilk paragraf |
| 2 | **tahmin et** | 77 ✅ Console | +%60 | Orta (3/5) | 5/5 | **P0** | Başlık — marka, koruyun |
| 3 | **tahmin etme oyunları** | 69 ✅ Console | +%1 | Orta (3/5) | 5/5 | **P0** | Uzun açıklamada doğal geçir |
| 4 | **ben kimim oyunu** | 32 ✅ Console | Yeni | Orta (3/5) | 5/5 | **P0** | Kısa açıklama veya başlık A/B |
| 5 | **alnına koy oyunu** | Other içinde ✦ | +%145 Other | Düşük (2/5) | 5/5 | **P1** | Kısa açıklama + screenshot başlığı |
| 6 | **telefonu alnına koy** | Other içinde ✦ | +%145 Other | Düşük (2/5) | 5/5 | **P1** | İlk screenshot caption |
| 7 | **canlandırma oyunu** | Other tahmini | Bilinmiyor | Düşük (2/5) | 5/5 | **P1** | Uzun açıklama gövdesi |
| 8 | **kelime tahmin oyunu** | Other tahmini | Bilinmiyor | Orta (3/5) | 5/5 | **P1** | Açıklama ilk bölüm |
| 9 | **sessiz sinema oyunu** | Other tahmini | Bilinmiyor | Düşük (2/5) | 4/5 | **P1** | Açıklama gövdesi |
| 10 | **arkadaşlarla oyun** | Other tahmini | +%145 Other | Yüksek (4/5) | 5/5 | **P1** | Açıklama + feature graphic |
| 11 | **parti oyunu** | Other tahmini | +%145 Other | Çok yüksek (5/5) | 4/5 | **P1** | Açıklama; başlıkta yalnız kullanma |
| 12 | **aile oyunu** | Other tahmini | Bilinmiyor | Yüksek (4/5) | 4/5 | **P1** | Açıklama — "kimler için" bölümü |
| 13 | **grup oyunu** | Other tahmini | Bilinmiyor | Orta (3/5) | 5/5 | **P1** | Açıklama |
| 14 | **mırıldanma oyunu** | Other tahmini | Bilinmiyor | Çok düşük (1/5) | 5/5 | **P2** | Müzik destesi varsa açıklamada |
| 15 | **çizim oyunu** | Other tahmini | Bilinmiyor | Düşük (2/5) | 4/5 | **P2** | Çizim destesi varsa açıklamada |
| 16 | **türk dizileri oyunu** | Other tahmini | Bilinmiyor | Çok düşük (1/5) | 5/5 | **P2** | Dizi destesi açıklamasında |
| 17 | **heads up türkçe** | Other tahmini | Bilinmiyor | Düşük (2/5) | 5/5 | **P2** | Global kullanıcı; açıklamada |
| 18 | **charades türkçe** | Other tahmini | Bilinmiyor | Düşük (2/5) | 5/5 | **P2** | Global kullanıcı; açıklamada |
| 19 | **mimik oyunu** | Other tahmini | Bilinmiyor | Düşük (2/5) | 4/5 | **P2** | Mimik destesi varsa |
| — | **kelime oyunu** | — | — | Çok yüksek (5/5) | 3/5 | **Dikkatli** | Destekleyici; başlığa alma |
| — | **tabu oyunu** | — | — | Çok yüksek (5/5) | 1/5 | **KAÇIN** | Farklı niyet; yanlış kitle |
| — | **bilgi yarışması** | — | — | Yüksek (4/5) | 1/5 | **KAÇIN** | Tamamen farklı mekanik |
| — | **online multiplayer** | — | — | Yüksek (4/5) | 1/5 | **KAÇIN** | Offline uygulama; hayal kırıklığı |
| — | **tek kişilik oyun** | — | — | Orta (3/5) | 1/5 | **KAÇIN** | En az 2 kişilik mekanik |

✦ = Play Console'da "Other" içinde olduğu güçlü olasılık; Explore raporu ile doğrulanmalı.

---

## 5) Yerleşim Planı — Her Kelime Nereye Gider

### Başlık (30 karakter)

**Mevcut (güçlü, koru):**
```
Tahmin Et! - Ben Kimim?
```
23/30 karakter — "tahmin et" markası + "ben kimim" format araması, ikisi birden başlıkta.

**A/B varyantı (long-tail için):**
```
Tahmin Et: Ben Kimim Oyunu
```
26/30 — "oyunu" eklenmesi "ben kimim oyunu" aramasını doğrudan karşılar.

### Kısa açıklama (80 karakter)

**Önerilen:**
```
Ben kimim & tahmin et: telefonu alnına koy, 50+ deste. Parti oyunu!
```
67/80 — P0 ve P1 terimler doğal biçimde içinde.

### Uzun açıklama — Keyword yerleşim haritası

İlk 400 karakter en kritik alan; Google bu kısmı en fazla indeksler.

```
🎮 BEN KİMİM VE TAHMİN ETME OYUNLARI — ALNINA KOY, EĞLEN!

Tahmin Et; arkadaşlarla oynanan ben kimim tarzı kelime tahmin ve 
parti oyunudur. Telefonu alnına koy; tahmin etme oyunları, 
canlandırma ve sessiz sinema sevenler için ideal. En az iki kişi; 
aile ve grup oyunlarında kahkaha garantisi.
```

Bu 4 cümlede geçen P0/P1 terimler: ben kimim, tahmin etme oyunları, alnına koy, parti oyunu, canlandırma, sessiz sinema, aile, grup oyunu — hepsi doğal cümle içinde.

Devamında (deste ve özellikler):
- "50+ DESTE" başlığı altında deste isimlerinde "türk dizileri", "mırıldanma", "çizim", "mimik" geçmeli.
- "KİMLER İÇİN?" bölümünde: "kelime oyunu sevenler", "heads up tarzı oyun arayanlar", "charades alternatifleri" geçebilir.

---

## 6) "Other" Long-Tail Stratejisi — %64,5'i Boşa Harcama

Bu kısım önceki versiyonda hiç yoktu. Ama asıl büyüme buradan.

### Neden önemli?

"Other" kümesindeki 1.014 indirme 4 adlandırılmış terimin toplamından (527) %92 daha fazla. Ve +%144,93 büyümekte. Bu kümeyi besleyen metin zenginliği, açıklamanın ortası ve alt kısmı + screenshot başlıklarıdır.

### Long-tail'i beslemek için 3 taktik

**1. Deste isimlerini açıklamada listele**
Her deste ismi potansiyel bir arama terimi. "Türk Dizileri" destesi → "türk dizileri oyunu" aramasını yakalar. "Müzik" destesi → "mırıldanma oyunu", "şarkı tahmin" aramalarını yakalar.

**2. Screenshot başlıklarına anahtar kelime göm**
Google Play, screenshot üstündeki metin başlıklarını indeksleyebilir. Her ekran görüntüsüne 2-4 kelimelik Türkçe başlık:
- Screenshot 1: "Alnına Koy — Tahmin Et"
- Screenshot 2: "50+ Türkçe Deste"
- Screenshot 3: "Arkadaşlarla Parti Oyunu"
- Screenshot 4: "Ben Kimim Tarzı — Canlandır, Çiz, Mırıldan"

**3. "What's New" alanını boşa harcama**
"Performans iyileştirmeleri" yazmak yerine yeni deste isimlerini, sezonsal içeriği buraya yaz. Bu alan da indekse girer.

---

## 7) Sezonsal Fırsatlar

Önceki versiyonda yoktu. Türkiye'ye özgü sezonsal arama zirveleri:

| Dönem | Zirve yapan aramalar | Önerilen aksiyon |
|-------|---------------------|-----------------|
| Ramazan / Bayram | "bayram oyunu", "aile oyunu", "grup oyunu" | Promotional text'i güncelle; yeni deste çıkar |
| Yılbaşı (Aralık) | "parti oyunu", "eğlenceli oyun", "arkadaşlarla" | Feature graphic'i yılbaşı temalı yap |
| Yaz (Haziran–Ağustos) | "kamp oyunu", "piknik oyunu", "tatil oyunu" | "Kamp & Piknik" destesi açıklamasına ekle |
| Okul başlangıcı | "öğrenci oyunu", "sınıf oyunu" | Long açıklamaya ekle |

---

## 8) Doğrulama — Sonraki Adımlar (Öncelik Sırasına Göre)

### Hemen yapılabilir (0 maliyet)

1. **Play Console → Search terms → Explore** butonuna tıkla. Tüm terimleri CSV olarak indir. "Other" içindeki top 30 terimi bu tabloya ekle — mevcut tahmini gerçek veriyle değiştir.

2. **Açıklama ilk 400 karakteri** Bölüm 5'teki haritaya göre güncelle. Tek başına en hızlı etki.

3. **Screenshot başlıklarına** Bölüm 6'daki metin önerilerini uygula.

### Kısa vadeli (1–4 hafta)

4. **Store listing experiment** başlat: "Tahmin Et! - Ben Kimim?" vs "Tahmin Et: Ben Kimim Oyunu" — 4 hafta sonra hangisi daha fazla indirme getiriyor bak.

5. **"What's New" alanını** deste ismi veya sezonsal mesajla güncelle (şu an "performans iyileştirmeleri" boşa gidiyor).

### Orta vadeli (aylık)

6. **AppTweak veya Mobile Action** ile aylık gerçek hacim doğrulaması. Bu tablodaki "Other tahmini" olanları gerçek veriyle değiştir.

7. **Rakip değişim takibi**: "Ben Kimim? Alındaki Kelime" ve "Tahmin et - Ben kimim?" uygulamalarının başlık/açıklama değişikliklerini aylık izle.

---

## 9) Özet: En Yüksek Etkili 5 Aksiyon

| Öncelik | Aksiyon | Beklenen etki | Zorluk |
|:-------:|---------|--------------|:------:|
| 1 | Play Console Explore → CSV indir → "Other" top 30'u tanımla | "Other" kümesini kör olmaktan çıkar | Kolay |
| 2 | Açıklama ilk 400 karakteri haritaya göre yaz | P0 terimlerin sıralaması güçlenir | Kolay |
| 3 | Screenshot başlıklarına keyword göm | Long-tail "Other" büyümesini destekler | Kolay |
| 4 | Başlık A/B testi başlat | "Ben kimim oyunu" long-tail etkisini ölç | Orta |
| 5 | "What's New" → deste/sezon mesajı | Güncel görünen uygulama sinyal verir | Kolay |

---

## 10) Referans Dosyalar

| Dosya | İçerik |
|-------|--------|
| `aso/app-store-listing.md` | iOS metadata taslakları |
| `aso/google-play-listing.md` | Play metadata taslakları |
| `aso/anahtar-kelimeler-siralamasi.md` | Önceki versiyon (bu dokümanla değişti) |

---

*Doküman güncelleme notu: Play Console Search terms CSV alındığında Bölüm 4'teki "Other tahmini" satırlarını gerçek verilerle değiştir. Revizyon tarihini de güncelle.*
