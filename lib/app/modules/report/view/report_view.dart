import 'package:aplikasi_kasir_umkm/app/modules/report/controller/report_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Catatan: Sidebar dihapus dari sini karena akan di-handle oleh MainLayout
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildSummaryCards(),
          const SizedBox(height: 32),
          const Text('Transaksi Terakhir', style: AppTheme.labelCaps),
          const SizedBox(height: 16),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Laporan Penjualan',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppTheme.surfaceDark,
          ),
        ),
        ElevatedButton.icon(
          onPressed: controller.exportToExcel,
          icon: const Icon(Icons.download, color: Colors.white),
          label: const Text(
            'EKSPOR EXCEL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Obx(
      () => Row(
        children: [
          _buildCard(
            'Omzet Hari Ini',
            'Rp ${controller.omzet.value.toInt()}',
            AppTheme.primary,
          ),
          const SizedBox(width: 24),
          _buildCard(
            'Laba Kotor',
            'Rp ${controller.labaKotor.value.toInt()}',
            AppTheme.secondary,
          ),
          const SizedBox(width: 24),
          _buildCard(
            'Total Transaksi',
            '${controller.totalTransaksi.value}',
            AppTheme.surfaceDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 6)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.labelCaps),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.priceDisplay.copyWith(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Obx(
        () => ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: controller.recentTransactions.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppTheme.divider),
          itemBuilder: (context, index) {
            final trx = controller.recentTransactions[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              title: Text(
                trx['id'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(trx['date']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${trx['total']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    trx['method'],
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
