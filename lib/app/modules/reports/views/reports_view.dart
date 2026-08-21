import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/page_header.dart';
import '../models/report_models.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Laporan',
            subtitle: 'Pantau omzet, laba kotor, dan produk terlaris',
            actions: [
              ElevatedButton.icon(
                onPressed: controller.exportReport,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Ekspor XLSX'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(
            () => SegmentedButton<ReportPeriod>(
              segments: const [
                ButtonSegment(value: ReportPeriod.daily, label: Text('Harian')),
                ButtonSegment(
                  value: ReportPeriod.weekly,
                  label: Text('Mingguan'),
                ),
                ButtonSegment(
                  value: ReportPeriod.monthly,
                  label: Text('Bulanan'),
                ),
              ],
              selected: {controller.selectedPeriod.value},
              onSelectionChanged: (selection) =>
                  controller.setPeriod(selection.first),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => _SummaryCards(summary: controller.summary.value)),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final trend = _TrendCard(controller: controller);
              final products = _TopProductsCard(controller: controller);
              final payments = _PaymentCard(controller: controller);

              if (isWide) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        Expanded(child: trend),
                        Expanded(child: products),
                      ],
                    ),
                    const SizedBox(height: 16),
                    payments,
                  ],
                );
              }

              return Column(spacing: 16, children: [trend, products, payments]);
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final ReportSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 900 ? 4 : 2;
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (count - 1)) / count;

        final items = [
          (
            'Omzet',
            CurrencyFormatter.format(summary.revenue),
            Icons.payments_outlined,
          ),
          (
            'Transaksi',
            summary.transactions.toString(),
            Icons.receipt_long_outlined,
          ),
          (
            'Laba Kotor',
            CurrencyFormatter.format(summary.grossProfit),
            Icons.trending_up_outlined,
          ),
          (
            'Rata-rata',
            CurrencyFormatter.format(summary.averageBasket),
            Icons.analytics_outlined,
          ),
        ];

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(item.$3, color: AppColors.primary),
                        const SizedBox(height: 14),
                        Text(item.$1, style: AppTheme.labelCaps),
                        const SizedBox(height: 6),
                        FittedBox(
                          child: Text(
                            item.$2,
                            style: AppTheme.priceDisplay.copyWith(fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TREN PENJUALAN', style: AppTheme.labelCaps),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 10,
                  children: [
                    for (final value in controller.trend)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 40 + value.toDouble() * .8,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: .82),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PRODUK TERLARIS', style: AppTheme.labelCaps),
              const SizedBox(height: 8),
              for (final product in controller.topProducts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.quantity} terjual'),
                  trailing: Text(
                    CurrencyFormatter.format(product.revenue),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.controller});

  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('KOMPOSISI PEMBAYARAN', style: AppTheme.labelCaps),
              const SizedBox(height: 18),
              for (final payment in controller.paymentBreakdown) ...[
                Row(
                  children: [
                    Expanded(child: Text(payment.label)),
                    Text(
                      CurrencyFormatter.format(payment.amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      payment.amount /
                      controller.paymentBreakdown.fold(
                        0,
                        (sum, item) => sum + item.amount,
                      ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(999),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
