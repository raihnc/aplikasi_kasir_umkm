import '../../modules/home/models/dashboard_models.dart';
import '../../modules/reports/models/report_models.dart';
import '../local/app_database.dart';
import 'base_repository.dart';

class DashboardData {
  const DashboardData({
    required this.revenueToday,
    required this.transactionCount,
    required this.grossProfit,
    required this.inventoryValue,
    required this.lowStockProducts,
    required this.recentSales,
  });

  final int revenueToday;
  final int transactionCount;
  final int grossProfit;
  final int inventoryValue;
  final List<LowStockProduct> lowStockProducts;
  final List<RecentSale> recentSales;
}

class ReportRepository extends BaseRepository {
  const ReportRepository(super.database);

  ReportSummary summary({required DateTime start, required DateTime end}) {
    final row = database.database
        .select(
          '''
      SELECT
        COALESCE(SUM(s.total), 0) AS revenue,
        COUNT(DISTINCT s.id) AS transactions,
        COALESCE(SUM(s.profit), 0) AS gross_profit,
        COALESCE(SUM(sl.qty), 0) AS items_sold
      FROM sales s
      LEFT JOIN sale_lines sl ON sl.sale_id = s.id
      WHERE s.business_id = ?
        AND s.status = 'completed'
        AND s.created_at >= ? AND s.created_at < ?
    ''',
          [
            businessId,
            AppDatabase.timestamp(start),
            AppDatabase.timestamp(end),
          ],
        )
        .first;

    return ReportSummary(
      revenue: row['revenue'] as int,
      transactions: row['transactions'] as int,
      grossProfit: row['gross_profit'] as int,
      itemsSold: row['items_sold'] as int,
    );
  }

  List<int> dailyTrend({int days = 7}) {
    final today = DateTime.now();
    final startDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));
    final endDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).add(const Duration(days: 1));
    final rows = database.database.select(
      '''
      SELECT DATE(created_at) AS local_date, COALESCE(SUM(total), 0) AS revenue
      FROM sales
      WHERE business_id = ? AND status = 'completed'
        AND created_at >= ? AND created_at < ?
      GROUP BY DATE(created_at)
      ORDER BY local_date
    ''',
      [
        businessId,
        AppDatabase.timestamp(startDay),
        AppDatabase.timestamp(endDay),
      ],
    );

    final valuesByDate = {
      for (final row in rows)
        row['local_date'] as String: row['revenue'] as int,
    };
    return [
      for (var index = 0; index < days; index++)
        valuesByDate[DateTime(
              startDay.year,
              startDay.month,
              startDay.day + index,
            ).toIso8601String().substring(0, 10)] ??
            0,
    ];
  }

  List<TopProduct> topProducts({
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) {
    return database.database
        .select(
          '''
      SELECT sl.product_name_snapshot AS name,
             SUM(sl.qty) AS quantity,
             SUM(sl.line_total) AS revenue
      FROM sale_lines sl
      JOIN sales s ON s.id = sl.sale_id
      WHERE s.business_id = ? AND s.status = 'completed'
        AND s.created_at >= ? AND s.created_at < ?
      GROUP BY sl.product_id, sl.product_name_snapshot
      ORDER BY quantity DESC
      LIMIT ?
    ''',
          [
            businessId,
            AppDatabase.timestamp(start),
            AppDatabase.timestamp(end),
            limit,
          ],
        )
        .map(
          (row) => TopProduct(
            name: row['name'] as String,
            quantity: row['quantity'] as int,
            revenue: row['revenue'] as int,
          ),
        )
        .toList();
  }

  List<PaymentBreakdown> paymentBreakdown({
    required DateTime start,
    required DateTime end,
  }) {
    final rows = database.database.select(
      '''
      SELECT p.method, SUM(p.amount) AS amount
      FROM payments p
      JOIN sales s ON s.id = p.sale_id
      WHERE s.business_id = ? AND s.status = 'completed'
        AND s.created_at >= ? AND s.created_at < ?
      GROUP BY p.method
      ORDER BY amount DESC
    ''',
      [businessId, AppDatabase.timestamp(start), AppDatabase.timestamp(end)],
    );

    return rows.map((row) {
      final method = row['method'] as String;
      return PaymentBreakdown(
        label: method == 'cash' ? 'Cash' : 'QRIS Statis',
        amount: row['amount'] as int,
        color: method == 'cash' ? '#064E3B' : '#D4AF37',
      );
    }).toList();
  }

  DashboardData dashboard() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final summaryRow = summary(start: startOfDay, end: endOfDay);

    final inventoryValue =
        database.database
                .select(
                  '''
      SELECT COALESCE(SUM(stock * avg_cost), 0) AS value
      FROM (
        SELECT p.id, p.avg_cost,
               CASE WHEN p.track_stock = 1 THEN COALESCE(SUM(sm.quantity_delta), 0) ELSE 0 END AS stock
        FROM products p
        LEFT JOIN stock_movements sm ON sm.product_id = p.id
        WHERE p.business_id = ? AND p.deleted_at IS NULL AND p.track_stock = 1
        GROUP BY p.id
      ) AS inventory
    ''',
                  [businessId],
                )
                .first['value']
            as int;

    final lowStockRows = database.database.select(
      '''
      SELECT p.id, p.name, p.sku, p.min_stock,
             CASE WHEN p.track_stock = 1 THEN COALESCE(SUM(sm.quantity_delta), 0) ELSE 0 END AS stock
      FROM products p
      LEFT JOIN stock_movements sm ON sm.product_id = p.id
      WHERE p.business_id = ? AND p.deleted_at IS NULL
        AND p.is_active = 1 AND p.track_stock = 1
      GROUP BY p.id
      HAVING stock <= p.min_stock
      ORDER BY stock ASC
      LIMIT 20
    ''',
      [businessId],
    );

    final recentRows = database.database.select(
      '''
      SELECT s.receipt_number, s.total, s.created_at,
             GROUP_CONCAT(p.method, ',') AS methods
      FROM sales s
      LEFT JOIN payments p ON p.sale_id = s.id
      WHERE s.business_id = ?
      GROUP BY s.id
      ORDER BY s.created_at DESC
      LIMIT 5
    ''',
      [businessId],
    );

    return DashboardData(
      revenueToday: summaryRow.revenue,
      transactionCount: summaryRow.transactions,
      grossProfit: summaryRow.grossProfit,
      inventoryValue: inventoryValue,
      lowStockProducts: lowStockRows
          .map(
            (row) => LowStockProduct(
              id: row['id'] as String,
              name: row['name'] as String,
              sku: row['sku'] as String,
              remainingStock: row['stock'] as int,
              minimumStock: row['min_stock'] as int,
            ),
          )
          .toList(),
      recentSales: recentRows.map((row) {
        final createdAt = DateTime.parse(row['created_at'] as String).toLocal();
        final methods = (row['methods'] as String?)?.split(',') ?? const [];
        return RecentSale(
          receiptNumber: row['receipt_number'] as String,
          customerName: 'Pelanggan Umum',
          time:
              '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
          total: 'Rp ${row['total']}',
          paymentMethod: methods.map(_paymentLabel).join(' + '),
        );
      }).toList(),
    );
  }

  String _paymentLabel(String value) => switch (value) {
    'cash' => 'Cash',
    'qris_static' => 'QRIS Statis',
    _ => value,
  };
}
