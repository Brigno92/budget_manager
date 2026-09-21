/// Formats [date] as an Italian-style `dd/MM/yyyy` string.
String formatItalianDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
