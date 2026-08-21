import 'package:aplikasi_kasir_umkm/app/data/local/app_database.dart';
import 'package:aplikasi_kasir_umkm/app/data/repositories/product_repository.dart';
import 'package:aplikasi_kasir_umkm/app/data/repositories/report_repository.dart';
import 'package:aplikasi_kasir_umkm/app/data/repositories/sale_repository.dart';
import 'package:aplikasi_kasir_umkm/app/modules/pos/models/pos_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.inMemory();
  });

  tearDown(() {
    database.close();
  });

  test('migrasi dan seed katalog berjalan', () {
    final products = ProductRepository(database).listProducts();

    expect(products, isNotEmpty);
    expect(products.every((product) => product.stock >= 0), isTrue);
  });

  test('checkout menyimpan transaksi, payment, dan mengurangi stok', () {
    final productRepository = ProductRepository(database);
    final saleRepository = SaleRepository(database);
    final product = productRepository.listProducts().first;
    final stockBefore = product.stock;
    final cost = database.database
        .select('SELECT avg_cost FROM products WHERE id = ?', [product.id])
        .first['avg_cost'] as int;

    final result = saleRepository.checkout(
      items: [
        SaleItemInput(
          productId: product.id,
          productName: product.name,
          quantity: 2,
          unitPrice: product.price,
          unitCost: cost,
        ),
      ],
      transactionDiscount: 0,
      paymentMethod: PaymentMethod.cash,
      cashReceived: product.price * 2,
      qrisReceived: 0,
    );

    expect(result.total, product.price * 2);
    expect(productRepository.listProducts(query: product.sku).first.stock, stockBefore - 2);
    expect(database.database.select('SELECT COUNT(*) AS total FROM sales').first['total'], 1);
    expect(database.database.select('SELECT COUNT(*) AS total FROM payments').first['total'], 1);
    expect(database.database.select("SELECT COUNT(*) AS total FROM sync_queue WHERE status = 'pending'").first['total'], greaterThan(0));
  });

  test('laporan membaca transaksi yang sudah selesai', () {
    final productRepository = ProductRepository(database);
    final saleRepository = SaleRepository(database);
    final reportRepository = ReportRepository(database);
    final product = productRepository.listProducts().first;
    final cost = database.database
        .select('SELECT avg_cost FROM products WHERE id = ?', [product.id])
        .first['avg_cost'] as int;

    saleRepository.checkout(
      items: [
        SaleItemInput(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
          unitCost: cost,
        ),
      ],
      transactionDiscount: 0,
      paymentMethod: PaymentMethod.qrisStatic,
      cashReceived: 0,
      qrisReceived: product.price,
    );

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final summary = reportRepository.summary(start: start, end: end);

    expect(summary.revenue, product.price);
    expect(summary.transactions, 1);
    expect(reportRepository.dailyTrend(), contains(product.price));
  });
}
