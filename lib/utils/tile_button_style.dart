import 'package:flutter/material.dart';

class TileButtonStyle {
  static ButtonStyle getTileStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    double borderRadius = 16.0,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
