import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Voice choices shown in the settings sheet.
enum TtsVoicePreset { system, male, female, child }

/// Singleton controller used by the app and settings sheet.
class TtsController {
  TtsController._();
  static final TtsController instance = TtsController._();

  final FlutterTts _tts = FlutterTts();

  double rate = 0.6;  // 0.1–1.0
  double pitch = 1.0; // 0.5–2.0
  TtsVoicePreset preset = TtsVoicePreset.system;

  List<Map<String, dynamic>> _voices = [];
  Map<String, dynamic>? _selectedVoice;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    rate  = prefs.getDouble('tts_rate')  ?? 0.6;
    pitch = prefs.getDouble('tts_pitch') ?? 1.0;
    final presetStr = prefs.getString('tts_preset') ?? 'system';
    preset = TtsVoicePreset.values.firstWhere(
      (e) => e.name == presetStr,
      orElse: () => TtsVoicePreset.system,
    );

    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setSharedInstance(true); // iOS safety

    final v = await _tts.getVoices;
    if (v is List) {
      _voices = v
          .cast<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    if (preset != TtsVoicePreset.system) {
      await _selectVoiceForPreset(preset);
    }
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    if (preset != TtsVoicePreset.system) {
      await _selectVoiceForPreset(preset);
    }
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();

  Future<void> setRate(double newRate) async {
    rate = newRate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(rate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_rate', rate);
  }

  Future<void> setPitch(double newPitch) async {
    pitch = newPitch.clamp(0.5, 2.0);
    await _tts.setPitch(pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tts_pitch', pitch);
  }

  Future<void> setPreset(TtsVoicePreset p) async {
    preset = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tts_preset', p.name);
    if (p != TtsVoicePreset.system) {
      await _selectVoiceForPreset(p);
    } else {
      _selectedVoice = null;
    }
  }

  Future<void> _selectVoiceForPreset(TtsVoicePreset p) async {
  // If “system”, don’t force a voice.
  if (p == TtsVoicePreset.system) return;
  if (_voices.isEmpty) return;

  String want = switch (p) {
    TtsVoicePreset.female => 'female',
    TtsVoicePreset.male   => 'male',
    TtsVoicePreset.child  => 'child',
    _                     => '',
  };

  Map<String, dynamic> pick;

  bool matches(Map<String, dynamic> m) {
    final gender = (m['gender'] ?? '').toString().toLowerCase();
    final name   = (m['name']   ?? '').toString().toLowerCase();

    // 1) Prefer a real gender field if present
    if (gender.contains(want)) return true;

    // 2) Otherwise try to infer from the voice name
    if (want == 'female' &&
        (name.contains('female') || name.contains('woman') || name.contains('girl'))) {
      return true;
    }
    if (want == 'male' &&
        (name.contains('male') || name.contains('man') || name.contains('boy'))) {
      return true;
    }
    if (want == 'child' &&
        (name.contains('child') || name.contains('kid') || name.contains('boy') || name.contains('girl'))) {
      return true;
    }
    return false;
  }

  try {
    pick = _voices.firstWhere(matches);
  } catch (_) {
    // Fallback to the first available voice
    pick = _voices.first;
  }

  _selectedVoice = pick;

  // flutter_tts expects a {name, locale} map
  final name   = (pick['name']   ?? '').toString();
  final locale = (pick['locale'] ?? pick['language'] ?? '').toString();

  if (name.isNotEmpty && locale.isNotEmpty) {
    await _tts.setVoice({'name': name, 'locale': locale});
  }
} // <- closes setExactVoice
} // <- closes class TtsController  (this was missing)

