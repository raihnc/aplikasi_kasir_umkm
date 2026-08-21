import 'package:get/get.dart';

import '../models/report_models.dart';

enum ReportPeriod { daily, weekly, monthly }

class ReportsController extends GetxController {
  final selectedPeriod = ReportPeriod.daily.obs;
  final summary = const ReportSummary(
    revenue: 0,
    transactions: 0,
    grossProfit: 0,
    itemsSold: 0,
  ).obs;
  final trend = <int>[].obs;
  final topProducts = <TopProduct>[].obs;
  final paymentBreakdown = <PaymentBreakdown>[].obs;

  @override
  void onInit() {
    super.onInit();
    setPeriod(ReportPeriod.daily);
  }

  void setPeriod(ReportPeriod period) {
    selectedPeriod.value = period;
    _loadSampleData(period);
  }

  void exportReport() {
    Get.snackbar(
      'Ekspor laporan',
      'File XLSX akan dibuat pada integrasi data.',
    );
  }

  void _loadSampleData(ReportPeriod period) {
    final data = switch (period) {
      ReportPeriod.daily => (
        summary: const ReportSummary(
          revenue: 2450000,
          transactions: 38,
          grossProfit: 820000,
          itemsSold: 104,
        ),
        trend: [12, 18, 9, 24, 16, 31, 22],
        topProducts: [
          const TopProduct(
            name: 'Beras Premium 5 kg',
            quantity: 14,
            revenue: 1008000,
          ),
          const TopProduct(
            name: 'Minyak Goreng 2 L',
            quantity: 21,
            revenue: 714000,
          ),
          const TopProduct(
            name: 'Air Mineral 600 ml',
            quantity: 38,
            revenue: 152000,
          ),
        ],
        payments: [
          const PaymentBreakdown(
            label: 'Cash',
            amount: 1540000,
            color: '#064E3B',
          ),
          const PaymentBreakdown(
            label: 'QRIS Statis',
            amount: 910000,
            color: '#D4AF37',
          ),
        ],
      ),
      ReportPeriod.weekly => (
        summary: const ReportSummary(
          revenue: 16840000,
          transactions: 254,
          grossProfit: 5480000,
          itemsSold: 731,
        ),
        trend: [124, 158, 132, 186, 164, 231, 202],
        topProducts: [
          const TopProduct(
            name: 'Beras Premium 5 kg',
            quantity: 92,
            revenue: 6624000,
          ),
          const TopProduct(
            name: 'Gula Pasir 1 kg',
            quantity: 118,
            revenue: 2006000,
          ),
          const TopProduct(
            name: 'Kopi Instan 20 g',
            quantity: 240,
            revenue: 600000,
          ),
        ],
        payments: [
          const PaymentBreakdown(
            label: 'Cash',
            amount: 10450000,
            color: '#064E3B',
          ),
          const PaymentBreakdown(
            label: 'QRIS Statis',
            amount: 6390000,
            color: '#D4AF37',
          ),
        ],
      ),
      ReportPeriod.monthly => (
        summary: const ReportSummary(
          revenue: 71200000,
          transactions: 1082,
          grossProfit: 23200000,
          itemsSold: 3126,
        ),
        trend: [520, 585, 610, 572, 648, 703, 682],
        topProducts: [
          const TopProduct(
            name: 'Beras Premium 5 kg',
            quantity: 402,
            revenue: 28944000,
          ),
          const TopProduct(
            name: 'Minyak Goreng 2 L',
            quantity: 486,
            revenue: 16524000,
          ),
          const TopProduct(
            name: 'Sabun Mandi Cair',
            quantity: 214,
            revenue: 3959000,
          ),
        ],
        payments: [
          const PaymentBreakdown(
            label: 'Cash',
            amount: 44100000,
            color: '#064E3B',
          ),
          const PaymentBreakdown(
            label: 'QRIS Statis',
            amount: 27100000,
            color: '#D4AF37',
          ),
        ],
      ),
    };

    summary.value = data.summary;
    trend.assignAll(data.trend);
    topProducts.assignAll(data.topProducts);
    paymentBreakdown.assignAll(data.payments);
  }
}
