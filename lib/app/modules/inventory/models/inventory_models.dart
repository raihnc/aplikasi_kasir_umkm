enum PurchaseStatus { draft, ordered, partial, received, cancelled }

class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
}

class PurchaseOrder {
  const PurchaseOrder({
    required this.id,
    required this.supplierName,
    required this.orderNumber,
    required this.expectedDate,
    required this.itemCount,
    required this.totalCost,
    required this.status,
  });

  final String id;
  final String supplierName;
  final String orderNumber;
  final String expectedDate;
  final int itemCount;
  final int totalCost;
  final PurchaseStatus status;

  String get statusLabel => switch (status) {
    PurchaseStatus.draft => 'Draft',
    PurchaseStatus.ordered => 'Dipesan',
    PurchaseStatus.partial => 'Sebagian',
    PurchaseStatus.received => 'Diterima',
    PurchaseStatus.cancelled => 'Dibatalkan',
  };
}

enum StockMovementType {
  purchaseReceive,
  sale,
  refund,
  adjustmentIn,
  adjustmentOut,
}

class StockMovement {
  const StockMovement({
    required this.id,
    required this.productName,
    required this.type,
    required this.quantityDelta,
    required this.occurredAt,
    required this.reference,
    this.note = '',
  });

  final String id;
  final String productName;
  final StockMovementType type;
  final int quantityDelta;
  final String occurredAt;
  final String reference;
  final String note;

  String get typeLabel => switch (type) {
    StockMovementType.purchaseReceive => 'Pembelian',
    StockMovementType.sale => 'Penjualan',
    StockMovementType.refund => 'Refund',
    StockMovementType.adjustmentIn => 'Penyesuaian masuk',
    StockMovementType.adjustmentOut => 'Penyesuaian keluar',
  };
}
