class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.barcode,
    required this.category,
    required this.unit,
    required this.price,
    required this.stock,
    required this.minimumStock,
    required this.supplier,
    this.trackStock = true,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String category;
  final String unit;
  final int price;
  final int stock;
  final int minimumStock;
  final String supplier;
  final bool trackStock;
  final bool isActive;

  bool get isLowStock => trackStock && stock <= minimumStock;

  Product copyWith({int? stock, bool? isActive}) {
    return Product(
      id: id,
      name: name,
      sku: sku,
      barcode: barcode,
      category: category,
      unit: unit,
      price: price,
      stock: stock ?? this.stock,
      minimumStock: minimumStock,
      supplier: supplier,
      trackStock: trackStock,
      isActive: isActive ?? this.isActive,
    );
  }
}
