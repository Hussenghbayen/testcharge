class Product {
  final String id;
  final String name;
  final double costPrice;
  final double sellPrice;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellPrice,
    this.imageUrl,
  });
}