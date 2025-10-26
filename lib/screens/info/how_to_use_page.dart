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
            'Deleting Tiles',
            'Long-press any custom tile and confirm deletion. Note: Default tiles (Needs, Feelings, etc.) cannot be deleted, but you can delete any custom tiles you create.',
          ),
          _buildSection(
            context,
            'Building Sentences',
            'In word lists, tap multiple words to build a sentence. Your selection appears at the bottom. Tap the speaker icon to speak the full sentence, or the X to clear.',
          ),
          _buildSection(
            context,
            'Adjusting Display Size',
            '1. Open menu → Settings\n2. Tap "Adjust Display Size"\n3. Use sliders to adjust:\n   • Text Size (100% - 300%)\n   • Tile Size (80% - 200%)\n\nMake text and tiles larger for better visibility.',
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
            'Save your custom vocabulary:\n\n1. Open menu → Backup & Restore\n2. Tap "Create Backup" to save all custom content\n3. Share or save the backup file\n4. Use "Restore from Backup" to reload your content on any device\n\nBackups include all custom tiles and words but not settings.',
          ),
          _buildSection(
            context,
            'Tips for Best Experience',
            '• Test different voices to find one that works offline\n• Use the Yes/No screen for quick binary questions\n• Create custom categories for frequently used phrases\n• Increase text size if needed for better readability\n• Make regular backups of your custom vocabulary\n• Enable "Use System Default Voice" if experiencing voice issues',
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