# Finance-Tracker-App-Web

## Registration Page
   * Kullanici giris ve kayit islemleri yapildi.

## Home Page
   - Accounts
      * Bakiye ve Hesap Adi bilgileri girilerek yeni hesap eklenebilir ve olusturulmus hesap kartinin ustune basilarak hesap silinebilir.
      * Ana sayfada Hesap kartlari halinde Hesba adi ve o hesaba ait bakiye gosterilir.
   - Net Worth + Graph
      * Kullanicinin toplam bakiyesi gosterilir.
      * Gelir ve giderleri tek cizgi grafik ile gosterilir.
      * Kategori bazli pasta grafigi gosterilir.
   - Transactions + Budgets
      * Kullanicinin son 30 islemi goruntulenir.
      * Islemler tarihlerine gore gruplandirilir.
      * Islemlerin gider veya gelir oldugu, ne kadar oldugu ve ne zaman isleme gecildigi gosterilir.
      * Hizli islem olusturmak icin “+ Islem Ekle” butonu ana sayfada da yer alir (butonun icerigi Transactions kisminda aciklanacak).
      * Yeni butce olusturma karti ile butcenin periyot tipi (haftalik, aylik, yillik), butcenin baslangic tarihi (bitis tarihi belirlenen periyot turune gore otomatik olusturulur) ve butce limiti bilgileri girilerek kolay bir sekilde yeni butce olusturulur.
      * Olusturulan butce kartinda butcenin limitiyle birlikte harcanan miktar, progress cubugu, butcenin yuzde kacinin harcandigi butce bitimine ne kadar kaldigi ve periyot tipi bulunur.
      * Butce kartina basildiginda butce gecmisleri gorunur.
      * Butce kartina basili tutuldugunda butce guncelleme ve silme secenekleri bulunur.
      * Butce silinmedigi surece butce secilen periyodik sure icerisinde otomatik yenilenmeye devam eder.
# Transactions Page
   * Islemler aylara, kategorilere ve gelir-gider olduguna gore filtrelenebilir.
   * “CSV Indir” butonu ile filtrelenilen aya ait islemler csv dosyasi olarak indirilir.
   * “+ Yeni Islem” butonu ile islem turu, tarih, saat, tutar, banka hesabi (kullaniciya ait hesaplar dropdown ile secilir), baslik, kategori ve opsiyonel bir not bilgileri girilerek kolayca yeni bir islem olusturulur.
   * Her bir islem guncellenebilir ve silinebilir. Silinen transaction hengi hesaptan harcandiysa otomatik olarak o hesaba transaction'da harcanan para geri eklenir.
# Subscriptions Page
   * Aboneliklere giden toplam aylik harcama, aktif abonelik sayisi ve yaklasan odeme sayisi gosterilir.
   * Tum abonelikler kartlar seklinde listelenir.
   * Bir abonelik kartina tiklanildiginda aboneligin odemesi yapilabilir, aboneligin o ayki odemesi atlanilabilir, abonelik silinebilir.
   * “+ Yeni Abonelik” butonu ile abonelik adi, kategori, aylik tutar ve odeme gunu bilgileri girilerek kolayca yeni bir abonelik olusturulur.
# Goals Page
   * Olusturulan abonelik kartlarinda progress cubugu, yuzdelik, hedeflenen tutar, hedef adi ve hedef’i silmek icin bir ikon bulunur.
   * Bir hedef kartina tiklanildiginda hedefte/birikimde olan mevcut para miktari, hedeflenen tutar, hedefe ulasmak icin kalan miktar progress cubugu ve yuzdelik ile birlikte verilir. Altinda ise hedefe katki eklemek icin parayi ayirmak icin hesap (kullanicinin var olan hesaplarindan), katki miktari ve opsiyonel bir not bilgileri girilir.
   * “+ Yeni Hedef” butonu ile hedef turu, hedef adi, hedef miktari, baslangic tarihi ve bitis tarihi bilgileri girilerek kolayca yeni bir hedef/birikim olusturulur.
# Currency Page
   * USD, EUR, GBP, CHF, JPY, KRW ekranda -TRY bazli- gosterilir.


# Iyilestirme Onerileri
   * Transaction icin opsiyonel olan notlari transaction ustune tiklanildiginda veya hover yapildiginda gostermek