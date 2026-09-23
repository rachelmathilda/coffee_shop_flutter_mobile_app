class Coffee {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  final List<String> sizes;
  final List<String> coffeeTypes;
  final List<String> addIns;

  const Coffee({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    this.sizes = const ['S', 'M', 'L'],
    this.coffeeTypes = const ['Arabica', 'Liberica', 'Robusta'],
    this.addIns = const ['Milk', 'Sugar', 'Cream', 'Cocoa', 'Vanilla', 'Salt'],
  });

  factory Coffee.fromMap(Map<String, dynamic> map, String id) {
    return Coffee(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }
}
