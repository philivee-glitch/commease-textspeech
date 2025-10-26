import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TtsController {
  TtsController._();
  static final TtsController instance = TtsController._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  // Settings keys
  static const String _keyRate = 'tts_rate';
  static const String _keyPitch = 'tts_pitch';
  static const String _keyVolume = 'tts_volume';
  static const String _keyVoice = 'tts_voice';
  static const String _keyUseDefaultVoice = 'tts_use_default_voice';

  double rate = 0.5;
  double pitch = 1.0;
  double volume = 1.0;
  Map<String, String>? selectedVoice;
  bool useDefaultVoice = false;

  Future<void> init() async {
    if (_initialized) return;
    
    await _tts.awaitSpeakCompletion(true);
    await loadSettings();
    await _applySettings();
    _initialized = true;
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      rate = prefs.getDouble(_keyRate) ?? 0.5;
      pitch = prefs.getDouble(_keyPitch) ?? 1.0;
      volume = prefs.getDouble(_keyVolume) ?? 1.0;
      useDefaultVoice = prefs.getBool(_keyUseDefaultVoice) ?? false;
      
      final voiceName = prefs.getString(_keyVoice);
      if (voiceName != null && !useDefaultVoice) {
        final voices = await getVoices();
        selectedVoice = voices.firstWhere(
          (v) => v['name'] == voiceName,
          orElse: () => {},
        );
      }
    } catch (_) {}
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyRate, rate);
      await prefs.setDouble(_keyPitch, pitch);
      await prefs.setDouble(_keyVolume, volume);
      await prefs.setBool(_keyUseDefaultVoice, useDefaultVoice);
      if (selectedVoice != null && selectedVoice!.isNotEmpty) {
        await prefs.setString(_keyVoice, selectedVoice!['name']!);
      }
    } catch (_) {}
  }

  Future<void> _applySettings() async {
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setVolume(volume);
    
    if (useDefaultVoice) {
      // Use system default voice
      await _tts.setVoice({});
    } else if (selectedVoice != null && selectedVoice!.isNotEmpty) {
      // Use selected voice
      try {
        await _tts.setVoice(selectedVoice!);
      } catch (_) {
        // Voice not available
      }
    }
  }

  Future<void> setUseDefaultVoice(bool value) async {
    useDefaultVoice = value;
    await _applySettings();
    await saveSettings();
  }

  Future<List<Map<String, String>>> getVoices() async {
    try {
      final voices = await _tts.getVoices as List<dynamic>;
      return voices.map((v) => Map<String, String>.from(v as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> setVoice(Map<String, String>? voice) async {
    selectedVoice = voice;
    if (!useDefaultVoice && voice != null && voice.isNotEmpty) {
      try {
        await _tts.setVoice(voice);
      } catch (_) {}
    }
    await saveSettings();
  }

  Future<void> updateRate(double newRate) async {
    rate = newRate;
    await _tts.setSpeechRate(rate);
    await saveSettings();
  }

  Future<void> updatePitch(double newPitch) async {
    pitch = newPitch;
    await _tts.setPitch(pitch);
    await saveSettings();
  }

  Future<void> updateVolume(double newVolume) async {
    volume = newVolume;
    await _tts.setVolume(volume);
    await saveSettings();
  }

  Future<void> speak(String text) async {
    if (!_initialized) await init();
    
    // Remove emojis before speaking
    final cleanText = _removeEmojis(text);
    
    if (cleanText.trim().isEmpty) return; // Don't speak if only emojis
    
    await _tts.speak(cleanText);
  }

  String _removeEmojis(String text) {
    // Remove emojis using regex that matches emoji unicode ranges
    return text.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F000}-\u{1F02F}]|[\u{1F0A0}-\u{1F0FF}]|[\u{1F100}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F910}-\u{1F96B}]|[\u{1F980}-\u{1F9E0}]',
        unicode: true,
      ),
      '',
    ).trim();
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}