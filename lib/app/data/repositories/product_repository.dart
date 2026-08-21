import '../../modules/product/models/product.dart';
import '../local/app_database.dart';
import 'base_repository.dart';

class ProductRepository extends BaseRepository {
  const ProductRepository(super.database);

  static const String _selectProduct = '''
    SELECT p.*,
           COALESCE(c.name, 'Umum') AS category_name,
           COALESCE(s.name, '') AS supplier_name,
           CASE
             WHEN p.track_stock = 1 THEN COALESCE((
               SELECT SUM(quantity_delta)
               FROM stock_movements sm
               WHERE sm.product_id = p.id
             ), 0)
             ELSE 0
           END AS stock
    FROM products p
    LEFT JOIN categories c ON c.id = p.category_id
    LEFT JOIN suppliers s ON s.id = p.supplier_id
    WHERE p.business_id = ? AND p.deleted_at IS NULL
  ''';

  List<Product> listProducts({String query = '', String category = 'Semua'}) {
    var sql = _selectProduct;
    final arguments = <Object?>[businessId];

    if (category != 'Semua') {
      sql += ' AND COALESCE(c.name, ?) = ?';
      arguments
        ..add('Umum')
        ..add(category);
    }
    if (query.trim().isNotEmpty) {
      final trimmedQuery = query.trim();
      final normalized = '%$trimmedQuery%';
      sql += ' AND (p.name LIKE ? OR p.sku LIKE ? OR p.barcode LIKE ?)';
      arguments.addAll([normalized, normalized, normalized]);
    }
    sql += ' ORDER BY p.created_at DESC, p.name ASC';

    return database.database.select(sql, arguments).map(_mapProduct).toList();
  }

  List<String> listCategories() {
    final rows = database.database.select(
      '''
      SELECT name FROM categories
      WHERE business_id = ?
      ORDER BY name
    ''',
      [businessId],
    );
    return rows.map((row) => row['name'] as String).toList();
  }

  Product? findByBarcode(String barcode) {
    final rows = database.database.select(
      '$_selectProduct AND p.barcode = ? LIMIT 1',
      [businessId, barcode],
    );
    return rows.isEmpty ? null : _mapProduct(rows.first);
  }

  Future<Product> create({
    required String name,
    required String sku,
    required String barcode,
    required String category,
    required String unit,
    required int sellingPrice,
    int minimumStock = 0,
    int initialStock = 0,
    int initialCost = 0,
    bool trackStock = true,
    String? supplierName,
  }) async {
    final now = AppDatabase.timestamp();
    final id = database.newId();
    final business = businessId;
    final categoryId = _ensureCategory(category);
    final supplierId = supplierName == null
        ? null
        : _ensureSupplier(supplierName);

    database.transaction(() {
      database.database.execute(
        '''INSERT INTO products
           (id, business_id, name, sku, barcode, category_id, unit, selling_price,
            track_stock, min_stock, avg_cost, supplier_id, is_active, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          id,
          business,
          name,
          sku,
          barcode,
          categoryId,
          unit,
          sellingPrice,
          trackStock ? 1 : 0,
          minimumStock,
          initialCost,
          supplierId,
          1,
          now,
          now,
        ],
      );

      if (trackStock && initialStock > 0) {
        _insertMovement(
          productId: id,
          movementType: 'purchase_receive',
          quantityDelta: initialStock,
          unitCost: initialCost,
          referenceType: 'seed',
          referenceId: id,
          note: 'Stok awal',
          occurredAt: now,
        );
      }

      final payload = {
        'id': id,
        'business_id': business,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'category_id': categoryId,
        'unit': unit,
        'selling_price': sellingPrice,
        'track_stock': trackStock,
        'min_stock': minimumStock,
        'avg_cost': initialCost,
        'supplier_id': supplierId,
        'is_active': true,
        'updated_at': now,
      };
      database.enqueueSync(
        businessId: business,
        entityType: 'products',
        entityId: id,
        payload: payload,
      );
      audit(
        action: 'create',
        entityType: 'product',
        entityId: id,
        after: payload,
        occurredAt: DateTime.now(),
      );
    });

    return listProducts(query: sku).firstWhere((item) => item.id == id);
  }

  Future<void> setActive(String productId, bool isActive) async {
    final now = AppDatabase.timestamp();
    final before = _rawProduct(productId);
    database.database.execute(
      'UPDATE products SET is_active = ?, updated_at = ? WHERE id = ?',
      [isActive ? 1 : 0, now, productId],
    );
    final after = _rawProduct(productId);
    database.enqueueSync(
      businessId: businessId,
      entityType: 'products',
      entityId: productId,
      payload: after,
    );
    audit(
      action: 'update',
      entityType: 'product',
      entityId: productId,
      before: before,
      after: after,
    );
  }

  String _ensureCategory(String name) {
    final business = businessId;
    final existing = database.database.select(
      'SELECT id FROM categories WHERE business_id = ? AND name = ? LIMIT 1',
      [business, name],
    );
    if (existing.isNotEmpty) return existing.first['id'] as String;

    final id = database.newId();
    final now = AppDatabase.timestamp();
    database.database.execute(
      '''INSERT INTO categories (id, business_id, name, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?)''',
      [id, business, name, now, now],
    );
    database.enqueueSync(
      businessId: business,
      entityType: 'categories',
      entityId: id,
      payload: {
        'id': id,
        'business_id': business,
        'name': name,
        'updated_at': now,
      },
    );
    return id;
  }

  String? _ensureSupplier(String name) {
    final business = businessId;
    final existing = database.database.select(
      'SELECT id FROM suppliers WHERE business_id = ? AND name = ? LIMIT 1',
      [business, name],
    );
    if (existing.isNotEmpty) return existing.first['id'] as String;

    final id = database.newId();
    final now = AppDatabase.timestamp();
    database.database.execute(
      '''INSERT INTO suppliers
         (id, business_id, name, phone, address, notes, created_at, updated_at)
         VALUES (?, ?, ?, '', '', '', ?, ?)''',
      [id, business, name, now, now],
    );
    database.enqueueSync(
      businessId: business,
      entityType: 'suppliers',
      entityId: id,
      payload: {
        'id': id,
        'business_id': business,
        'name': name,
        'updated_at': now,
      },
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
        currentUserId,
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
        'user_id': currentUserId,
        'note': note,
        'updated_at': now,
      },
    );
  }

  Map<String, Object?> _rawProduct(String productId) {
    return database.database.select('SELECT * FROM products WHERE id = ?', [
      productId,
    ]).first;
  }

  Product _mapProduct(Map<String, Object?> row) {
    return Product(
      id: row['id'] as String,
      name: row['name'] as String,
      sku: row['sku'] as String,
      barcode: row['barcode'] as String,
      category: row['category_name'] as String,
      unit: row['unit'] as String,
      price: row['selling_price'] as int,
      stock: row['stock'] as int,
      minimumStock: row['min_stock'] as int,
      supplier: row['supplier_name'] as String,
      trackStock: row['track_stock'] == 1,
      isActive: row['is_active'] == 1,
    );
  }
}
