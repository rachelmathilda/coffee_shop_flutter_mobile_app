class Promo {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String imageUrl;
  final String ctaLabel;

  const Promo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.ctaLabel = 'order now',
  });

  factory Promo.fromMap(Map<String, dynamic> map, String id) {
    return Promo(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      ctaLabel: map['ctaLabel'] ?? 'order now',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'imageUrl': imageUrl,
      'ctaLabel': ctaLabel,
    };
  }
}
