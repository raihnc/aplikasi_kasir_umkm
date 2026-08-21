import 'package:get/get.dart';

import '../../product/controllers/product_controller.dart';
import '../../product/models/product.dart';
import '../models/pos_models.dart';

class PosController extends GetxController {
  static const int _maxDiscountPercent = 10;
  static const String _deviceCode = 'D01';

  final searchQuery = ''.obs;
  final cart = <CartItem>[].obs;
  final discountAmount = 0.obs;
  final paymentMethod = PaymentMethod.cash.obs;
  final cashReceived = 0.obs;
  final qrisReceived = 0.obs;
  final receiptSequence = 38.obs;
  final isProcessing = false.obs;

  ProductController get _productController => Get.find<ProductController>();

  List<Product> get products =>
      _productController.products.where((product) => product.isActive).toList();

  List<Product> get filteredProducts {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return products;

    return products
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              product.barcode.contains(query),
        )
        .toList();
  }

  int get subtotal => cart.fold(0, (sum, item) => sum + item.lineTotal);

  int get maxDiscountAmount => subtotal * _maxDiscountPercent ~/ 100;

  int get total {
    final value = subtotal - discountAmount.value;
    return value < 0 ? 0 : value;
  }

  int get cashDue {
    final method = paymentMethod.value;
    if (method == PaymentMethod.cash) return total;
    if (method == PaymentMethod.mixed) {
      return total - qrisReceived.value;
    }
    return 0;
  }

  int get change {
    final method = paymentMethod.value;
    if (method == PaymentMethod.qrisStatic) return 0;
    final value = cashReceived.value - cashDue;
    return value < 0 ? 0 : value;
  }

  bool get canCheckout {
    if (cart.isEmpty || isProcessing.value) return false;

    return switch (paymentMethod.value) {
      PaymentMethod.cash => cashReceived.value >= total,
      PaymentMethod.qrisStatic => qrisReceived.value >= total,
      PaymentMethod.mixed =>
        qrisReceived.value >= 0 &&
            cashDue >= 0 &&
            cashReceived.value == cashDue &&
            cashReceived.value + qrisReceived.value == total,
    };
  }

  void addToCart(Product product) {
    if (!product.trackStock || product.stock <= 0) {
      if (product.trackStock) {
        Get.snackbar('Stok habis', product.name);
      } else {
        _upsertCartItem(product);
      }
      return;
    }

    final currentQuantity = _quantityInCart(product);
    if (currentQuantity >= product.stock) {
      Get.snackbar('Stok tidak cukup', 'Sisa ${product.stock} ${product.unit}');
      return;
    }

    _upsertCartItem(product);
  }

  void incrementQuantity(CartItem item) {
    final currentQuantity = _quantityInCart(item.product);
    if (item.product.trackStock && currentQuantity >= item.product.stock) {
      Get.snackbar('Stok tidak cukup', item.product.name);
      return;
    }
    _replaceItem(item, item.quantity + 1);
  }

  void decrementQuantity(CartItem item) {
    if (item.quantity <= 1) {
      removeItem(item);
      return;
    }
    _replaceItem(item, item.quantity - 1);
  }

  void removeItem(CartItem item) {
    cart.remove(item);
    _recalculateDiscount();
  }

  void setDiscountFromInput(String value) {
    final parsed = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    discountAmount.value = parsed.clamp(0, maxDiscountAmount);
  }

  void setPaymentMethod(PaymentMethod method) {
    paymentMethod.value = method;
    if (method == PaymentMethod.mixed && qrisReceived.value > total) {
      qrisReceived.value = total;
    }
    if (method == PaymentMethod.qrisStatic) {
      cashReceived.value = 0;
    }
  }

  void setCashFromInput(String value) {
    cashReceived.value = _parseAmount(value);
  }

  void setQrisFromInput(String value) {
    final parsed = _parseAmount(value).clamp(0, total);
    qrisReceived.value = parsed;
  }

  void useExactCash() {
    cashReceived.value = cashDue;
  }

  void clearCart() {
    cart.clear();
    resetPayment();
  }

  Future<CheckoutResult?> checkout() async {
    if (!canCheckout) return null;

    isProcessing.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 350));

    for (final item in cart) {
      if (!item.product.trackStock) continue;
      final updated = item.product.copyWith(
        stock: item.product.stock - item.quantity,
      );
      final index = _productController.products.indexWhere(
        (product) => product.id == item.product.id,
      );
      if (index >= 0) {
        _productController.products[index] = updated;
      }
    }

    receiptSequence.value++;
    final result = CheckoutResult(
      receiptNumber: _receiptNumber(),
      total: total,
      change: change,
      paymentMethod: paymentMethod.value,
    );

    clearCart();
    isProcessing.value = false;
    return result;
  }

  void scanBarcode() {
    Get.snackbar(
      'Scan barcode',
      'Integrasi kamera akan diaktifkan pada tahap berikutnya.',
    );
  }

  void _upsertCartItem(Product product) {
    final index = cart.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(CartItem(product: product, quantity: 1));
    }
    _recalculateDiscount();
  }

  void _replaceItem(CartItem item, int quantity) {
    final index = cart.indexWhere(
      (candidate) => candidate.product.id == item.product.id,
    );
    if (index >= 0) {
      cart[index] = item.copyWith(quantity: quantity);
    }
    _recalculateDiscount();
  }

  int _quantityInCart(Product product) {
    final match = cart
        .where((item) => item.product.id == product.id)
        .firstOrNull;
    return match?.quantity ?? 0;
  }

  void _recalculateDiscount() {
    if (discountAmount.value > maxDiscountAmount) {
      discountAmount.value = maxDiscountAmount;
    }
  }

  void resetPayment() {
    discountAmount.value = 0;
    cashReceived.value = 0;
    qrisReceived.value = 0;
    paymentMethod.value = PaymentMethod.cash;
  }

  int _parseAmount(String value) {
    return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  String _receiptNumber() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return 'UMKM-$_deviceCode-$date-${receiptSequence.value.toString().padLeft(4, '0')}';
  }
}
