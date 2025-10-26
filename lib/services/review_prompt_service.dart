import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReviewPromptService {
  static const String _usageCountKey = 'communication_usage_count';
  static const String _hasPromptedKey = 'has_prompted_for_review';
  static const int _usageThreshold = 15;

  static Future<void> incrementUsageAndCheckPrompt(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if already prompted
    final hasPrompted = prefs.getBool(_hasPromptedKey) ?? false;
    if (hasPrompted) return;
    
    // Increment usage count
    final currentCount = prefs.getInt(_usageCountKey) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_usageCountKey, newCount);
    
    // Show prompt after threshold
    if (newCount >= _usageThreshold) {
      _showReviewDialog(context);
      await prefs.setBool(_hasPromptedKey, true);
    }
  }

  static void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enjoying CommEase?'),
        content: const Text(
          'Your feedback helps us improve and helps others discover CommEase. '
          'Would you like to rate us on the Play Store?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No thanks'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openPlayStore();
            },
            child: const Text('Rate now'),
          ),
        ],
      ),
    );
  }

  static Future<void> _openPlayStore() async {
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=au.com.codenestle.commease';
    final uri = Uri.parse(playStoreUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}