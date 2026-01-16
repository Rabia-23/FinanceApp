# Finance-Tracker-App-Web

## Registration Page
   * Kullanici giris ve kayit islemleri yapildi.

## Home Page
   - Accounts
      * Bakiye ve hesap adı bilgileri girilerek yeni hesap eklenebilir ve oluşturulmuş hesap kartının üstüne basılı tutularak hesap silinebilir.
      * Ana sayfada hesap kartları halinde hesap adı ve o hesaba ait bakiye gösterilir.

   - Net Worth + Graph
      * Kullanıcının toplam bakiyesi gösterilir.
      * Gelir ve giderler tek çizgi grafik ile gösterilir.
      * Kategori bazlı pasta grafiği gösterilir.

   - Transactions + Budgets
      * Kullanıcının son 30 işlemi görüntülenir.
      * İşlemler tarihlerine göre gruplandırılır.
      * İşlemlerin gider veya gelir olduğu, ne kadar olduğu ve ne zaman işleme geçildiği gösterilir.
      * Hızlı işlem oluşturmak için “+ İşlem Ekle” butonu ana sayfada da yer alır (butonun içeriği Transactions kısmında açıklanacak).
      * Yeni bütçe oluşturma kartı ile bütçenin periyot tipi (haftalık, aylık, yıllık), bütçenin başlangıç tarihi (bitiş tarihi belirlenen periyot türüne göre otomatik oluşturulur) ve bütçe limit bilgileri girilerek kolay bir şekilde yeni bütçe oluşturulur.
      * Oluşturulan bütçe kartında bütçenin limitiyle birlikte harcanan miktar, progress çubuğu, bütçenin yüzde kaçının harcandığı bütçe bitimine ne kadar kaldığı ve periyot tipi bulunur.
      * Bütçe kartına basıldığında bütçe geçmişleri görünür.
      * Bütçe kartına basılı tutulduğunda bütçe güncelleme ve silme seçenekleri bulunur.
      * Bütçe silinmediği sürece bütçe seçilen periyodik süre türünde otomatik yenilenmeye devam eder.

# Transactions Page
   * İşlemler aylara, kategorilere ve gelir-gider olduğuna göre filtrelenebilir.
   * “CSV İndir” butonu ile filtrelenen işlemler csv dosyası olarak indirilir.
   * “+ Yeni İşlem” butonu ile işlem türü, tarih, saat, tutar, banka hesabı (kullanıcıya ait hesaplar dropdown ile seçilir), başlık kategori ve opsiyonel bir not bilgileri girilerek kolayca yeni bir işlem oluşturulur.
   * Her bir işlem güncellenebilir ve silinebilir. Silinen transaction hangi hesaptan harcandıysa otomatik olarak o hesaba transaction’da harcanan para geri eklenir.

# Subscriptions Page
   * Aboneliklere giden toplam aylık harcama, aktif abonelik sayısı ve yaklaşan ödeme sayısı gösterilir.
   * Tüm abonelikler kartlar şeklinde listelenir.
   * Bir abonelik kartına tıklandığında aboneliğin ödemesi yapılabilir, aboneliğin o aylik ödemesi atlanabilir, abonelik silinebilir.
   * “+ Yeni Abonelik” butonu ile abonelik adı, kategori, aylık tutar ve ödeme günü bilgileri girilerek kolayca yeni bir abonelik oluşturulur.

# Goals Page
   * Oluşturulan hedef kartlarında progress çubuğu, yüzdelik, hedeflenen tutar, hedef adı ve hedefi silmek için bir ikon bulunur.
   * Bir hedef kartına tıklanıldığında hedefte/birikimde olan mevcut para miktarı, hedeflenen tutar, hedefe ulaşmak için kalan miktar progress çubuğu ve yüzdelik ile birlikte verilir. Altında ise hedefe katkı eklemek için hesap (kullanıcının var olan hesaplarından), katkı miktarı ve opsiyonel bir not bilgileri girilir.
   * “+ Yeni Hedef” butonu ile hedef türü, hedef adı, hedef miktarı, başlangıç tarihi ve bitiş tarihi bilgileri girilerek kolayca yeni bir hedef/birikim oluşturulur.

# Currency Page
   * USD, EUR, GBP, CHF, JPY, KRW ekranda -TRY bazlı- gösterilir.