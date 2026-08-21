import '../../modules/pos/models/pos_models.dart';
import '../local/app_database.dart';
import 'base_repository.dart';

class SaleItemInput {
  const SaleItemInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost,
    this.lineDiscount = 0,
    this.trackStock = true,
  });

  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int unitCost;
  final int lineDiscount;
  final bool trackStock;

  int get lineTotal => unitPrice * quantity - lineDiscount;
}

class SaleRepository extends BaseRepository {
  const SaleRepository(super.database);

  static const String deviceCode = 'D01';

  CheckoutResult checkout({
    required List<SaleItemInput> items,
    required int transactionDiscount,
    required PaymentMethod paymentMethod,
    required int cashReceived,
    required int qrisReceived,
    String? cashierId,
    String deviceCode = deviceCode,
  }) {
    if (items.isEmpty) throw StateError('Keranjang kosong.');

    final subtotal = items.fold(0, (sum, item) => sum + item.lineTotal);
    final discount = transactionDiscount.clamp(0, subtotal);
    final total = subtotal - discount;
    final cashDue = switch (paymentMethod) {
      PaymentMethod.cash => total,
      PaymentMethod.mixed => total - qrisReceived,
      PaymentMethod.qrisStatic => 0,
    };
    final paidAmount = cashReceived + qrisReceived;
    final changeAmount = switch (paymentMethod) {
      PaymentMethod.qrisStatic => 0,
      _ => cashReceived - cashDue,
    };

    if (total < 0) throw StateError('Total transaksi tidak valid.');
    if (paymentMethod == PaymentMethod.cash && cashReceived < total) {
      throw StateError('Uang cash tidak cukup.');
    }
    if (paymentMethod == PaymentMethod.qrisStatic && qrisReceived < total) {
      throw StateError('Nominal QRIS belum sesuai.');
    }
    if (paymentMethod == PaymentMethod.mixed &&
        (qrisReceived < 0 ||
            cashDue < 0 ||
            cashReceived != cashDue ||
            paidAmount != total)) {
      throw StateError('Pembayaran campuran harus sama dengan total tagihan.');
    }

    final saleId = database.newId();
    final business = businessId;
    final actor = cashierId ?? currentUserId;
    final now = DateTime.now();
    final nowText = AppDatabase.timestamp(now);
    final receiptNumber = _generateReceiptNumber(
      businessCode: _businessCode(),
      deviceCode: deviceCode,
      at: now,
    );

    var grossProfit = 0;
    database.transaction(() {
      for (final item in items) {
        if (item.trackStock) {
          final stock = _stockForProduct(item.productId);
          if (stock < item.quantity) {
            throw StateError('Stok ${item.productName} tidak cukup.');
          }
        }
      }

      database.database.execute(
        '''INSERT INTO sales
           (id, business_id, receipt_number, status, subtotal, discount, total,
            paid_amount, change_amount, profit, cashier_id, created_at, updated_at)
           VALUES (?, ?, ?, 'completed', ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          saleId,
          business,
          receiptNumber,
          subtotal,
          discount,
          total,
          paidAmount,
          changeAmount,
          0,
          actor,
          nowText,
          nowText,
        ],
      );

      for (final item in items) {
        final lineId = database.newId();
        grossProfit +=
            (item.unitPrice - item.lineDiscount - item.unitCost) *
            item.quantity;

        database.database.execute(
          '''INSERT INTO sale_lines
             (id, sale_id, product_id, product_name_snapshot, qty, unit_price,
              line_discount, unit_cogs_snapshot, line_total)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
          [
            lineId,
            saleId,
            item.productId,
            item.productName,
            item.quantity,
            item.unitPrice,
            item.lineDiscount,
            item.unitCost,
            item.lineTotal,
          ],
        );
        database.enqueueSync(
          businessId: business,
          entityType: 'sale_lines',
          entityId: lineId,
          payload: {
            'id': lineId,
            'sale_id': saleId,
            'product_id': item.productId,
            'product_name_snapshot': item.productName,
            'qty': item.quantity,
            'unit_price': item.unitPrice,
            'line_discount': item.lineDiscount,
            'unit_cogs_snapshot': item.unitCost,
            'line_total': item.lineTotal,
          },
        );

        if (item.trackStock) {
          _insertMovement(
            productId: item.productId,
            movementType: 'sale',
            quantityDelta: -item.quantity,
            unitCost: item.unitCost,
            referenceType: 'sale',
            referenceId: saleId,
            note: receiptNumber,
            occurredAt: nowText,
            actorId: actor,
          );
        }
      }

      grossProfit -= discount;
      database.database.execute('UPDATE sales SET profit = ? WHERE id = ?', [
        grossProfit,
        saleId,
      ]);

      void insertPayment(PaymentMethod method, int amount) {
        if (amount <= 0) return;
        final paymentId = database.newId();
        database.database.execute(
          '''INSERT INTO payments
             (id, sale_id, method, amount, reference_note, confirmed_by_cashier, created_at)
             VALUES (?, ?, ?, ?, '', 1, ?)''',
          [paymentId, saleId, _paymentName(method), amount, nowText],
        );
        database.enqueueSync(
          businessId: business,
          entityType: 'payments',
          entityId: paymentId,
          payload: {
            'id': paymentId,
            'sale_id': saleId,
            'method': _paymentName(method),
            'amount': amount,
            'reference_note': '',
            'confirmed_by_cashier': true,
            'created_at': nowText,
          },
        );
      }

      insertPayment(PaymentMethod.cash, cashReceived);
      insertPayment(PaymentMethod.qrisStatic, qrisReceived);

      final payload = _rawSale(saleId);
      database.enqueueSync(
        businessId: business,
        entityType: 'sales',
        entityId: saleId,
        payload: payload,
      );
      audit(
        action: 'checkout',
        entityType: 'sale',
        entityId: saleId,
        after: payload,
        occurredAt: now,
      );
    });

