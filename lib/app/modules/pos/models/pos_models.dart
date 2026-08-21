import '../../product/models/product.dart';

enum PaymentMethod { cash, qrisStatic, mixed }

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}

class CheckoutResult {
  const CheckoutResult({
    required this.receiptNumber,
    required this.total,
    required this.change,
    required this.paymentMethod,
  });

  final String receiptNumber;
  final int total;
  final int change;
  final PaymentMethod paymentMethod;

  String get paymentLabel => switch (paymentMethod) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.qrisStatic => 'QRIS Statis',
    PaymentMethod.mixed => 'Cash + QRIS',
  };
}
