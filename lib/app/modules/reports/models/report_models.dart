class ReportSummary {
  const ReportSummary({
    required this.revenue,
    required this.transactions,
    required this.grossProfit,
    required this.itemsSold,
  });

  final int revenue;
  final int transactions;
  final int grossProfit;
  final int itemsSold;

  int get averageBasket => transactions == 0 ? 0 : revenue ~/ transactions;
}

class TopProduct {
  const TopProduct({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final int quantity;
  final int revenue;
}

class PaymentBreakdown {
  const PaymentBreakdown({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final String color;
}
