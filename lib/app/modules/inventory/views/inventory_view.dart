import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';
import '../controllers/inventory_controller.dart';
import '../models/inventory_models.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: PageHeader(
              title: 'Inventori',
              subtitle: 'Pantau pembelian, pergerakan stok, dan supplier',
              actions: [
                ElevatedButton.icon(
                  onPressed: () => _showAdjustmentSheet(context),
                  icon: const Icon(Icons.tune),
                  label: const Text('Sesuaikan'),
                ),
              ],
            ),
          ),
          TabBar(
            tabs: const [
              Tab(text: 'Purchase Order'),
              Tab(text: 'Pergerakan'),
              Tab(text: 'Supplier'),
            ],
            onTap: (index) => controller.selectedTab.value = index,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PurchaseOrderTab(controller: controller),
                _MovementTab(controller: controller),
                _SupplierTab(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentSheet(BuildContext context) {
    final product = TextEditingController();
    final quantity = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Penyesuaian Stok',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: product,
              decoration: const InputDecoration(labelText: 'Nama produk'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: quantity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (+/-)',
                helperText: 'Gunakan minus untuk pengurangan',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => controller.adjustStock(
                product.text,
                int.tryParse(quantity.text) ?? 0,
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseOrderTab extends StatelessWidget {
  const _PurchaseOrderTab({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.purchaseOrders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = controller.purchaseOrders[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              title: Text(
                '${order.orderNumber} • ${order.supplierName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${order.itemCount} item • Estimasi ${order.expectedDate}',
              ),
              trailing: order.status == PurchaseStatus.received
                  ? Chip(
                      label: const Text('Diterima'),
                      backgroundColor: AppColors.primaryContainer,
                    )
                  : FilledButton.tonal(
                      onPressed: () => controller.receivePurchaseOrder(order),
                      child: const Text('Terima'),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _MovementTab extends StatelessWidget {
  const _MovementTab({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: controller.stockMovements.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final movement = controller.stockMovements[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: Icon(
                movement.quantityDelta >= 0
                    ? Icons.add_circle_outline
                    : Icons.remove_circle_outline,
                color: movement.quantityDelta >= 0
                    ? AppColors.primary
                    : AppColors.error,
              ),
              title: Text(
                movement.productName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${movement.typeLabel} • ${movement.reference} • ${movement.occurredAt}',
              ),
              trailing: Text(
                '${movement.quantityDelta >= 0 ? '+' : ''}${movement.quantityDelta}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: movement.quantityDelta >= 0
                      ? AppColors.primary
                      : AppColors.error,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SupplierTab extends StatelessWidget {
  const _SupplierTab({required this.controller});

  final InventoryController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Supplier'),
      ),
      body: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: controller.suppliers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final supplier = controller.suppliers[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(18),
                leading: const CircleAvatar(
                  child: Icon(Icons.business_outlined),
                ),
                title: Text(
                  supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${supplier.phone}\n${supplier.address}'),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
