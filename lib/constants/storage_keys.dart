/// Storage keys for SharedPreferences
class StoreKeys {
  static const acceptedTerms = 'has_accepted_terms';
  static const ttsRate = 'tts_rate';
  static const history = 'history';
  static const favs = 'favs';
  static const homeCustomQuick = 'home:custom_quick';
  static const homeCustomCats = 'home:custom_categories';
  static const homeColourMap = 'home:colour_map';
  static const backupNamespace = 'backup:v2';
  static String subcats(String parentRaw) => 'subcats:${_keyize(parentRaw)}';
  static String words(String catKey) => 'words:$catKey';
  static String wordImages(String catKey) => 'word_images:$catKey';
  static String _keyize(String s) => s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '_');
}