class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');

    for (var index = 0; index < digits.length; index++) {
      buffer.write(digits[index]);
      final remaining = digits.length - index - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return 'Rp $buffer';
  }
}
