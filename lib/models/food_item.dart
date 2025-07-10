class FoodItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final String description; // ✅ NEW FIELD

  FoodItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.description, // ✅ NEW
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'description': description, // ✅ SAVE it to Firestore
    };
  }

  factory FoodItem.fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      name: map['name'],
      imageUrl: map['imageUrl'],
      price: (map['price'] as num).toDouble(),
      category: map['category'],
      description: map['description'] ?? '', // ✅ fallback empty if missing
    );
  }
}
