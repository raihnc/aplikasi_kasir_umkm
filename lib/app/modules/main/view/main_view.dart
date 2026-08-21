import 'package:aplikasi_kasir_umkm/app/modules/costumer/view/costumer_view.dart';
import 'package:aplikasi_kasir_umkm/app/modules/main/controller/main_controller.dart';
import 'package:aplikasi_kasir_umkm/app/modules/product/view/product_view.dart';
import 'package:aplikasi_kasir_umkm/app/modules/report/view/report_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';
import '../../../core/theme/app_theme.dart';

class MainView extends GetView<MainController> {
  // Daftar halaman yang diakses dari sidebar
  final List<Widget> pages = [
    HomeView(), // 0: Kasir / POS
    ProductsView(), // 1: Produk
    CustomersView(), // 2: Piutang Pelanggan
    ReportsView(), // 3: Laporan
  ];

  MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Obx(
              () => IndexedStack(
                index: controller.currentIndex.value,
                children: pages,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 88, // Minimal interactive area > 44px
      color: AppTheme.surfaceDark,
      child: Obx(
        () => Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.storefront, color: Colors.white, size: 36),
            const SizedBox(height: 48),
            _buildNavItem(Icons.point_of_sale, 0, 'Kasir'),
            _buildNavItem(Icons.inventory_2_outlined, 1, 'Produk'),
            _buildNavItem(Icons.people_outline, 2, 'Piutang'),
            _buildNavItem(Icons.bar_chart, 3, 'Laporan'),
            const Spacer(),
            _buildNavItem(Icons.settings_outlined, 4, 'Pengaturan'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = controller.currentIndex.value == index;
    return InkWell(
      onTap: () {
        if (index < 4) {
          controller.changePage(
            index,
          ); // Index 4 (Settings) bisa berupa modal/dialog
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.secondary : Colors.transparent,
              width: 4,
            ),
          ),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.secondary : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.secondary : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
