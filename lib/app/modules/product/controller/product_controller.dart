import 'package:get/get.dart';

class ProductsController extends GetxController {
  final products = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
  }

  void _loadProducts() {
    // Simulasi data dari Firestore
    products.assignAll([
      {
        'id': '1',
        'name': 'Beras Premium 5kg',
        'category': 'Sembako',
        'price': 65000,
        'cost': 60000,
        'stock': 20,
      },
      {
        'id': '2',
        'name': 'Minyak Goreng 2L',
        'category': 'Sembako',
        'price': 32000,
        'cost': 30000,
        'stock': 5,
      }, // Stok menipis
    ]);
  }

  void addProduct() {
    // Logika form tambah produk masuk di sini
    Get.snackbar('Tambah Produk', 'Menampilkan dialog form tambah produk...');
  }
}
