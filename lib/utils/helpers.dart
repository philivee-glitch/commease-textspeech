import 'package:flutter/material.dart';

/// Convert string to storage key format
String keyize(String s) => s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');

/// Compose a compound key from parent and child
String composeKey(String parent, String child) => '${keyize(parent)}|${keyize(child)}';

/// Convert string to title case
String titleCase(String s) {
  if (s.isEmpty) return s;
  // Special case for Yes / No
  if (s.toLowerCase() == 'yes / no') return 'Yes / No';
  return s[0].toUpperCase() + s.substring(1);
}

/// Calculate appropriate text color for background
Color onColor(Color bg, Brightness brightness) {
  final lum = 0.299 * bg.red + 0.587 * bg.green + 0.114 * bg.blue;
  return lum > 160 ? Colors.black : Colors.white;
}

/// Get icon for tile label
IconData iconFor(String label) {
  switch (label.toLowerCase()) {
    case 'yes / no':
      return Icons.thumbs_up_down;
    case 'needs':
      return Icons.list_alt;
    case 'feelings':
      return Icons.emoji_emotions;
    case 'food':
      return Icons.restaurant;
    case 'places':
      return Icons.place;
    case 'people':
      return Icons.people;
    case 'i want':
      return Icons.check_circle;
    case 'help':
      return Icons.help;
    case 'stop':
      return Icons.stop;
    case 'go':
      return Icons.play_arrow;
    case 'toilet':
      return Icons.wc;
    case 'drink':
      return Icons.local_drink;
    case 'eat':
      return Icons.fastfood;
    case 'sleep':
      return Icons.hotel;
    case 'pain':
      return Icons.healing;
    default:
      return Icons.category;
  }
}