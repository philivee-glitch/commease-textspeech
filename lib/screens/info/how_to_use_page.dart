import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Use'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            'Getting Started',
            'CommEase helps you communicate using tiles that speak when tapped. The app is organized into three levels: Home tiles, Category tiles, and Word tiles.',
          ),
          _buildSection(
            context,
            'Type-to-Speech Input',
            'At the bottom of the home screen, you\'ll find a text input field:\n\n1. Tap the field and type any custom phrase\n2. Press "Speak" button (or Enter) to hear it spoken\n3. Text stays in the field until you clear it manually\n\nPerfect for saying anything not in your pre-set tiles!',
          ),
          _buildSection(
            context,
            'Quick Yes/No Responses',
            'Tap the "Yes / No" tile on the home screen for instant access to large YES (green) and NO (red) buttons. Perfect for quick binary responses.',
          ),
          _buildSection(
            context,
            'Using Pre-loaded Categories',
            '• Needs: Common needs and requests\n• Feelings: Emotions and states\n• Food: Meals, drinks, and food items\n• Places: Locations and rooms\n• People: Family, friends, and professionals\n\nTap any category to explore the words and phrases inside.',
          ),
          _buildSection(
            context,
            'Quick Tiles',
            'Quick tiles (like Help, Stop, Go, Toilet) speak immediately when tapped - no need to navigate into categories.',
          ),
          _buildSection(
            context,
            'Creating Custom Content',
            '1. Tap "Add tile" on any screen\n2. Choose "Category" (opens more tiles) or "Quick" (speaks immediately)\n3. Enter your label\n4. Tap "Add Tile"\n\nYou can create up to 3 levels deep:\nHome → Your Category → Subcategory → Words',
          ),
          _buildSection(
            context,
            'Adding Images to Tiles',
            'Personalize ANY tile with custom images:\n\n1. Long-press any tile (word, subcategory, or quick tile)\n2. Select "Add Image" or "Change Image"\n3. Choose a photo from your device\n4. The image appears on the tile with text below\n\nImages work on:\n• Word tiles in categories\n• Subcategory tiles (Meals, Drinks, etc.)\n• Quick tiles you create\n• Custom category tiles\n\nImages are automatically optimized and cropped to 4:3 ratio for consistency.',
          ),
          _buildSection(
            context,
            'Managing Tiles (Edit & Delete)',
            'Long-press any tile to access the tile menu:\n\n• Add/Change Image: Add or replace the tile image\n• Remove Image: Delete the current image\n• Edit Tile/Word: Rename the tile or word\n• Delete Tile/Word: Remove the tile completely\n\nNote: You can edit and add images to default tiles (like "Meals" or "Drinks"), but you cannot delete default tiles - only custom tiles you create can be deleted.',
          ),
          _buildSection(
            context,
            'Deleting Subcategories',
            'When deleting a subcategory:\n\n1. Long-press the subcategory tile\n2. Select "Delete Subcategory"\n3. Confirm deletion\n\nWarning: This will delete the subcategory AND all words inside it. This action cannot be undone unless you have a backup.',
          ),
          _buildSection(
            context,
            'Building Sentences',
            'In word lists, tap multiple words to build a sentence:\n\n1. Tap words in order\n2. Your selection appears at the bottom\n3. Tap the speaker icon to speak the full sentence\n4. Tap the X to clear and start over\n\nPerfect for constructing longer phrases!',
          ),
          _buildSection(
            context,
            'Adjusting Display Size',
            'Tap the grid icon (⊞) in the top right corner to access size controls:\n\n• Text Size slider: Adjusts font size (100% - 300%)\n• Tile Size slider: Adjusts tile dimensions (80% - 200%)\n\nText and tiles resize independently across all screens for optimal accessibility and comfort.',
          ),
          _buildSection(
            context,
            'Voice Settings',
            'From Settings, you can:\n\n• Adjust Speech Rate (how fast it speaks)\n• Adjust Pitch (voice tone)\n• Adjust Volume\n• Select Voice (if multiple voices installed on device)\n• Enable "Use System Default Voice" for reliable offline speech\n\nNote: Voice selection depends on TTS engines installed on your device. Cloud-based voices require internet connection.',
          ),
          _buildSection(
            context,
            'Offline Mode',
            'CommEase works completely offline. If you\'ve selected a cloud-based voice:\n\n1. Go to Settings\n2. Turn ON "Use System Default Voice"\n3. This ensures speech always works, even without internet',
          ),
          _buildSection(
            context,
            'Backup & Restore',
            'Save your custom vocabulary and images:\n\n1. Open menu → Backup & Restore\n2. Tap "Create Backup" to save all custom content\n3. Share or save the backup file\n4. Use "Restore from Backup" to reload your content on any device\n\nBackups include:\n• All custom tiles and words\n• All custom images\n• Category organization\n\nBackups do NOT include:\n• Voice settings\n• Display size settings',
          ),
          _buildSection(
            context,
            'Tips for Best Experience',
            '• Use the text-to-speech input for spontaneous communication\n• Add images to commonly used words for better recognition\n• Long-press tiles to access edit and image options\n• Test different voices to find one that works offline\n• Use the Yes/No screen for quick binary questions\n• Create custom categories for frequently used phrases\n• Adjust text and tile sizes independently for comfort\n• Make regular backups of your custom vocabulary\n• Enable "Use System Default Voice" if experiencing voice issues\n• Images automatically update when changed - no need to restart',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}