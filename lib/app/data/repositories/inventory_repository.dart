import '../../modules/inventory/models/inventory_models.dart';
import '../local/app_database.dart';
import 'base_repository.dart';

class PurchaseOrderItemInput {
  const PurchaseOrderItemInput({
    required this.productId,
    required this.quantity,
    required this.unitCost,
  });

  final String productId;
  final int quantity;
  final int unitCost;
}

class InventoryRepository extends BaseRepository {
  const InventoryRepository(super.database);

  List<Supplier> listSuppliers() {
    return database.database
        .select(
          '''
      SELECT * FROM suppliers
      WHERE business_id = ? AND deleted_at IS NULL
      ORDER BY name
    ''',
          [businessId],
        )
        .map(
          (row) => Supplier(
            id: row['id'] as String,
            name: row['name'] as String,
            phone: row['phone'] as String,
            address: row['address'] as String,
          ),
        )
        .toList();
  }

  List<PurchaseOrder> listPurchaseOrders() {
    return database.database
        .select(
          '''
      SELECT po.*, s.name AS supplier_name,
             COALESCE(SUM(pol.ordered_qty), 0) AS item_count,
             COALESCE(SUM(pol.ordered_qty * pol.unit_cost), 0) AS calculated_total
      FROM purchase_orders po
      JOIN suppliers s ON s.id = po.supplier_id
      LEFT JOIN purchase_order_lines pol ON pol.purchase_order_id = po.id
      WHERE po.business_id = ?
      GROUP BY po.id
      ORDER BY po.created_at DESC
    ''',
          [businessId],
        )
        .map(_mapPurchaseOrder)
        .toList();
  }

  List<StockMovement> listStockMovements({int limit = 100}) {
    return database.database
        .select(
          '''
      SELECT sm.*, p.name AS product_name
      FROM stock_movements sm
      JOIN products p ON p.id = sm.product_id
      WHERE sm.business_id = ?
      ORDER BY sm.occurred_at DESC, sm.created_at DESC
      LIMIT ?
    ''',
          [businessId, limit],
        )
        .map(_mapMovement)
        .toList();
  }

  Future<PurchaseOrder> createPurchaseOrder({
    required String supplierId,
    required List<PurchaseOrderItemInput> items,
    DateTime? expectedAt,
  }) async {
    if (items.isEmpty) {
      throw ArgumentError('Purchase order harus memiliki item.');
    }

    final id = database.newId();
    final now = AppDatabase.timestamp();
    final business = businessId;
    final orderNumber =
        'PO-${now.substring(0, 10).replaceAll('-', '')}-${id.substring(0, 4).toUpperCase()}';
    var totalCost = 0;
    for (final item in items) {
      totalCost += item.quantity * item.unitCost;
    }

    database.transaction(() {
      database.database.execute(
        '''INSERT INTO purchase_orders
           (id, business_id, supplier_id, order_number, status, expected_at,
            total_cost, created_at, updated_at)
           VALUES (?, ?, ?, ?, 'ordered', ?, ?, ?, ?)''',
        [
          id,
          business,
          supplierId,
          orderNumber,
          expectedAt == null ? null : AppDatabase.timestamp(expectedAt),
          totalCost,
          now,
          now,
        ],
      );

      for (final item in items) {
        database.database.execute(
          '''INSERT INTO purchase_order_lines
             (id, purchase_order_id, product_id, ordered_qty, received_qty, unit_cost)
             VALUES (?, ?, ?, ?, 0, ?)''',
          [database.newId(), id, item.productId, item.quantity, item.unitCost],
        );
      }

      final payload = _rawPurchaseOrder(id);
      database.enqueueSync(
        businessId: business,
        entityType: 'purchase_orders',
        entityId: id,
        payload: payload,
      );
      audit(
        action: 'create',
        entityType: 'purchase_order',
        entityId: id,
        after: payload,
      );
    });

    return listPurchaseOrders().firstWhere((order) => order.id == id);
  }

  Future<void> receivePurchaseOrder(String purchaseOrderId) async {
    final business = businessId;
    final actor = currentUserId;
    final occurredAt = AppDatabase.timestamp();

    database.transaction(() {
      final orders = database.database.select(
        'SELECT * FROM purchase_orders WHERE id = ? AND business_id = ?',
        [purchaseOrderId, business],
      );
      if (orders.isEmpty) {
        throw StateError('Purchase order tidak ditemukan.');
      }
      if (orders.first['status'] as String == 'received') {
        return;
      }

      final lines = database.database.select(
        '''SELECT * FROM purchase_order_lines
           WHERE purchase_order_id = ? AND received_qty < ordered_qty''',
        [purchaseOrderId],
      );

      var hasPartial = false;
      for (final line in lines) {
        final productId = line['product_id'] as String;
        final quantity =
            (line['ordered_qty'] as int) - (line['received_qty'] as int);
        final unitCost = line['unit_cost'] as int;

        _insertMovement(
          productId: productId,
          movementType: 'purchase_receive',
          quantityDelta: quantity,
          unitCost: unitCost,
          referenceType: 'purchase_order',
          referenceId: purchaseOrderId,
          note: 'Penerimaan barang',
          occurredAt: occurredAt,
          actorId: actor,
        );
        _updateMovingAverageCost(productId, quantity, unitCost);
        database.database.execute(
          'UPDATE purchase_order_lines SET received_qty = ordered_qty WHERE id = ?',
          [line['id']],
        );
      }

      final remaining =
          database.database
                  .select(
                    '''SELECT COUNT(*) AS total FROM purchase_order_lines
           WHERE purchase_order_id = ? AND received_qty < ordered_qty''',
                    [purchaseOrderId],
                  )
                  .first['total']
              as int;
      hasPartial = remaining > 0;

      database.database.execute(
        '''UPDATE purchase_orders
           SET status = ?, received_at = ?, updated_at = ?
           WHERE id = ?''',
        [
          hasPartial ? 'partial' : 'received',
          occurredAt,
          occurredAt,
          purchaseOrderId,
        ],
      );

      final payload = _rawPurchaseOrder(purchaseOrderId);
      database.enqueueSync(
        businessId: business,
        entityType: 'purchase_orders',
        entityId: purchaseOrderId,
        payload: payload,
      );
      audit(
        action: 'receive',
        entityType: 'purchase_order',
        entityId: purchaseOrderId,
        after: payload,
        occurredAt: DateTime.now(),
      );
    });
  }

