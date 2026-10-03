class Coffee {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String image;
  final int color;
  final bool featured;
  final int order;

  const Coffee({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
    this.color = 0xFF6E4A35,
    this.featured = false,
    this.order = 0,
  });

  factory Coffee.fromMap(Map<String, dynamic> map, String id) {
    return Coffee(
      id: id,
      name: (map['name'] ?? '') as String,
      price: ((map['price'] ?? 0) as num).toDouble(),
      rating: ((map['rating'] ?? 0) as num).toDouble(),
      image: (map['image'] ?? '') as String,
      color: ((map['color'] ?? 0xFF6E4A35) as num).toInt(),
      featured: (map['featured'] ?? false) as bool,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }
}
