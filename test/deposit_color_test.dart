import 'package:budget_manager/FE/widgets/deposit_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDepositColor', () {
    test('parses a 6-digit hex string with a leading #', () {
      expect(parseDepositColor('#3F51B5'), const Color(0xFF3F51B5));
    });

    test('parses a 6-digit hex string without a leading #', () {
      expect(parseDepositColor('3F51B5'), const Color(0xFF3F51B5));
    });

    test('falls back to grey for invalid input', () {
      expect(parseDepositColor('not-a-color'), Colors.grey);
    });
  });

  group('encodeDepositColor', () {
    test('round-trips through parseDepositColor', () {
      const color = Color(0xFF3F51B5);
      expect(parseDepositColor(encodeDepositColor(color)), color);
    });

    test('produces an uppercase 6-digit hex string with a leading #', () {
      expect(encodeDepositColor(const Color(0xFF3F51B5)), '#3F51B5');
    });
  });
}
