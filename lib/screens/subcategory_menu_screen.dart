import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_item.dart';
import '../constants/storage_keys.dart';
import '../utils/helpers.dart';
import '../tts_controller.dart';
import '../tile_size.dart';
import '../widgets/large_back_button.dart';
import 'word_library_screen.dart';

class SubcategoryMenuScreen extends StatefulWidget {
  final String category;
  final String parentKeyRaw;
  final Map<String, List<String>> subcategories;

  const SubcategoryMenuScreen({
    super.key,
    required this.category,
    required this.parentKeyRaw,
    required this.subcategories,
  });

  @override
  State<SubcategoryMenuScreen> createState() => _SubcategoryMenuScreenState();
}

class _SubcategoryMenuScreenState extends State<SubcategoryMenuScreen> {
  late Map<String, List<String>> _subs;
  List<String> _customCategories = [];
  List<String> _customQuick = [];

  @override
  void initState() {
    super.initState();
    _subs = Map<String, List<String>>.from(widget.subcategories);
    _loadCustom();
  }

  Future<void> _loadCustom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = widget.parentKeyRaw;
      _customCategories = prefs.getStringList('${key}:custom_cats') ?? [];
      _customQuick = prefs.getStringList('${key}:custom_quick') ?? [];
      
      for (final k in _customCategories) {
        _subs.putIfAbsent(k, () => []);
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _saveCustom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = widget.parentKeyRaw;
      await prefs.setStringList('${key}:custom_cats', _customCategories);
      await prefs.setStringList('${key}:custom_quick', _customQuick);
    } catch (_) {}
  }

  List<HomeItem> get _allItems {
    final items = <HomeItem>[];
    // Add seeded and custom categories
    for (final key in _subs.keys) {
      items.add(HomeItem(key, HomeItemType.category));
    }
    // Add custom quick tiles
    for (final label in _customQuick) {
      items.add(HomeItem(label, HomeItemType.quick));
    }
    return items;
  }

  void _addTile() {
    HomeItemType selectedType = HomeItemType.category;
    String label = '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    'Add New Tile',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Choose tile type:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _TileTypeCard(
                          icon: Icons.folder,
                          title: 'Category',
                          description: 'Opens word list',
                          isSelected: selectedType == HomeItemType.category,
                          onTap: () {
                            setModalState(() {
                              selectedType = HomeItemType.category;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TileTypeCard(
                          icon: Icons.volume_up,
                          title: 'Quick',
                          description: 'Speaks immediately',
                          isSelected: selectedType == HomeItemType.quick,
                          onTap: () {
                            setModalState(() {
                              selectedType = HomeItemType.quick;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    autofocus: true,
                    onChanged: (v) => label = v,
                    decoration: InputDecoration(
                      labelText: 'Tile label',
                      hintText: selectedType == HomeItemType.category 
                          ? 'e.g., Snacks, Breakfast'
                          : 'e.g., Yes please, No thank you',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        selectedType == HomeItemType.category 
                            ? Icons.folder 
                            : Icons.chat_bubble,
                      ),
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
                            final t = label.trim();
                            if (t.isEmpty) {
                              Navigator.pop(ctx);
                              return;
                            }
                            setState(() {
                              if (selectedType == HomeItemType.category) {
                                _customCategories.add(t);
                                _subs.putIfAbsent(t, () => []);
                              } else {
                                _customQuick.add(t);
                              }
                            });
                            await _saveCustom();
                            if (mounted) Navigator.pop(ctx);
                          },
                          child: const Text('Add Tile'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTile(HomeItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this tile?',
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
                  Icon(
                    item.type == HomeItemType.category 
                        ? Icons.folder 
                        : Icons.volume_up,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      titleCase(item.label),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (item.type == HomeItemType.category) ...[
              const SizedBox(height: 12),
              Text(
                'All words inside this category will also be deleted.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                ),
              ),
            ],
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
              setState(() {
                if (item.type == HomeItemType.category) {
                  _customCategories.remove(item.label);
                  _subs.remove(item.label);
                } else {
                  _customQuick.remove(item.label);
                }
              });
              
              await _saveCustom();
              
              // Delete associated words if it's a category
              if (item.type == HomeItemType.category) {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final categoryKey = composeKey(widget.parentKeyRaw, item.label);
                  await prefs.remove(StoreKeys.words(categoryKey));
                } catch (_) {}
              }
              
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${titleCase(item.label)} deleted'),
                    duration: const Duration(seconds: 2),
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
    final items = _allItems;
    
    return Scaffold(
      appBar: AppBar(
        leading: const LargeBackButton(),
        title: Text(widget.category),
        actions: [
          IconButton(
            tooltip: 'Add Tile',
            icon: const Icon(Icons.add),
            onPressed: _addTile,
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<double>(
          valueListenable: TileSizeController.instance.gridScale,
          builder: (context, gridScaleValue, child) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180 * gridScaleValue,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = titleCase(item.label);
                
                return GestureDetector(
                  onLongPress: () => _confirmDeleteTile(item),
                  child: ElevatedButton(
                    onPressed: () {
                      TtsController.instance.speak(title);
                      
                      // Quick tiles just speak
                      if (item.type == HomeItemType.quick) {
                        return;
                      }
                      
                      // Category tiles navigate to word library
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordLibraryScreen(
                            categoryDisplay: '${widget.category} › $title',
                            categoryKey: composeKey(widget.parentKeyRaw, item.label),
                            initialWords: _subs[item.label] ?? [],
                          ),
                        ),
                      );
                    },
                    child: ValueListenableBuilder<double>(
                      valueListenable: TileSizeController.instance.scale,
                      builder: (context, textScaleValue, child) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final textPainter = TextPainter(
                              text: TextSpan(
                                text: title,
                                style: TextStyle(
                                  fontSize: 16 * textScaleValue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              maxLines: 2,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            if (textPainter.didExceedMaxLines) {
                              // Text exceeds 2 lines, use FittedBox to scale down
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: Text(
                                    title,
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
                              // Text fits in 2 lines, display normally
                              return Center(
                                child: Text(
                                  title,
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
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TileTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _TileTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? colorScheme.primary 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected 
                  ? colorScheme.onPrimaryContainer 
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isSelected 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}