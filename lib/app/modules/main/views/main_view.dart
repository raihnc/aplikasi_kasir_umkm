import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/views/home_view.dart';
import '../../inventory/views/inventory_view.dart';
import '../../pos/views/pos_view.dart';
import '../../product/views/product_view.dart';
import '../../reports/views/reports_view.dart';
import '../../settings/views/settings_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const _destinations = [
    _Destination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _Destination(
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      label: 'Kasir',
    ),
    _Destination(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Produk',
    ),
    _Destination(
      icon: Icons.local_shipping_outlined,
      selectedIcon: Icons.local_shipping,
      label: 'Stok',
    ),
    _Destination(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: 'Laporan',
    ),
    _Destination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Pengaturan',
    ),
  ];

  static const _pages = [
    HomeView(),
    PosView(),
    ProductView(),
    InventoryView(),
    ReportsView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final selectedIndex = controller.currentIndex.value;
          final width = MediaQuery.sizeOf(context).width;

          if (width >= 1100) {
            return Row(
              children: [
                _Sidebar(
                  controller: controller,
                  selectedIndex: selectedIndex,
                  destinations: _destinations,
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(child: _pages[selectedIndex]),
              ],
            );
          }

          if (width >= 760) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: controller.changePage,
                  labelType: NavigationRailLabelType.all,
                  leading: const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 20),
                    child: Icon(Icons.storefront, color: AppColors.primary),
                  ),
                  destinations: [
                    for (final destination in _destinations)
                      NavigationRailDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: Text(destination.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, color: AppColors.divider),
                Expanded(child: _pages[selectedIndex]),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: _pages[selectedIndex]),
              NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: controller.changePage,
                destinations: [
                  for (final destination in _destinations)
                    NavigationDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.selectedIcon),
                      label: destination.label,
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.controller,
    required this.selectedIndex,
    required this.destinations,
  });

  final MainController controller;
  final int selectedIndex;
  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Aurelian POS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < destinations.length; index++)
            _SidebarItem(
              destination: destinations[index],
              isSelected: selectedIndex == index,
              onTap: () => controller.changePage(index),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final _Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? AppColors.gold
        : AppColors.surface.withValues(alpha: .68);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected
            ? AppColors.surface.withValues(alpha: .08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: isSelected ? AppColors.gold : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  color: foreground,
                ),
                const SizedBox(width: 14),
                Text(
                  destination.label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
