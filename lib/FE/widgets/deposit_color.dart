import 'package:flutter/material.dart';

/// Parses a [Deposit.color] string such as `'#3F51B5'`, `'3F51B5'` or an
/// 8-digit ARGB hex string into a [Color].
///
/// Falls back to [Colors.grey] for anything that isn't valid hex, since the
/// database does not constrain the format of this column.
Color parseDepositColor(String raw) {
  var hex = raw.trim();
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 6) hex = 'FF$hex';

  final value = hex.length == 8 ? int.tryParse(hex, radix: 16) : null;
  if (value == null) {
    debugPrint('Invalid deposit color "$raw", falling back to grey.');
    return Colors.grey;
  }
  return Color(value);
}

/// Encodes [color] as the `#RRGGBB` hex string [Deposit.color] expects.
///
/// The alpha channel is dropped: a deposit's color is always shown opaque.
String encodeDepositColor(Color color) {
  final r = (color.r * 255).round().clamp(0, 255);
  final g = (color.g * 255).round().clamp(0, 255);
  final b = (color.b * 255).round().clamp(0, 255);
  final hex = ((r << 16) | (g << 8) | b)
      .toRadixString(16)
      .padLeft(6, '0')
      .toUpperCase();
  return '#$hex';
}
