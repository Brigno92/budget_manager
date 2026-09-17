import 'package:flutter/material.dart';

/// A small square swatch of [color] with a black border, used to preview a
/// deposit's color both in its table row and in its edit form.
class ColorPreviewBox extends StatelessWidget {
  final Color color;
  final double size;

  const ColorPreviewBox({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
    );
  }
}
