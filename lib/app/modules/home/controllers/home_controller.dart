import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../main/controllers/main_controller.dart';
import '../models/dashboard_models.dart';

class HomeController extends GetxController {
  final storeName = 'Toko Ritel Nusantara'.obs;
  final ownerName = 'Owner'.obs;
  final isLoading = true.obs;
  final revenueToday = 2450000.obs;
  final transactionCount = 38.obs;
  final grossProfit = 820000.obs;
  final inventoryValue = 18600000.obs;
  final lowStockProducts = <LowStockProduct>[].obs;
  final recentSales = <RecentSale>[].obs;

  List<DashboardMetric> get metrics => [
    DashboardMetric(
      label: 'Omzet Hari Ini',
      value: CurrencyFormatter.format(revenueToday.value),
      change: '+12%',
      icon: Icons.payments_outlined,
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Transaksi',
      value: transactionCount.value.toString(),
      change: '+8%',
      icon: Icons.receipt_long_outlined,
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Laba Kotor',
      value: CurrencyFormatter.format(grossProfit.value),
      change: '+10%',
      icon: Icons.trending_up_outlined,
      isPositive: true,
    ),
    DashboardMetric(
      label: 'Nilai Stok',
      value: CurrencyFormatter.format(inventoryValue.value),
      change: '-3%',
      icon: Icons.inventory_2_outlined,
      isPositive: false,
    ),
  ];

  List<QuickAction> get quickActions => const [
    QuickAction(
      type: QuickActionType.newSale,
      title: 'Transaksi Baru',
      subtitle: 'Mulai penjualan kasir',
      icon: Icons.point_of_sale_outlined,
    ),
    QuickAction(
      type: QuickActionType.scanProduct,
      title: 'Scan Produk',
      subtitle: 'Cari dengan barcode',
      icon: Icons.qr_code_scanner_outlined,
    ),
    QuickAction(
      type: QuickActionType.addProduct,
      title: 'Tambah Produk',
      subtitle: 'Kelola katalog toko',
      icon: Icons.add_box_outlined,
    ),
    QuickAction(
      type: QuickActionType.openReport,
      title: 'Laporan',
      subtitle: 'Pantau performa toko',
      icon: Icons.bar_chart_outlined,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSampleDashboard();
  }

  Future<void> refreshDashboard() async {
    isLoading.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _loadSampleDashboard();
    isLoading.value = false;
  }

  void handleQuickAction(QuickActionType type) {
    switch (type) {
      case QuickActionType.newSale:
        Get.find<MainController>().changePage(1);
      case QuickActionType.scanProduct:
        Get.find<MainController>().changePage(2);
      case QuickActionType.addProduct:
        Get.find<MainController>().changePage(2);
      case QuickActionType.openReport:
        Get.find<MainController>().changePage(4);
    }
  }

  void _loadSampleDashboard() {
    isLoading.value = false;
    lowStockProducts.assignAll([
      const LowStockProduct(
        id: 'p-01',
        name: 'Beras Premium 5 kg',
        sku: 'BRS-005',
        remainingStock: 4,
        minimumStock: 12,
      ),
      const LowStockProduct(
        id: 'p-02',
        name: 'Minyak Goreng 2 L',
        sku: 'MYG-002',
        remainingStock: 7,
        minimumStock: 15,
      ),
      const LowStockProduct(
        id: 'p-03',
        name: 'Gula Pasir 1 kg',
        sku: 'GUL-001',
        remainingStock: 9,
        minimumStock: 20,
      ),
    ]);

    recentSales.assignAll([
      const RecentSale(
        receiptNumber: 'TRX-038',
        customerName: 'Pelanggan Umum',
        time: '13:45',
        total: 'Rp 97.000',
        paymentMethod: 'QRIS Statis',
      ),
      const RecentSale(
        receiptNumber: 'TRX-037',
        customerName: 'Ibu Sari',
        time: '13:12',
        total: 'Rp 65.000',
        paymentMethod: 'Cash',
      ),
      const RecentSale(
        receiptNumber: 'TRX-036',
        customerName: 'Pelanggan Umum',
        time: '12:58',
        total: 'Rp 142.000',
        paymentMethod: 'Cash',
      ),
    ]);
  }
}
