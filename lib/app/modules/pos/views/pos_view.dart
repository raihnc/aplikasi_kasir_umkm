import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../product/models/product.dart';
import '../controllers/pos_controller.dart';
import '../models/pos_models.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: _ProductWorkspace(controller: controller)),
              const VerticalDivider(width: 1, color: AppColors.divider),
              SizedBox(
                width: 390,
                child: _TransactionPane(controller: controller),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(child: _ProductWorkspace(controller: controller)),
            _MobileCheckoutBar(
              controller: controller,
              onViewPayment: () => _showMobilePayment(context),
            ),
          ],
        );
      },
    );
  }

  void _showMobilePayment(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * .82,
          child: _TransactionPane(controller: controller),
        );
      },
    );
  }
}

class _ProductWorkspace extends StatelessWidget {
  const _ProductWorkspace({required this.controller});

  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kasir',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih produk atau pindai barcode',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => controller.searchQuery.value = value,
                  decoration: const InputDecoration(
                    hintText: 'Cari nama, SKU, atau barcode',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: controller.scanBarcode,
                tooltip: 'Scan barcode',
                iconSize: 24,
                style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final products = controller.filteredProducts;
              if (products.isEmpty) {
                return const Center(child: Text('Produk tidak ditemukan'));
              }

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.55,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductTile(
                    product: product,
                    onTap: () => controller.addToCart(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.trackStock && product.stock <= 0;

    return InkWell(
      onTap: outOfStock ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: outOfStock ? AppColors.surfaceVariant : AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.format(product.price),
                style: AppTheme.priceDisplay.copyWith(fontSize: 19),
              ),
              const SizedBox(height: 4),
              Text(
                product.trackStock
                    ? 'Stok: ${product.stock} ${product.unit}'
                    : 'Tanpa stok',
                style: TextStyle(
                  fontSize: 12,
                  color: outOfStock
                      ? AppColors.error
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileCheckoutBar extends StatelessWidget {
  const _MobileCheckoutBar({
    required this.controller,
    required this.onViewPayment,
  });

  final PosController controller;
  final VoidCallback onViewPayment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.cart.length} produk',
                    style: AppTheme.labelCaps,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(controller.total),
                    style: AppTheme.priceDisplay.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: controller.cart.isEmpty ? null : onViewPayment,
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionPane extends StatelessWidget {
  const _TransactionPane({required this.controller});

  final PosController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('RINGKASAN ORDER', style: AppTheme.labelCaps),
                ),
                IconButton(
                  onPressed: controller.clearCart,
                  tooltip: 'Kosongkan keranjang',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            Expanded(
              child: controller.cart.isEmpty
                  ? const Center(child: Text('Keranjang masih kosong'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: controller.cart.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = controller.cart[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${CurrencyFormatter.format(item.product.price)} × ${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  controller.decrementQuantity(item),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            IconButton(
                              onPressed: () =>
                                  controller.incrementQuantity(item),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const Divider(),
            _SummaryRow(
              label: 'Subtotal',
              value: CurrencyFormatter.format(controller.subtotal),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: controller.discountAmount.value == 0
                  ? ''
                  : controller.discountAmount.value.toString(),
              onChanged: controller.setDiscountFromInput,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Diskon transaksi',
                helperText:
                    'Maksimum ${CurrencyFormatter.format(controller.maxDiscountAmount)}',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<PaymentMethod>(
              segments: const [
                ButtonSegment(
                  value: PaymentMethod.cash,
                  label: Text('Cash'),
                  icon: Icon(Icons.payments_outlined),
                ),
                ButtonSegment(
                  value: PaymentMethod.qrisStatic,
                  label: Text('QRIS'),
                  icon: Icon(Icons.qr_code_2),
                ),
                ButtonSegment(
                  value: PaymentMethod.mixed,
                  label: Text('Campur'),
                  icon: Icon(Icons.call_split),
                ),
              ],
              selected: {controller.paymentMethod.value},
              onSelectionChanged: (selection) =>
                  controller.setPaymentMethod(selection.first),
            ),
            const SizedBox(height: 16),
            ..._paymentFields(controller),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Total',
              value: CurrencyFormatter.format(controller.total),
              emphasized: true,
            ),
            if (controller.paymentMethod.value != PaymentMethod.qrisStatic) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: 'Cash dibayar',
                value: CurrencyFormatter.format(controller.cashReceived.value),
              ),
              _SummaryRow(
                label: 'Kembalian',
                value: CurrencyFormatter.format(controller.change),
              ),
            ] else ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: 'QRIS diterima',
                value: CurrencyFormatter.format(controller.qrisReceived.value),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: controller.canCheckout
                  ? () async {
                      final result = await controller.checkout();
                      if (result == null) return;

                      Get.dialog(
                        AlertDialog(
                          title: const Text('Transaksi Berhasil'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No. Struk: ${result.receiptNumber}'),
                              Text('Metode: ${result.paymentLabel}'),
                              Text('Kembalian: Rp ${result.change}'),
                            ],
                          ),
                          actions: [
                            FilledButton(
                              onPressed: () => Get.back<void>(),
                              child: const Text('Bagikan Struk'),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                controller.isProcessing.value ? 'MEMPROSES' : 'BAYAR SEKARANG',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _paymentFields(PosController controller) {
    return switch (controller.paymentMethod.value) {
      PaymentMethod.cash => [
        TextFormField(
          initialValue: controller.cashReceived.value == 0
              ? ''
              : controller.cashReceived.value.toString(),
          onChanged: controller.setCashFromInput,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Uang diterima',
            prefixText: 'Rp ',
            suffixIcon: TextButton(
              onPressed: controller.useExactCash,
              child: const Text('Exact'),
            ),
          ),
        ),
      ],
      PaymentMethod.qrisStatic => [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 120),
                const SizedBox(height: 8),
                const Text(
                  'Tampilkan QRIS statis merchant',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: controller.qrisReceived.value == 0
                      ? ''
                      : controller.qrisReceived.value.toString(),
                  onChanged: controller.setQrisFromInput,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nominal diterima',
                    prefixText: 'Rp ',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      PaymentMethod.mixed => [
        TextFormField(
          initialValue: controller.qrisReceived.value == 0
              ? ''
              : controller.qrisReceived.value.toString(),
          onChanged: controller.setQrisFromInput,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bagian QRIS',
            prefixText: 'Rp ',
            helperText: 'Sisa dibayar tunai',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: controller.cashReceived.value == 0
              ? ''
              : controller.cashReceived.value.toString(),
          onChanged: controller.setCashFromInput,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Bagian cash',
            prefixText: 'Rp ',
            helperText: 'Harus ${CurrencyFormatter.format(controller.cashDue)}',
            suffixIcon: TextButton(
              onPressed: controller.useExactCash,
              child: const Text('Exact'),
            ),
          ),
        ),
      ],
    };
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: emphasized
              ? const TextStyle(fontWeight: FontWeight.w600)
              : const TextStyle(color: AppColors.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: emphasized
              ? AppTheme.priceDisplay.copyWith(fontSize: 24)
              : const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
