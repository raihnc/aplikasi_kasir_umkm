import 'package:aplikasi_kasir_umkm/app/modules/costumer/controller/costumer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class CustomersView extends GetView<CustomersController> {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // _buildSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buku Piutang & Pelanggan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.surfaceDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(child: _buildCustomerList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSidebar() {
  //   // Struktur sidebar (sama seperti halaman sebelumnya)
  //   return Container(width: 80, color: AppTheme.surfaceDark);
  // }

  Widget _buildCustomerList() {
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
          padding: const EdgeInsets.all(0),
          itemCount: controller.customers.length,
          // ignore: unnecessary_underscores
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppTheme.divider),
          itemBuilder: (context, index) {
            final customer = controller.customers[index];
            final hasDebt = customer['debt_balance'] > 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.background,
                    child: Text(
                      customer['name'][0],
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          customer['phone'],
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Sisa Piutang', style: AppTheme.labelCaps),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${customer['debt_balance']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: hasDebt
                              ? AppTheme.error
                              : AppTheme.surfaceDark,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Secondary Button (Ghost Style) berdasar desain
                  OutlinedButton(
                    onPressed: hasDebt
                        ? () => controller.receivePayment(customer['name'])
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'TERIMA PEMBAYARAN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
