import 'package:flutter/material.dart';
import '../tts_controller.dart';
import '../tile_size.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _rate;
  late double _pitch;
  late double _volume;
  late bool _useDefaultVoice;
  Map<String, String>? _selectedVoice;
  List<Map<String, String>> _availableVoices = [];
  bool _loadingVoices = true;

  @override
  void initState() {
    super.initState();
    final tts = TtsController.instance;
    _rate = tts.rate;
    _pitch = tts.pitch;
    _volume = tts.volume;
    _useDefaultVoice = tts.useDefaultVoice;
    _selectedVoice = tts.selectedVoice;
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    final voices = await TtsController.instance.getVoices();
    setState(() {
      _availableVoices = voices;
      _loadingVoices = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
        children: [
          const Text(
            'Display Size',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Adjust tile and text sizes for better visibility'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => TileSizeController.showSizeSheet(context),
                    icon: const Icon(Icons.tune),
                    label: const Text('Adjust Display Size'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Text-to-Speech',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Use System Default Voice'),
                    subtitle: Text(
                      _useDefaultVoice 
                        ? 'Using device default voice (always available offline)'
                        : 'Using selected voice (may require internet)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    value: _useDefaultVoice,
                    onChanged: (value) async {
                      setState(() => _useDefaultVoice = value);
                      await TtsController.instance.setUseDefaultVoice(value);
                    },
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Speech Rate', style: TextStyle(fontSize: 16)),
                      Text(
                        '${(_rate * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _rate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    onChanged: (value) async {
                      setState(() => _rate = value);
                      await TtsController.instance.updateRate(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pitch', style: TextStyle(fontSize: 16)),
                      Text(
                        '${(_pitch * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    onChanged: (value) async {
                      setState(() => _pitch = value);
                      await TtsController.instance.updatePitch(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Volume', style: TextStyle(fontSize: 16)),
                      Text(
                        '${(_volume * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) async {
                      setState(() => _volume = value);
                      await TtsController.instance.updateVolume(value);
                    },
                  ),
                  if (!_useDefaultVoice) ...[
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Voice', style: TextStyle(fontSize: 16)),
                        ),
                        TextButton(
                          onPressed: () => _showVoiceSelector(),
                          child: Text(
                            _selectedVoice != null && _selectedVoice!.isNotEmpty
                                ? _selectedVoice!['name'] ?? 'Select Voice'
                                : 'Select Voice',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Voice selection depends on TTS engines installed on your device',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await TtsController.instance.speak('Hello, this is a test of the text to speech voice.');
                      },
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Test Voice'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showVoiceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Select Voice',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingVoices)
                        const CircularProgressIndicator()
                      else if (_availableVoices.isEmpty)
                        Column(
                          children: [
                            const Icon(Icons.info_outline, size: 48, color: Colors.orange),
                            const SizedBox(height: 16),
                            const Text(
                              'No additional voices found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your device is using the default system voice. To add more voices:',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '1. Go to device Settings\n2. Find "Text-to-Speech" or "Language & Input"\n3. Install additional TTS engines (e.g., Google Text-to-Speech)\n4. Download voice data packs',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Available voices (${_availableVoices.length})',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (!_loadingVoices && _availableVoices.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _availableVoices.length,
                      itemBuilder: (context, index) {
                        final voice = _availableVoices[index];
                        final isSelected = _selectedVoice?['name'] == voice['name'];
                        
                        return ListTile(
                          leading: Icon(
                            isSelected ? Icons.check_circle : Icons.record_voice_over,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            voice['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${voice['locale'] ?? ''}'.toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () async {
                              await TtsController.instance.setVoice(voice);
                              await TtsController.instance.speak('Hello, this is a test.');
                            },
                          ),
                          selected: isSelected,
                          onTap: () async {
                            await TtsController.instance.setVoice(voice);
                            setState(() => _selectedVoice = voice);
                            if (mounted) Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}