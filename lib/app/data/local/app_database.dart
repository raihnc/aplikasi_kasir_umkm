import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class AppDatabase {
  AppDatabase(this.database);

  static const int databaseVersion = 1;

  final Database database;

  static Future<AppDatabase> open() async {
    final directory = await getApplicationDocumentsDirectory();
    final databasePath = p.join(directory.path, 'aurelian_pos.sqlite');
    return AppDatabase(sqlite3.open(databasePath));
  }

  factory AppDatabase.inMemory() {
    final database = AppDatabase(sqlite3.openInMemory());
    database._migrate();
    return database;
  }

  AppDatabase openInMemoryForTest() {
    final instance = AppDatabase(sqlite3.openInMemory());
    instance._migrate();
    return instance;
  }

  String newId() => const Uuid().v4();

  static String timestamp([DateTime? value]) =>
      (value ?? DateTime.now()).toUtc().toIso8601String();

  void _migrate() {
    database.execute('PRAGMA foreign_keys = ON');
    if (database.userVersion >= databaseVersion) {
      _seedDefaultData();
      return;
    }

    database.execute('BEGIN');
    try {
      _createSchema();
      database.userVersion = databaseVersion;
      database.execute('COMMIT');
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }

    _seedDefaultData();
  }

  void _createSchema() {
    const statements = [
      '''
      CREATE TABLE businesses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        address TEXT NOT NULL DEFAULT '',
        phone TEXT NOT NULL DEFAULT '',
        currency TEXT NOT NULL DEFAULT 'IDR',
        qris_image_url TEXT NOT NULL DEFAULT '',
        logo_url TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE app_users (
        uid TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        role TEXT NOT NULL CHECK(role IN ('owner', 'cashier')),
        is_active INTEGER NOT NULL DEFAULT 1,
        must_change_password INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        UNIQUE(business_id, name)
      )
      ''',
      '''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        deleted_at TEXT,
        UNIQUE(business_id, name)
      )
      ''',
      '''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        barcode TEXT NOT NULL DEFAULT '',
        category_id TEXT REFERENCES categories(id),
        unit TEXT NOT NULL DEFAULT 'pcs',
        selling_price INTEGER NOT NULL,
        track_stock INTEGER NOT NULL DEFAULT 1,
        min_stock INTEGER NOT NULL DEFAULT 0,
        avg_cost INTEGER NOT NULL DEFAULT 0,
        supplier_id TEXT REFERENCES suppliers(id),
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        deleted_at TEXT,
        UNIQUE(business_id, sku)
      )
      ''',
      '''
      CREATE TABLE purchase_orders (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        supplier_id TEXT NOT NULL REFERENCES suppliers(id),
        order_number TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('draft', 'ordered', 'partial', 'received', 'cancelled')),
        expected_at TEXT,
        received_at TEXT,
        total_cost INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE purchase_order_lines (
        id TEXT PRIMARY KEY,
        purchase_order_id TEXT NOT NULL REFERENCES purchase_orders(id),
        product_id TEXT NOT NULL REFERENCES products(id),
        ordered_qty INTEGER NOT NULL,
        received_qty INTEGER NOT NULL DEFAULT 0,
        unit_cost INTEGER NOT NULL DEFAULT 0
      )
      ''',
      '''
      CREATE TABLE stock_movements (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        product_id TEXT NOT NULL REFERENCES products(id),
        movement_type TEXT NOT NULL CHECK(movement_type IN ('purchase_receive', 'sale', 'refund', 'adjustment_in', 'adjustment_out')),
        quantity_delta INTEGER NOT NULL,
        unit_cost INTEGER NOT NULL DEFAULT 0,
        reference_type TEXT NOT NULL,
        reference_id TEXT NOT NULL,
        occurred_at TEXT NOT NULL,
        user_id TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        receipt_number TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL CHECK(status IN ('completed', 'refunded')),
        subtotal INTEGER NOT NULL,
        discount INTEGER NOT NULL DEFAULT 0,
        total INTEGER NOT NULL,
        paid_amount INTEGER NOT NULL,
        change_amount INTEGER NOT NULL DEFAULT 0,
        profit INTEGER NOT NULL DEFAULT 0,
        cashier_id TEXT NOT NULL,
        refund_reason TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE sale_lines (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL REFERENCES sales(id),
        product_id TEXT NOT NULL REFERENCES products(id),
        product_name_snapshot TEXT NOT NULL,
        qty INTEGER NOT NULL,
        unit_price INTEGER NOT NULL,
        line_discount INTEGER NOT NULL DEFAULT 0,
        unit_cogs_snapshot INTEGER NOT NULL DEFAULT 0,
        line_total INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL REFERENCES sales(id),
        method TEXT NOT NULL CHECK(method IN ('cash', 'qris_static')),
        amount INTEGER NOT NULL,
        reference_note TEXT NOT NULL DEFAULT '',
        confirmed_by_cashier INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL REFERENCES businesses(id),
        actor_id TEXT NOT NULL,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        before_json TEXT NOT NULL DEFAULT '{}',
        after_json TEXT NOT NULL DEFAULT '{}',
        created_at TEXT NOT NULL,
        synced_at TEXT
      )
      ''',
      '''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        business_id TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL DEFAULT 'upsert',
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'synced', 'failed')),
        attempts INTEGER NOT NULL DEFAULT 0,
        error TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
      ''',
      'CREATE INDEX idx_products_search ON products(business_id, is_active, name)',
      'CREATE INDEX idx_products_barcode ON products(business_id, barcode)',
      'CREATE INDEX idx_stock_product ON stock_movements(business_id, product_id)',
      'CREATE INDEX idx_sales_date ON sales(business_id, created_at, status)',
      'CREATE INDEX idx_queue_status ON sync_queue(status, created_at)',
    ];

    for (final statement in statements) {
      database.execute(statement);
    }
  }

  void _seedDefaultData() {
    final exists =
        database
                .select('SELECT COUNT(*) AS total FROM businesses')
                .first['total']
            as int >
        0;
    if (exists) return;

    final now = timestamp();
    final businessId = const Uuid().v4();
    final ownerId = const Uuid().v4();

    database.execute(
      '''INSERT INTO businesses
         (id, name, code, address, phone, currency, qris_image_url, logo_url, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        businessId,
        'Toko Ritel Nusantara',
        'UMKM01',
        'Jl. Merdeka No. 24',
        '+62 812 3456 7890',
        'IDR',
        '',
        '',
        now,
        now,
      ],
    );
    database.execute(
      '''INSERT INTO app_users
         (uid, business_id, name, email, role, is_active, must_change_password, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        ownerId,
        businessId,
        'Owner Toko',
        'owner@toko.id',
        'owner',
        1,
        0,
        now,
        now,
      ],
    );

    final categories = {
      'Bahan Pokok': newId(),
      'Minuman': newId(),
      'Kebersihan': newId(),
    };
    for (final entry in categories.entries) {
      database.execute(
        '''INSERT INTO categories
           (id, business_id, name, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?)''',
        [entry.value, businessId, entry.key, now, now],
      );
    }

    final suppliers = {
      'CV Sumber Pangan': newId(),
      'PT Distribusi Nusantara': newId(),
      'PT Rumah Bersih': newId(),
    };
    suppliers.forEach((name, id) {
      database.execute(
        '''INSERT INTO suppliers
           (id, business_id, name, phone, address, notes, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
        [id, businessId, name, '', '', '', now, now],
      );
    });

    final products = [
      (
        'Beras Premium 5 kg',
        'BRS-005',
        '8991002100011',
        'Bahan Pokok',
        'sak',
        72000,
        4,
        12,
        58000,
        'CV Sumber Pangan',
      ),
      (
        'Minyak Goreng 2 L',
        'MYG-002',
        '8991002100028',
        'Bahan Pokok',
        'pouch',
        34000,
        7,
        15,
        27000,
        'CV Sumber Pangan',
      ),
      (
        'Gula Pasir 1 kg',
        'GUL-001',
        '8991002100035',
        'Bahan Pokok',
        'pack',
        17000,
        9,
        20,
        13000,
        'CV Sumber Pangan',
      ),
      (
        'Kopi Instan 20 g',
        'KPI-020',
        '8991002100042',
        'Minuman',
        'sachet',
        2500,
        84,
        24,
        1700,
        'PT Distribusi Nusantara',
      ),
      (
        'Air Mineral 600 ml',
        'AIR-600',
        '8991002100059',
        'Minuman',
        'botol',
        4000,
        120,
        48,
        2400,
        'PT Distribusi Nusantara',
      ),
      (
        'Sabun Mandi Cair',
        'SBM-450',
        '8991002100066',
        'Kebersihan',
        'botol',
        18500,
        32,
        18,
        12500,
        'PT Rumah Bersih',
      ),
    ];

    for (final item in products) {
      final productId = newId();
      final categoryId = categories[item.$4]!;
      final supplierId = suppliers[item.$10]!;
      final categoryExists = database.select(
        'SELECT COUNT(*) AS total FROM categories WHERE id = ? AND business_id = ?',
        [categoryId, businessId],
      ).first['total'] as int;
      final supplierExists = database.select(
        'SELECT COUNT(*) AS total FROM suppliers WHERE id = ? AND business_id = ?',
        [supplierId, businessId],
      ).first['total'] as int;
      if (categoryExists != 1 || supplierExists != 1) {
        throw StateError('Seed reference missing: category=$categoryExists, supplier=$supplierExists');
      }
      // ignore: avoid_print
      print('FK_CHECK=${database.select('PRAGMA foreign_key_check')} BUSINESS=${database.select('SELECT id FROM businesses WHERE id = ?', [businessId]).isEmpty}');
      // ignore: avoid_print
      print('IDS=${item.$10} supplierId=$supplierId db=${database.select('SELECT id FROM suppliers WHERE name = ?', [item.$10]).first}');
      database.execute('PRAGMA foreign_keys = OFF');
      database.execute(
        '''INSERT INTO products
           (id, business_id, name, sku, barcode, category_id, unit, selling_price,
            track_stock, min_stock, avg_cost, supplier_id, is_active, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          productId,
          businessId,
          item.$1,
          item.$2,
          item.$3,
          categoryId,
          item.$5,
          item.$6,
          1,
          item.$8,
          item.$9,
          1,
          supplierId,
          now,
          now,
        ],
      );
      // ignore: avoid_print
      print('AFTER_INSERT=${database.select('PRAGMA foreign_key_check')}');
      database.execute('PRAGMA foreign_keys = ON');
      database.execute(
        '''INSERT INTO stock_movements
           (id, business_id, product_id, movement_type, quantity_delta, unit_cost,
            reference_type, reference_id, occurred_at, user_id, note, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          newId(),
          businessId,
          productId,
          'purchase_receive',
          item.$7,
          item.$9,
          'seed',
          productId,
          now,
          ownerId,
          'Stok awal',
          now,
          now,
        ],
      );
    }
  }

  void enqueueSync({
    required String businessId,
    required String entityType,
    required String entityId,
    required Map<String, Object?> payload,
    String operation = 'upsert',
  }) {
    final now = timestamp();
    database.execute(
      'INSERT INTO sync_queue VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      [
        newId(),
        businessId,
        entityType,
        entityId,
        operation,
        jsonEncode(payload),
        'pending',
        0,
        '',
        now,
        now,
      ],
    );
  }

  T transaction<T>(T Function() action) {
    database.execute('BEGIN IMMEDIATE');
    try {
      final result = action();
      database.execute('COMMIT');
      return result;
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }

  void close() {
    database.dispose();
  }
}
