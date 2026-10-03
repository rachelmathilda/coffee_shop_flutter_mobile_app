class Promo {
  final String id;
  final String title;
  final double price;
  final String image;
  final String coffeeId;
  final int order;

  const Promo({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.coffeeId,
    this.order = 0,
  });

  factory Promo.fromMap(Map<String, dynamic> map, String id) {
    return Promo(
      id: id,
      title: (map['title'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      image: (map['image'] ?? '') as String,
      coffeeId: (map['coffeeId'] ?? '') as String,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }
}
