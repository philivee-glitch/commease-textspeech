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
import 'word_library_screen.dart';

class SubcategoryMenuScreen extends StatefulWidget {
  final String parentCategoryDisplay;
  final String parentCategoryKey;
  final List<Map<String, dynamic>> subcategories;

  const SubcategoryMenuScreen({
    super.key,
    required this.parentCategoryDisplay,
    required this.parentCategoryKey,
    required this.subcategories,
  });

  @override
  State<SubcategoryMenuScreen> createState() => _SubcategoryMenuScreenState();
}

class _SubcategoryMenuScreenState extends State<SubcategoryMenuScreen> {
  List<String> _customTiles = [];
  Map<String, String> _tileImages = {}; // Maps tile name -> image path

  @override
  void initState() {
    super.initState();
    _loadCustomTiles();
    _loadImages();
  }

  String get _tilesKey => 'custom_tiles_${widget.parentCategoryKey}';

  Future<void> _loadCustomTiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_tilesKey);
      setState(() {
        _customTiles = stored ?? [];
      });
    } catch (_) {}
  }

  Future<void> _loadImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('${_tilesKey}_images');
      if (stored != null && stored.isNotEmpty) {
        final Map<String, dynamic> decoded = {};
        stored.split('|||').forEach((entry) {
          final parts = entry.split(':::');
          if (parts.length == 2) decoded[parts[0]] = parts[1];
        });
        setState(() {
          _tileImages = decoded.cast<String, String>();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveCustomTiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_tilesKey, _customTiles);
    } catch (_) {}
  }

  Future<void> _saveImages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _tileImages.entries
          .map((e) => '${e.key}:::${e.value}')
          .join('|||');
      await prefs.setString('${_tilesKey}_images', encoded);
    } catch (_) {}
  }

  Future<void> _pickAndSaveImage(String tileName) async {
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
      final fileName = 'tile_${widget.parentCategoryKey}_${tileName.replaceAll(RegExp(r'[^\w\s]+'), '')}_$timestamp.jpg';
      final savedFile = File('${appDir.path}/$fileName');
      await savedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));

      setState(() {
        _tileImages[tileName] = savedFile.path;
      });
      await _saveImages();
    } catch (_) {}
  }

  Future<void> _removeImage(String tileName) async {
    try {
      final imagePath = _tileImages[tileName];
      if (imagePath != null) {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      setState(() {
        _tileImages.remove(tileName);
      });
      await _saveImages();
    } catch (_) {}
  }

  void _showTileOptions(String tileName) {
    final hasImage = _tileImages.containsKey(tileName);
    
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
                _pickAndSaveImage(tileName);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeImage(tileName);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Tile'),
              onTap: () {
                Navigator.pop(ctx);
                _editTile(tileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Tile'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteTile(tileName);
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

  void _showSubcategoryImageOptions(String tileName) {
    final hasImage = _tileImages.containsKey(tileName);
    
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
                _pickAndSaveImage(tileName);
              },
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Image'),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeImage(tileName);
                },
              ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Subcategory'),
              onTap: () {
                Navigator.pop(ctx);
                _editSubcategory(tileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Subcategory'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteSubcategory(tileName);
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

  void _editSubcategory(String oldName) {
    String newName = oldName;
    
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
                'Edit Subcategory Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: oldName),
                decoration: const InputDecoration(
                  labelText: 'Subcategory Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => newName = val.trim(),
                onSubmitted: (_) {
                  if (newName.isNotEmpty && newName != oldName) {
                    setState(() {
                      if (_tileImages.containsKey(oldName)) {
                        _tileImages[newName] = _tileImages[oldName]!;
                        _tileImages.remove(oldName);
                      }
                    });
                    _saveImages();
                  }
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (newName.isNotEmpty && newName != oldName) {
                    setState(() {
                      if (_tileImages.containsKey(oldName)) {
                        _tileImages[newName] = _tileImages[oldName]!;
                        _tileImages.remove(oldName);
                      }
                    });
                    _saveImages();
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

  void _deleteSubcategory(String tileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delete "$tileName"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will also delete all words inside this subcategory!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              // Remove the image if it exists
              await _removeImage(tileName);
              
              // Note: The subcategory data is in widget.subcategories which is read-only
              // We can only remove the image, not delete the actual subcategory structure
              // If you want full deletion, you'd need to manage subcategories in SharedPreferences
              
              Navigator.pop(ctx);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note: Seeded subcategories can only have their images removed. To fully manage subcategories, they need to be stored in app data.'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editTile(String oldTileName) {
    String newTileName = oldTileName;
    
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
                'Edit Tile Name',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                controller: TextEditingController(text: oldTileName),
                decoration: const InputDecoration(
                  labelText: 'Tile Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => newTileName = val.trim(),
                onSubmitted: (_) {
                  if (newTileName.isNotEmpty && newTileName != oldTileName) {
                    final index = _customTiles.indexOf(oldTileName);
                    if (index != -1) {
                      setState(() {
                        _customTiles[index] = newTileName;
                        if (_tileImages.containsKey(oldTileName)) {
                          _tileImages[newTileName] = _tileImages[oldTileName]!;
                          _tileImages.remove(oldTileName);
                        }
                      });
                      _saveCustomTiles();
                      _saveImages();
                    }
                  }
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (newTileName.isNotEmpty && newTileName != oldTileName) {
                    final index = _customTiles.indexOf(oldTileName);
                    if (index != -1) {
                      setState(() {
                        _customTiles[index] = newTileName;
                        if (_tileImages.containsKey(oldTileName)) {
                          _tileImages[newTileName] = _tileImages[oldTileName]!;
                          _tileImages.remove(oldTileName);
                        }
                      });
                      _saveCustomTiles();
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

  void _addTile() {
    String tileName = '';
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
        final fileName = 'temp_tile_$timestamp.jpg';
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
                    'Add Quick Tile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'to ${widget.parentCategoryDisplay}',
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
                      labelText: 'Tile Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => tileName = val.trim(),
                    onSubmitted: (_) {
                      if (tileName.isNotEmpty) {
                        setState(() => _customTiles.add(tileName));
                        _saveCustomTiles();
                        if (tempImagePath != null) {
                          _tileImages[tileName] = tempImagePath!;
                          _saveImages();
                        }
                        Navigator.pop(ctx);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (tileName.isNotEmpty) {
                        setState(() => _customTiles.add(tileName));
                        _saveCustomTiles();
                        if (tempImagePath != null) {
                          _tileImages[tileName] = tempImagePath!;
                          _saveImages();
                        }
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Add Tile'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTile(String tile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tile'),
        content: Text('Delete "$tile"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _customTiles.remove(tile);
                _removeImage(tile);
              });
              _saveCustomTiles();
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
    final allTiles = [
      ...widget.subcategories.map((s) => {
            'name': s['display'] as String,
            'isSubcategory': true,
            'data': s,
          }),
      ..._customTiles.map((t) => {
            'name': t,
            'isSubcategory': false,
          }),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const LargeBackButton(),
        title: Text(widget.parentCategoryDisplay),
        actions: [
          IconButton(
            tooltip: 'Add Quick Tile',
            icon: const Icon(Icons.add),
            onPressed: _addTile,
          ),
        ],
      ),
      body: SafeArea(
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
              itemCount: allTiles.length,
              itemBuilder: (context, index) {
                final tile = allTiles[index];
                final tileName = tile['name'] as String;
                final isSubcategory = tile['isSubcategory'] as bool;
                final imagePath = _tileImages[tileName];
                final hasImage = imagePath != null && File(imagePath).existsSync();

                return GestureDetector(
                  onLongPress: isSubcategory 
                      ? () => _showSubcategoryImageOptions(tileName)
                      : () => _showTileOptions(tileName),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      if (isSubcategory) {
                        final subcat = tile['data'] as Map<String, dynamic>;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WordLibraryScreen(
                              categoryDisplay: subcat['display'] as String,
                              categoryKey: subcat['key'] as String,
                              initialWords: (subcat['words'] as List<dynamic>)
                                  .cast<String>(),
                            ),
                          ),
                        );
                      } else {
                        TtsController.instance.speak(tileName);
                      }
                    },
                    child: hasImage
                        ? Column(
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
                                  tileName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14 * textScaleValue),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Text(
                              tileName,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16 * textScaleValue),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}