    return CheckoutResult(
      receiptNumber: receiptNumber,
      total: total,
      change: changeAmount,
      paymentMethod: paymentMethod,
    );
  }

  void refundFull({required String saleId, required String reason}) {
    final business = businessId;
    final actor = currentUserId;
    final occurredAt = AppDatabase.timestamp();

    database.transaction(() {
      final sales = database.database.select(
        '''SELECT * FROM sales
           WHERE id = ? AND business_id = ? AND status = 'completed' LIMIT 1''',
        [saleId, business],
      );
      if (sales.isEmpty) {
        throw StateError('Transaksi tidak ditemukan atau sudah direfund.');
      }

      final lines = database.database.select(
        'SELECT * FROM sale_lines WHERE sale_id = ?',
        [saleId],
      );
      for (final line in lines) {
        if ((line['qty'] as int) == 0) continue;
        _insertMovement(
          productId: line['product_id'] as String,
          movementType: 'refund',
          quantityDelta: line['qty'] as int,
          unitCost: line['unit_cogs_snapshot'] as int,
          referenceType: 'refund',
          referenceId: saleId,
          note: reason,
          occurredAt: occurredAt,
          actorId: actor,
        );
      }

      database.database.execute(
        '''UPDATE sales SET status = 'refunded', refund_reason = ?, updated_at = ?
           WHERE id = ?''',
        [reason, occurredAt, saleId],
      );
      final payload = _rawSale(saleId);
      database.enqueueSync(
        businessId: business,
        entityType: 'sales',
        entityId: saleId,
        payload: payload,
      );
      audit(
        action: 'refund_full',
        entityType: 'sale',
        entityId: saleId,
        before: {'status': 'completed'},
        after: payload,
      );
    });
  }

  List<Map<String, Object?>> recentSales({int limit = 10}) {
    return database.database
        .select(
          '''
      SELECT s.*, GROUP_CONCAT(p.method, ',') AS methods
      FROM sales s
      LEFT JOIN payments p ON p.sale_id = s.id
      WHERE s.business_id = ?
      GROUP BY s.id
      ORDER BY s.created_at DESC
      LIMIT ?
    ''',
          [businessId, limit],
        )
        .toList();
  }

  String _generateReceiptNumber({
    required String businessCode,
    required String deviceCode,
    required DateTime at,
  }) {
    final localDate =
        '${at.year}${at.month.toString().padLeft(2, '0')}${at.day.toString().padLeft(2, '0')}';
    final startLocal = DateTime(at.year, at.month, at.day);
    final endLocal = startLocal.add(const Duration(days: 1));
    final count =
        database.database
                .select(
                  '''
      SELECT COUNT(*) AS total FROM sales
      WHERE created_at >= ? AND created_at < ?
    ''',
                  [
                    AppDatabase.timestamp(startLocal),
                    AppDatabase.timestamp(endLocal),
                  ],
                )
                .first['total']
            as int;

    return '$businessCode-$deviceCode-$localDate-${(count + 1).toString().padLeft(4, '0')}';
  }

  String _businessCode() {
    return database.database
            .select('SELECT code FROM businesses LIMIT 1')
            .first['code']
        as String;
  }

  int _stockForProduct(String productId) {
    return database.database.select(
          'SELECT COALESCE(SUM(quantity_delta), 0) AS stock FROM stock_movements WHERE product_id = ?',
          [productId],
        ).first['stock']
        as int;
  }

  void _insertMovement({
    required String productId,
    required String movementType,
    required int quantityDelta,
    required int unitCost,
    required String referenceType,
    required String referenceId,
    required String note,
    required String occurredAt,
    required String actorId,
  }) {
    final id = database.newId();
    final business = businessId;
    final now = AppDatabase.timestamp();
    database.database.execute(
      '''INSERT INTO stock_movements
         (id, business_id, product_id, movement_type, quantity_delta, unit_cost,
          reference_type, reference_id, occurred_at, user_id, note, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        id,
        business,
        productId,
        movementType,
        quantityDelta,
        unitCost,
        referenceType,
        referenceId,
        occurredAt,
        actorId,
        note,
        now,
        now,
      ],
    );
    database.enqueueSync(
      businessId: business,
      entityType: 'stock_movements',
      entityId: id,
      payload: {
        'id': id,
        'business_id': business,
        'product_id': productId,
        'movement_type': movementType,
        'quantity_delta': quantityDelta,
        'unit_cost': unitCost,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'occurred_at': occurredAt,
        'user_id': actorId,
        'note': note,
        'updated_at': now,
      },
    );
  }

  Map<String, Object?> _rawSale(String id) {
    return Map<String, Object?>.from(
      database.database.select('SELECT * FROM sales WHERE id = ?', [id]).first,
    );
  }

  String _paymentName(PaymentMethod method) => switch (method) {
    PaymentMethod.cash => 'cash',
    PaymentMethod.qrisStatic => 'qris_static',
    PaymentMethod.mixed => throw ArgumentError(
      'Mixed disimpan sebagai dua payment.',
    ),
  };
}
