import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../constants/storage_keys.dart';
import '../tts_controller.dart';
import '../tile_size.dart';
import '../widgets/large_back_button.dart';

class WordLibraryScreen extends StatefulWidget {
  final String categoryDisplay;
  final String categoryKey;
  final List<String> initialWords;

  const WordLibraryScreen({
    super.key,
    required this.categoryDisplay,
    required this.categoryKey,
    required this.initialWords,
  });

  @override
  State<WordLibraryScreen> createState() => _WordLibraryScreenState();
}

class _WordLibraryScreenState extends State<WordLibraryScreen> {
  List<String> _words = [];
  final List<String> _selectedWords = [];
  Map<String, String> _wordImages = {}; // Maps word -> image path

  @override
  void initState() {
    super.initState();
    _loadWords();
    _loadImages();
  }

  Future<void> _loadWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(StoreKeys.words(widget.categoryKey));
      setState(() {
        _words = stored ?? List<String>.from(widget.initialWords);
      });
    } catch (_) {
      setState(() => _words = List<String>.from(widget.initialWords));
    }
  }

  Future<void> _loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(StoreKeys.wordImages(widget.categoryKey));
      if (stored != null && stored.isNotEmpty) {
        final Map<String, dynamic> decoded = {};
        stored.split('|||').forEach((entry) {
          final parts = entry.split(':::');
          if (parts.length == 2) decoded[parts[0]] = parts[1];
        });
        setState(() {
          _wordImages = decoded.cast<String, String>();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(StoreKeys.words(widget.categoryKey), _words);
    } catch (_) {}
  }

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _wordImages.entries
          .map((e) => '${e.key}:::${e.value}')
          .join('|||');
      await prefs.setString(StoreKeys.wordImages(widget.categoryKey), encoded);
    } catch (_) {}
  }

  Future<void> _pickAndSaveImage(String word) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.first.path!);
      if (!await file.exists()) return;

      // Load and resize image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return;

      // Resize and crop to 4:3 aspect ratio
      final targetWidth = 400;
      final targetHeight = 300; // 4:3 ratio

      img.Image resized;

      // Calculate the scale needed to cover the target dimensions
      final scaleX = targetWidth / image.width;
      final scaleY = targetHeight / image.height;
      final scale = scaleX > scaleY ? scaleX : scaleY;

      // Resize image to cover target dimensions
      final scaledWidth = (image.width * scale).round();
      final scaledHeight = (image.height * scale).round();
      final temp = img.copyResize(image, width: scaledWidth, height: scaledHeight);

      // Crop from center to exact 4:3 ratio
      final x = (temp.width - targetWidth) ~/ 2;
      final y = (temp.height - targetHeight) ~/ 2;
      resized = img.copyCrop(temp, x: x, y: y, width: targetWidth, height: targetHeight);

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'word_${widget.categoryKey}_${word.replaceAll(RegExp(r'[^\w\s]+'), '')}_$timestamp.jpg';
      final savedFile = File('${appDir.path}/$fileName');
      await savedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

      setState(() {
        _wordImages[word] = savedFile.path;
      });
      await _saveImages();
    } catch (_) {}
  }

  Future<void> _removeImage(String word) async {
    try {
      final imagePath = _wordImages[word];
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _wordImages.remove(word);
      });
      await _saveImages();
    } catch (_) {}
  }

  void _showImageOptions(String word) {
    final hasImage = _wordImages.containsKey(word);
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(hasImage ? Icons.edit : Icons.add_photo_alternate),
              title: Text(hasImage ? 'Change Image' : 'Add Image'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSaveImage(word);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeImage(word);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Word'),
              onTap: () {
                Navigator.pop(ctx);
                _editWord(word);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Word'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteWord(word);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _editWord(String oldWord) {
    String newWord = oldWord;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final keyboardPadding = MediaQuery.of(ctx).viewInsets.bottom;
        final systemNavPadding = MediaQuery.of(ctx).padding.bottom;
        
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: keyboardPadding + systemNavPadding + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Word/Phrase',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: oldWord),
                decoration: const InputDecoration(
                  labelText: 'Word or Phrase',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => newWord = val.trim(),
                onSubmitted: (_) {
                  if (newWord.isNotEmpty && newWord != oldWord) {
                    final index = _words.indexOf(oldWord);
                    if (index != -1) {
                      setState(() {
                        _words[index] = newWord;
                        if (_wordImages.containsKey(oldWord)) {
                          _wordImages[newWord] = _wordImages[oldWord]!;
                          _wordImages.remove(oldWord);
                        }
                      });
                      _saveWords();
                      _saveImages();
                    }
                  }
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (newWord.isNotEmpty && newWord != oldWord) {
                    final index = _words.indexOf(oldWord);
                    if (index != -1) {
                      setState(() {
                        _words[index] = newWord;
                        if (_wordImages.containsKey(oldWord)) {
                          _wordImages[newWord] = _wordImages[oldWord]!;
                          _wordImages.remove(oldWord);
                        }
                      });
                      _saveWords();
                      _saveImages();
                    }
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteWord(String word) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Word'),
        content: Text('Delete "$word"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _words.remove(word);
                _removeImage(word);
              });
              _saveWords();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addWord() {
    String word = '';
    String? tempImagePath;

    Future<void> pickImage(StateSetter setModalState) async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result == null || result.files.isEmpty) return;

        final file = File(result.files.first.path!);
        if (!await file.exists()) return;

        // Load and resize image
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) return;

        // Resize and crop to 4:3 aspect ratio
        final targetWidth = 400;
        final targetHeight = 300;

        img.Image resized;
        final scaleX = targetWidth / image.width;
        final scaleY = targetHeight / image.height;
        final scale = scaleX > scaleY ? scaleX : scaleY;

        final scaledWidth = (image.width * scale).round();
        final scaledHeight = (image.height * scale).round();
        final temp = img.copyResize(image, width: scaledWidth, height: scaledHeight);

        final x = (temp.width - targetWidth) ~/ 2;
        final y = (temp.height - targetHeight) ~/ 2;
        resized = img.copyCrop(temp, x: x, y: y, width: targetWidth, height: targetHeight);

        // Save to temp location
        final appDir = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'temp_word_$timestamp.jpg';
        final savedFile = File('${appDir.path}/$fileName');
        await savedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

        setModalState(() {
          tempImagePath = savedFile.path;
        });
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final keyboardPadding = MediaQuery.of(ctx).viewInsets.bottom;
        final systemNavPadding = MediaQuery.of(ctx).padding.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: keyboardPadding + systemNavPadding + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Word/Phrase',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'to ${widget.categoryDisplay}',
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (tempImagePath != null) ...[
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(ctx).colorScheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(tempImagePath!),
                          key: ValueKey(tempImagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        setModalState(() {
                          if (tempImagePath != null) {
                            File(tempImagePath!).delete();
                            tempImagePath = null;
                          }
                        });
                      },
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Remove Image'),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    OutlinedButton.icon(
                      onPressed: () => pickImage(setModalState),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Image (Optional)'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    autofocus: false,
                    decoration: const InputDecoration(
                      labelText: 'Word or Phrase',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => word = val.trim(),
                    onSubmitted: (_) {
                      if (word.isNotEmpty) {
                        setState(() => _words.add(word));
                        _saveWords();
                        if (tempImagePath != null) {
                          _wordImages[word] = tempImagePath!;
                          _saveImages();
                        }
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (word.isNotEmpty) {
                        setState(() => _words.add(word));
                        _saveWords();
                        if (tempImagePath != null) {
                          _wordImages[word] = tempImagePath!;
                          _saveImages();
                        }
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add Word'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteSelected() {
    if (_selectedWords.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Words'),
        content: Text(
          'Delete ${_selectedWords.length} selected word(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                for (final word in _selectedWords) {
                  _words.remove(word);
                  _removeImage(word);
                }
                _selectedWords.clear();
              });
              _saveWords();
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: const LargeBackButton(),
        title: Text(widget.categoryDisplay),
        actions: [
          IconButton(
            tooltip: 'Add Word',
            icon: const Icon(Icons.add),
            onPressed: _addWord,
          ),
        ],
      ),
      floatingActionButton: _selectedWords.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete),
              label: Text('Delete ${_selectedWords.length}'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: TileSizeController.instance.gridScale,
                builder: (context, gridScaleValue, __) => ValueListenableBuilder<double>(
                  valueListenable: TileSizeController.instance.scale,
                  builder: (context, textScaleValue, __) => GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180 * gridScaleValue,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _words.length,
                    itemBuilder: (context, index) {
                      final word = _words[index];
                      final imagePath = _wordImages[word];
                      final hasImage = imagePath != null && File(imagePath).existsSync();

                      return GestureDetector(
                        onLongPress: () => _showImageOptions(word),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () {
                            if (_selectedWords.isEmpty) {
                              TtsController.instance.speak(word);
                            } else {
                              setState(() {
                                if (_selectedWords.contains(word)) {
                                  _selectedWords.remove(word);
                                } else {
                                  _selectedWords.add(word);
                                }
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              if (hasImage)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Image.file(
                                        File(imagePath),
                                        key: ValueKey(imagePath),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        word,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14 * textScaleValue),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Center(
                                  child: Text(
                                    word,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16 * textScaleValue),
                                  ),
                                ),
                              if (_selectedWords.contains(word))
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: cs.onPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}