  Future<void> adjustStock({
    required String productId,
    required int quantityDelta,
    String note = '',
  }) async {
    if (quantityDelta == 0) return;

    final stock = _stockForProduct(productId);
    if (quantityDelta < 0 && stock + quantityDelta < 0) {
      throw StateError('Stok tidak cukup untuk penyesuaian.');
    }

    database.transaction(() {
      _insertMovement(
        productId: productId,
        movementType: quantityDelta > 0 ? 'adjustment_in' : 'adjustment_out',
        quantityDelta: quantityDelta,
        unitCost: _averageCost(productId),
        referenceType: 'adjustment',
        referenceId: productId,
        note: note,
        occurredAt: AppDatabase.timestamp(),
        actorId: currentUserId,
      );
      audit(
        action: 'adjust',
        entityType: 'stock',
        entityId: productId,
        after: {'quantity_delta': quantityDelta, 'note': note},
      );
    });
  }

  Future<String> createSupplier({
    required String name,
    String phone = '',
    String address = '',
    String notes = '',
  }) async {
    final id = database.newId();
    final now = AppDatabase.timestamp();
    final business = businessId;
    database.database.execute(
      '''INSERT INTO suppliers
         (id, business_id, name, phone, address, notes, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [id, business, name, phone, address, notes, now, now],
    );
    final payload = {
      'id': id,
      'business_id': business,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'updated_at': now,
    };
    database.enqueueSync(
      businessId: business,
      entityType: 'suppliers',
      entityId: id,
      payload: payload,
    );
    audit(
      action: 'create',
      entityType: 'supplier',
      entityId: id,
      after: payload,
    );
    return id;
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

  void _updateMovingAverageCost(
    String productId,
    int receivedQty,
    int unitCost,
  ) {
    final currentStock = _stockForProduct(productId) - receivedQty;
    final currentCost = _averageCost(productId);
    final totalQuantity = currentStock + receivedQty;
    if (totalQuantity <= 0) return;

    final newAverage =
        ((currentStock * currentCost) + (receivedQty * unitCost)) ~/
        totalQuantity;
    database.database.execute(
      'UPDATE products SET avg_cost = ?, updated_at = ? WHERE id = ?',
      [newAverage, AppDatabase.timestamp(), productId],
    );
    database.enqueueSync(
      businessId: businessId,
      entityType: 'products',
      entityId: productId,
      payload: _rawProduct(productId),
    );
  }

  int _stockForProduct(String productId) {
    return database.database.select(
          'SELECT COALESCE(SUM(quantity_delta), 0) AS stock FROM stock_movements WHERE product_id = ?',
          [productId],
        ).first['stock']
        as int;
  }

  int _averageCost(String productId) {
    return database.database.select(
          'SELECT avg_cost FROM products WHERE id = ?',
          [productId],
        ).first['avg_cost']
        as int;
  }

  Map<String, Object?> _rawProduct(String productId) {
    return database.database.select('SELECT * FROM products WHERE id = ?', [
      productId,
    ]).first;
  }

  Map<String, Object?> _rawPurchaseOrder(String id) {
    final row = database.database.select(
      'SELECT * FROM purchase_orders WHERE id = ?',
      [id],
    ).first;
    return Map<String, Object?>.from(row);
  }

  PurchaseOrder _mapPurchaseOrder(Map<String, Object?> row) {
    return PurchaseOrder(
      id: row['id'] as String,
      supplierName: row['supplier_name'] as String,
      orderNumber: row['order_number'] as String,
      expectedDate: row['expected_at'] == null
          ? '-'
          : (row['expected_at'] as String).substring(0, 10),
      itemCount: row['item_count'] as int,
      totalCost: row['calculated_total'] as int,
      status: PurchaseStatus.values.firstWhere(
        (status) => _statusName(status) == row['status'],
      ),
    );
  }

  StockMovement _mapMovement(Map<String, Object?> row) {
    return StockMovement(
      id: row['id'] as String,
      productName: row['product_name'] as String,
      type: StockMovementType.values.firstWhere(
        (type) => _movementName(type) == row['movement_type'],
      ),
      quantityDelta: row['quantity_delta'] as int,
      occurredAt: (row['occurred_at'] as String).substring(11, 16),
      reference: row['reference_id'] as String,
      note: row['note'] as String,
    );
  }

  String _statusName(PurchaseStatus status) => switch (status) {
    PurchaseStatus.draft => 'draft',
    PurchaseStatus.ordered => 'ordered',
    PurchaseStatus.partial => 'partial',
    PurchaseStatus.received => 'received',
    PurchaseStatus.cancelled => 'cancelled',
  };

  String _movementName(StockMovementType type) => switch (type) {
    StockMovementType.purchaseReceive => 'purchase_receive',
    StockMovementType.sale => 'sale',
    StockMovementType.refund => 'refund',
    StockMovementType.adjustmentIn => 'adjustment_in',
    StockMovementType.adjustmentOut => 'adjustment_out',
  };
}
