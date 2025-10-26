import "package:shared_preferences/shared_preferences.dart";

/// Persist/restore the selected sub-category per tile.
/// key:  tileSub:<tileKey>
/// val:  <subCategoryKey>
class SubcategoryPrefs {
  static SharedPreferences? _prefs;
  static const _prefix = "tileSub:";

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setSelected(String tileKey, String subKey) async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    await p.setString("$_prefix$tileKey", subKey);
  }

  static Future<String?> getSelected(String tileKey) async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    return p.getString("$_prefix$tileKey");
  }

  /// Synchronous read (valid after init()).
  static String? getSelectedSync(String tileKey) {
    return _prefs?.getString("$_prefix$tileKey");
  }

  static Future<void> clearTile(String tileKey) async {
    final p = _prefs ??= await SharedPreferences.getInstance();
    await p.remove("$_prefix$tileKey");
  }
}
