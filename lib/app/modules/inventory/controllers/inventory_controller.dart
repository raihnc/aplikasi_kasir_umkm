import 'package:get/get.dart';

import '../models/inventory_models.dart';

class InventoryController extends GetxController {
  final selectedTab = 0.obs;
  final purchaseOrders = <PurchaseOrder>[].obs;
  final stockMovements = <StockMovement>[].obs;
  final suppliers = <Supplier>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void receivePurchaseOrder(PurchaseOrder order) {
    final index = purchaseOrders.indexWhere((item) => item.id == order.id);
    if (index >= 0 && order.status != PurchaseStatus.received) {
      purchaseOrders[index] = PurchaseOrder(
        id: order.id,
        supplierName: order.supplierName,
        orderNumber: order.orderNumber,
        expectedDate: order.expectedDate,
        itemCount: order.itemCount,
        totalCost: order.totalCost,
        status: PurchaseStatus.received,
      );
      stockMovements.insert(
        0,
        StockMovement(
          id: 'sm-${DateTime.now().microsecondsSinceEpoch}',
          productName: '${order.itemCount} item PO ${order.orderNumber}',
          type: StockMovementType.purchaseReceive,
          quantityDelta: order.itemCount,
          occurredAt: 'Baru saja',
          reference: order.orderNumber,
        ),
      );
    }
  }

  void adjustStock(String productName, int quantity) {
    stockMovements.insert(
      0,
      StockMovement(
        id: 'sm-${DateTime.now().microsecondsSinceEpoch}',
        productName: productName,
        type: quantity >= 0
            ? StockMovementType.adjustmentIn
            : StockMovementType.adjustmentOut,
        quantityDelta: quantity,
        occurredAt: 'Baru saja',
        reference: 'ADJ',
        note: 'Penyesuaian hasil opname',
      ),
    );
    Get.back<void>();
    Get.snackbar(
      'Stok disesuaikan',
      '$productName (${quantity >= 0 ? '+' : ''}$quantity)',
    );
  }

  void addSupplier(String name, String phone) {
    suppliers.insert(
      0,
      Supplier(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        phone: phone,
        address: 'Belum diisi',
      ),
    );
    Get.back<void>();
  }

  void _loadSampleData() {
    purchaseOrders.assignAll(const [
      PurchaseOrder(
        id: 'po-01',
        supplierName: 'CV Sumber Pangan',
        orderNumber: 'PO-2201',
        expectedDate: '22 Agu 2026',
        itemCount: 48,
        totalCost: 2860000,
        status: PurchaseStatus.ordered,
      ),
      PurchaseOrder(
        id: 'po-02',
        supplierName: 'PT Distribusi Nusantara',
        orderNumber: 'PO-2200',
        expectedDate: '20 Agu 2026',
        itemCount: 96,
        totalCost: 412000,
        status: PurchaseStatus.partial,
      ),
      PurchaseOrder(
        id: 'po-03',
        supplierName: 'PT Rumah Bersih',
        orderNumber: 'PO-2198',
        expectedDate: '15 Agu 2026',
        itemCount: 36,
        totalCost: 666000,
        status: PurchaseStatus.received,
      ),
    ]);
    stockMovements.assignAll(const [
      StockMovement(
        id: 'sm-05',
        productName: 'Beras Premium 5 kg',
        type: StockMovementType.sale,
        quantityDelta: -2,
        occurredAt: '13:45',
        reference: 'TRX-038',
      ),
      StockMovement(
        id: 'sm-04',
        productName: 'Air Mineral 600 ml',
        type: StockMovementType.adjustmentOut,
        quantityDelta: -3,
        occurredAt: '11:20',
        reference: 'OPN-08',
        note: 'Botol pecah',
      ),
      StockMovement(
        id: 'sm-03',
        productName: 'Kopi Instan 20 g',
        type: StockMovementType.purchaseReceive,
        quantityDelta: 48,
        occurredAt: '09:10',
        reference: 'PO-2198',
      ),
    ]);
    suppliers.assignAll(const [
      Supplier(
        id: 's-01',
        name: 'CV Sumber Pangan',
        phone: '+62 811 200 301',
        address: 'Jl. Pasar Induk 12',
      ),
      Supplier(
        id: 's-02',
        name: 'PT Distribusi Nusantara',
        phone: '+62 811 200 302',
        address: 'Jl. Industri Raya 45',
      ),
      Supplier(
        id: 's-03',
        name: 'PT Rumah Bersih',
        phone: '+62 811 200 303',
        address: 'Jl. Merdeka 88',
      ),
    ]);
  }
}
