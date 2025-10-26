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

  Future<void> _saveWords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(StoreKeys.words(widget.categoryKey), _words);
    } catch (_) {}
  }

  Future<void> _loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imageMapJson = prefs.getString(StoreKeys.wordImages(widget.categoryKey));
      if (imageMapJson != null) {
        final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          Uri.splitQueryString(imageMapJson),
        );
        setState(() {
          _wordImages = decoded.map((k, v) => MapEntry(k, v.toString()));
        });
      }
    } catch (_) {}
  }

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simple encoding: word1=path1&word2=path2
      final encoded = _wordImages.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
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

      // Save as JPEG with 85% quality
      final jpegBytes = img.encodeJpg(resized, quality: 85);

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/word_images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${widget.categoryKey}_${word.replaceAll(RegExp(r'[^\w\s]'), '_')}.jpg';
      final savedFile = File('${imagesDir.path}/$fileName');
      await savedFile.writeAsBytes(jpegBytes);

      setState(() {
        _wordImages[word] = savedFile.path;
      });
      await _saveImages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image added successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding image: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _removeImage(String word) async {
    try {
      final imagePath = _wordImages[word];
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
        setState(() {
          _wordImages.remove(word);
        });
        await _saveImages();
      }
    } catch (_) {}
  }

  void _showImageOptions(String word) {
    final hasImage = _wordImages.containsKey(word);

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.image),
                  title: Text(hasImage ? 'Change Image' : 'Add Image'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndSaveImage(word);
                  },
                ),
                if (hasImage)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Remove Image'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeImage(word);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: const Text('Delete Word'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteWord(word);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addWord() {
    String word = '';

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
                'Add Word/Phrase',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'to ${widget.categoryDisplay}',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                onChanged: (v) => word = v,
                maxLines: 3,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Word or phrase',
                  hintText: 'e.g., I would like some water',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.chat_bubble_outline),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final t = word.trim();
                        if (t.isEmpty) {
                          Navigator.pop(ctx);
                          return;
                        }
                        setState(() {
                          _words.add(t);
                        });
                        await _saveWords();
                        if (mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteWord(String word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this word/phrase?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      word,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _removeImage(word);
              setState(() {
                _words.remove(word);
              });
              await _saveWords();
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Word deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<double>(
                valueListenable: TileSizeController.instance.gridScale,
                builder: (context, gridScaleValue, __) => GridView.builder(
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
                          TtsController.instance.speak(word);
                          setState(() => _selectedWords.add(word));
                        },
                        child: ValueListenableBuilder<double>(
                          valueListenable: TileSizeController.instance.scale,
                          builder: (context, textScaleValue, child) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                if (hasImage) {
                                  // Display image with text below
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Image.file(
                                          File(imagePath),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        flex: 1,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            word,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 14 * textScaleValue,
                                              fontWeight: FontWeight.w600,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Text-only tile
                                  final textPainter = TextPainter(
                                    text: TextSpan(
                                      text: word,
                                      style: TextStyle(
                                        fontSize: 16 * textScaleValue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    maxLines: 2,
                                    textDirection: TextDirection.ltr,
                                  )..layout(maxWidth: constraints.maxWidth);

                                  if (textPainter.didExceedMaxLines) {
                                    return FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        child: Text(
                                          word,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontSize: 16 * textScaleValue,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Text(
                                        word,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16 * textScaleValue,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              color: cs.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedWords.join(' '),
                      style: const TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => TtsController.instance.speak(_selectedWords.join(' ')),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _selectedWords.clear()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}