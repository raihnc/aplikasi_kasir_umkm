import 'package:get/get.dart';

import '../models/product.dart';

class ProductController extends GetxController {
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final products = <Product>[].obs;

  List<String> get categories => [
    'Semua',
    ...{for (final product in products) product.category},
  ];

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    return products.where((product) {
      final matchesCategory =
          selectedCategory.value == 'Semua' ||
          product.category == selectedCategory.value;
      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.barcode.contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadSampleProducts();
  }

  Future<void> refreshProducts() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    isLoading.value = false;
  }

  void addProduct(Product product) {
    products.insert(0, product);
    Get.back<void>();
    Get.snackbar('Produk ditambahkan', product.name);
  }

  void toggleActive(Product product) {
    final index = products.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      products[index] = product.copyWith(isActive: !product.isActive);
    }
  }

  void scanBarcode() {
    Get.snackbar(
      'Scan barcode',
      'Kamera scanner akan diaktifkan pada integrasi perangkat.',
    );
  }

  void _loadSampleProducts() {
    isLoading.value = false;
    products.assignAll(const [
      Product(
        id: 'p-01',
        name: 'Beras Premium 5 kg',
        sku: 'BRS-005',
        barcode: '8991002100011',
        category: 'Bahan Pokok',
        unit: 'Sak',
        price: 72000,
        stock: 4,
        minimumStock: 12,
        supplier: 'CV Sumber Pangan',
      ),
      Product(
        id: 'p-02',
        name: 'Minyak Goreng 2 L',
        sku: 'MYG-002',
        barcode: '8991002100028',
        category: 'Bahan Pokok',
        unit: 'Pouch',
        price: 34000,
        stock: 7,
        minimumStock: 15,
        supplier: 'PT Minyak Sejahtera',
      ),
      Product(
        id: 'p-03',
        name: 'Gula Pasir 1 kg',
        sku: 'GUL-001',
        barcode: '8991002100035',
        category: 'Bahan Pokok',
        unit: 'Pack',
        price: 17000,
        stock: 9,
        minimumStock: 20,
        supplier: 'CV Sumber Pangan',
      ),
      Product(
        id: 'p-04',
        name: 'Kopi Instan 20 g',
        sku: 'KPI-020',
        barcode: '8991002100042',
        category: 'Minuman',
        unit: 'Sachet',
        price: 2500,
        stock: 84,
        minimumStock: 24,
        supplier: 'PT Distribusi Nusantara',
      ),
      Product(
        id: 'p-05',
        name: 'Air Mineral 600 ml',
        sku: 'AIR-600',
        barcode: '8991002100059',
        category: 'Minuman',
        unit: 'Botol',
        price: 4000,
        stock: 120,
        minimumStock: 48,
        supplier: 'PT Distribusi Nusantara',
      ),
      Product(
        id: 'p-06',
        name: 'Sabun Mandi Cair',
        sku: 'SBM-450',
        barcode: '8991002100066',
        category: 'Kebersihan',
        unit: 'Botol',
        price: 18500,
        stock: 32,
        minimumStock: 18,
        supplier: 'PT Rumah Bersih',
      ),
    ]);
  }
}
