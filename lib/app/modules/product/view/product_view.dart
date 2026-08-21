import 'package:aplikasi_kasir_umkm/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

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
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Expanded(child: _buildProductList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildSidebar() {
  //   return Container(
  //     width: 80,
  //     color: AppTheme.surfaceDark,
  //     child: Column(
  //       children: [
  //         const SizedBox(height: 24),
  //         const Icon(Icons.storefront, color: Colors.white, size: 32),
  //         const Spacer(),
  //         IconButton(
  //           icon: const Icon(Icons.inventory, color: AppTheme.secondary),
  //           onPressed: () {},
  //         ), // Indikator aktif
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Manajemen Produk',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: AppTheme.surfaceDark,
          ),
        ),
        ElevatedButton.icon(
          onPressed: controller.addProduct,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'TAMBAH PRODUK',
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

  Widget _buildProductList() {
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
          itemCount: controller.products.length,
          // ignore: unnecessary_underscores
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppTheme.divider),
          itemBuilder: (context, index) {
            final product = controller.products[index];
            final isLowStock = product['stock'] <= 5;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              title: Text(
                product['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                product['category'],
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${product['price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        'Stok: ${product['stock']}',
                        style: TextStyle(
                          color: isLowStock ? AppTheme.error : Colors.black54,
                          fontWeight: isLowStock
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppTheme.surfaceDark,
                    ),
                    onPressed: () {}, // Edit form
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
