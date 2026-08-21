import 'package:flutter/material.dart';

class DashboardMetric {
  const DashboardMetric({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.isPositive,
  });

  final String label;
  final String value;
  final String change;
  final IconData icon;
  final bool isPositive;
}

class LowStockProduct {
  const LowStockProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.remainingStock,
    required this.minimumStock,
  });

  final String id;
  final String name;
  final String sku;
  final int remainingStock;
  final int minimumStock;

  int get shortage => minimumStock - remainingStock;
}

class RecentSale {
  const RecentSale({
    required this.receiptNumber,
    required this.customerName,
    required this.time,
    required this.total,
    required this.paymentMethod,
  });

  final String receiptNumber;
  final String customerName;
  final String time;
  final String total;
  final String paymentMethod;
}

enum QuickActionType { newSale, scanProduct, addProduct, openReport }

class QuickAction {
  const QuickAction({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final QuickActionType type;
  final String title;
  final String subtitle;
  final IconData icon;
}
