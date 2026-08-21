import 'package:aplikasi_kasir_umkm/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observables
  final products = <Product>[].obs;
  final cartItems = <CartItem>[].obs;
  final subtotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyProducts(); // Dummy data untuk UI
  }

  void _loadDummyProducts() {
    products.addAll([
      Product(id: '1', name: 'Beras Premium 5kg', price: 65000, stock: 20),
      Product(id: '2', name: 'Minyak Goreng 2L', price: 32000, stock: 15),
      Product(id: '3', name: 'Gula Pasir 1kg', price: 14000, stock: 50),
      Product(id: '4', name: 'Telur Ayam 1kg', price: 28000, stock: 10),
    ]);
  }

  void addToCart(Product product) {
    var existingItem = cartItems.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
    if (existingItem != null) {
      existingItem.qty.value++;
    } else {
      cartItems.add(CartItem(product: product, qty: 1.obs));
    }
    calculateTotal();
  }

  void calculateTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item.product.price * item.qty.value;
    }
    subtotal.value = total;
  }

  void scanBarcode() {
    // Implementasi Mobile Scanner akan masuk ke sini
    Get.snackbar(
      'Scan Barcode',
      'Membuka kamera tablet...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primary,
      colorText: Colors.white,
    );
  }

  void checkout() {
    if (cartItems.isEmpty) return;
    // Logika simpan ke Firestore & cetak struk digital masuk ke sini
    Get.snackbar(
      'Sukses',
      'Transaksi berhasil, menyimpan struk...',
      backgroundColor: AppTheme.primary,
      colorText: Colors.white,
    );
    cartItems.clear();
    calculateTotal();
  }
}

// Model Sederhana
class Product {
  final String id, name;
  final double price;
  final int stock;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });
}

class CartItem {
  final Product product;
  RxInt qty;
  CartItem({required this.product, required this.qty});
}
