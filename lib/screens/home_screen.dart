import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_item.dart';
import '../constants/storage_keys.dart';
import '../constants/seed_data.dart';
import '../constants/colors.dart';
import '../utils/helpers.dart';
import '../tts_controller.dart';
import '../tile_size.dart';
import '../widgets/app_drawer.dart';
import 'subcategory_menu_screen.dart';
import 'word_library_screen.dart';
import 'yes_no_screen.dart';
import '../services/review_prompt_service.dart';
import '../services/revenue_cat_service.dart';
import '../widgets/accessible_keyboard.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeItem> _custom = [];
  late Map<String, int> _colourMap;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  bool _showCustomKeyboard = false;
  bool _isPremium = false;
  bool _isLoadingPremium = true;

  @override
  void initState() {
    super.initState();
    _colourMap = {};
    _loadCustom();
    _checkPremiumStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkPremiumStatus() async {
    final premium = await RevenueCatService.isPremium();
    setState(() {
      _isPremium = premium;
      _isLoadingPremium = false;
    });
  }

  Future<void> _loadCustom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quick = prefs.getStringList(StoreKeys.homeCustomQuick) ?? [];
      final cats = prefs.getStringList(StoreKeys.homeCustomCats) ?? [];
      final colourJson = prefs.getString(StoreKeys.homeColourMap);

      if (colourJson != null) {
        final map = Map<String, dynamic>.from(jsonDecode(colourJson) as Map);
        _colourMap = map.map((k, v) => MapEntry(k, v as int));
      }

      setState(() {
        _custom = [
          ...cats.map((e) => HomeItem(e, HomeItemType.category)),
          ...quick.map((e) => HomeItem(e, HomeItemType.quick))
        ];
      });
    } catch (_) {}
  }

  Future<void> _saveCustom() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quick = _custom.where((e) => e.type == HomeItemType.quick).map((e) => e.label).toList();
      final cats = _custom.where((e) => e.type == HomeItemType.category).map((e) => e.label).toList();
      await prefs.setStringList(StoreKeys.homeCustomQuick, quick);
      await prefs.setStringList(StoreKeys.homeCustomCats, cats);
      await prefs.setString(StoreKeys.homeColourMap, jsonEncode(_colourMap));
    } catch (_) {}
  }

  List<HomeItem> get _homeItems {
    // Show all seeded categories but not custom tiles for free users
    if (!_isPremium) {
      return seededHome;
    }
    
    return [...seededHome, ..._custom];
  }

  Color _getHomeTileColour(String label) {
    final lower = label.toLowerCase();
    if (seededColors.containsKey(lower)) return seededColors[lower]!;
    if (_colourMap.containsKey(lower)) return Color(_colourMap[lower]!);

    final customTileCount = _custom.length;
    final colorIndex = customTileCount % homePalette.length;
    final newColor = homePalette[colorIndex];

    _colourMap[lower] = newColor.value;
    _saveCustom();
    return newColor;
  }

  void _speakText() {
    if (!_isPremium) {
      _showUpgradePrompt('Text-to-speech is a premium feature');
      return;
    }
    
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      TtsController.instance.speak(text);
      ReviewPromptService.incrementUsageAndCheckPrompt(context);
    }
  }

  void _showUpgradePrompt(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Premium Feature'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
              if (result == true) {
                _checkPremiumStatus();
              }
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _addHomeTile() {
    if (!_isPremium) {
      _showUpgradePrompt('Creating custom tiles is a premium feature');
      return;
    }
    
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
                          icon: Icons.category,
                          title: 'Category',
                          description: 'Opens more tiles',
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
                          ? 'e.g., Music, Activities'
                          : 'e.g., Hello, Thank you',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        selectedType == HomeItemType.category
                            ? Icons.category
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
                              _getHomeTileColour(t);
                              _custom.add(HomeItem(t, selectedType));
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

  void _confirmDeleteHomeTile(HomeItem item) {
    final isCustom = _custom.any((c) => c.label == item.label && c.type == item.type);
    
    if (!isCustom) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default tiles cannot be deleted'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Tile'),
        content: Text('Are you sure you want to delete "${titleCase(item.label)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _custom.removeWhere((e) => e.label == item.label && e.type == item.type);
              });
              await _saveCustom();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPremium) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/app_icon.png',
              height: 28,
              width: 28,
            ),
            const SizedBox(width: 8),
            const Text('CommEase'),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!_isPremium)
            TextButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                );
                if (result == true) {
                  _checkPremiumStatus();
                }
              },
              icon: const Icon(Icons.star, color: Colors.amber),
              label: const Text('Upgrade'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: 'Tile Size',
            onPressed: () {
              TileSizeController.showSizeSheet(context);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Free user banner
          if (!_isPremium)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Free: Needs + Stop, Go, Toilet, Drink',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaywallScreen()),
                      );
                      if (result == true) {
                        _checkPremiumStatus();
                      }
                    },
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),
          // Tile grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ValueListenableBuilder<double>(
                  valueListenable: TileSizeController.instance.gridScale,
                  builder: (context, gridScaleValue, child) {
                    final baseTileSize = (120 * gridScaleValue).clamp(125, double.infinity);
                    final tilesAcross = (constraints.maxWidth / baseTileSize).floor().clamp(2, 12);

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: tilesAcross,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _homeItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _homeItems.length) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              padding: const EdgeInsets.all(4),
                            ),
                            onPressed: _addHomeTile,
                            child: ValueListenableBuilder<double>(
                              valueListenable: TileSizeController.instance.scale,
                              builder: (context, textScaleValue, child) {
                                return _iconLabel('Add tile', Icons.add, textScaleValue);
                              },
                            ),
                          );
                        }

                        final item = _homeItems[index];
                        final title = titleCase(item.label);
                        final colour = _getHomeTileColour(item.label);
                        
                        // Free tier unlocked items
                        final freeUnlockedItems = ['needs', 'stop', 'go', 'toilet', 'drink'];
                        final isLocked = !_isPremium && !freeUnlockedItems.contains(item.label.toLowerCase());

                        return GestureDetector(
                          onLongPress: () => _confirmDeleteHomeTile(item),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLocked ? colour.withOpacity(0.3) : colour,
                              foregroundColor: onColor(colour, Theme.of(context).brightness),
                              padding: const EdgeInsets.all(4),
                            ),
                            onPressed: () {
                              final raw = item.label;
                              
                              // Free users can only click unlocked items
                              if (isLocked) {
                                _showUpgradePrompt('Upgrade to unlock all categories');
                                return;
                              }
                              
                              if (item.type == HomeItemType.quick) {
                                TtsController.instance.speak(title);
                                ReviewPromptService.incrementUsageAndCheckPrompt(context);
                                return;
                              }

                              // Block Yes/No for free users
                              if (raw.toLowerCase() == 'yes / no') {
                                if (!_isPremium) {
                                  _showUpgradePrompt('Yes/No screen is a premium feature');
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const YesNoScreen()),
                                );
                                return;
                              }

                              TtsController.instance.speak(title);
                              ReviewPromptService.incrementUsageAndCheckPrompt(context);

                              final isSeeded = seededHome.any((s) => s.label == item.label);
                              final hasNested = seededNested.containsKey(raw);
                              final hasFlat = seededFlat.containsKey(raw);

                              if (hasFlat && isSeeded) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WordLibraryScreen(
                                      categoryDisplay: title,
                                      categoryKey: raw,
                                      initialWords: seededFlat[raw]!,
                                    ),
                                  ),
                                );
                              } else if (hasNested && isSeeded) {
                                final nestedMap = seededNested[raw]!;
                                final subcategoriesList = nestedMap.entries.map((entry) {
                                  return {
                                    'display': entry.key[0].toUpperCase() + entry.key.substring(1),
                                    'key': entry.key,
                                    'words': entry.value,
                                  };
                                }).toList();
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubcategoryMenuScreen(
                                      parentCategoryDisplay: title,
                                      parentCategoryKey: raw,
                                      subcategories: subcategoriesList,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SubcategoryMenuScreen(
                                      parentCategoryDisplay: title,
                                      parentCategoryKey: raw,
                                      subcategories: const [],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Stack(
                              children: [
                                ValueListenableBuilder<double>(
                                  valueListenable: TileSizeController.instance.scale,
                                  builder: (context, textScaleValue, child) {
                                    return _iconLabel(title, iconFor(item.label), textScaleValue);
                                  },
                                ),
                                if (isLocked)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.lock,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Text input section - only for premium users
          if (_isPremium)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _textFocusNode,
                        enableInteractiveSelection: false,
                        decoration: InputDecoration(
                          hintText: 'Type to speak...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _speakText(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _speakText,
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Speak'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Custom keyboard
          if (_showCustomKeyboard)
            AccessibleKeyboard(
              controller: _textController,
              onClose: () {
                setState(() {
                  _showCustomKeyboard = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _iconLabel(String text, IconData icon, double scale) {
    return ClipRect(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 32 * scale),
                  SizedBox(height: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                        ),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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