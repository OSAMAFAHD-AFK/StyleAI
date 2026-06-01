/// Curated placeholder images for UI preview (fashion-focused).
abstract final class MockCatalog {
  static const dress =
      'https://images.unsplash.com/photo-1595777457583-95e059ce5829?w=600&q=80';
  static const blazer =
      'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=600&q=80';
  static const handbag =
      'https://images.unsplash.com/photo-1584917865442-de89d76a861a?w=600&q=80';
  static const sneakers =
      'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=600&q=80';
  static const eveningGown =
      'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=600&q=80';
  static const silkDress =
      'https://images.unsplash.com/photo-1612336307423-30072adaa1bd?w=600&q=80';

  static const List<String> productImages = [
    dress,
    blazer,
    handbag,
    sneakers,
    eveningGown,
    silkDress,
  ];

  /// Builds a swipeable gallery starting with [primary] (wraps catalog for extras).
  static List<String> galleryFor(String primary, {int count = 3}) {
    if (count <= 1) return [primary];

    final start = productImages.indexOf(primary);
    if (start < 0) {
      return [primary, ...productImages.take(count - 1)];
    }

    return List.generate(
      count,
      (index) => productImages[(start + index) % productImages.length],
    );
  }
}
