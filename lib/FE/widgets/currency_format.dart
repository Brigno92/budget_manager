/// Formats [value] as an Italian-style currency amount, e.g. `1234` becomes
/// `'€ 1.234'`.
String formatEuroAmount(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return '${isNegative ? '-' : ''}€ $buffer';
}
