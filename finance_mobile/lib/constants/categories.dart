/// Uygulama genelinde kullanılacak sabit kategori listesi
class Categories {
  // Gider Kategorileri
  static const List<String> expenseCategories = [
    'Yemek',
    'Ulaşım',
    'Alışveriş',
    'Eğlence',
    'Sağlık',
    'Eğitim',
    'Faturalar',
    'Kira',
    'Diğer',
  ];

  // Gelir Kategorileri
  static const List<String> incomeCategories = [
    'Maaş',
    'Yatırım',
    'Hediye',
    'Diğer',
  ];

  // Tüm kategoriler (dropdown'lar için)
  static List<String> getAllCategories() {
    return [...expenseCategories, ...incomeCategories];
  }

  // Türe göre kategorileri getir
  static List<String> getCategoriesByType(String type) {
    if (type == 'Income' || type == 'Gelir') {
      return incomeCategories;
    } else {
      return expenseCategories;
    }
  }

  // Kategori ikonu
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'Yemek':
        return '🍔';
      case 'Ulaşım':
        return '🚗';
      case 'Alışveriş':
        return '🛒';
      case 'Eğlence':
        return '🎬';
      case 'Sağlık':
        return '💊';
      case 'Eğitim':
        return '📚';
      case 'Faturalar':
        return '📄';
      case 'Kira':
        return '🏠';
      case 'Maaş':
        return '💰';
      case 'Yatırım':
        return '📈';
      case 'Hediye':
        return '🎁';
      default:
        return '💵';
    }
  }
}
