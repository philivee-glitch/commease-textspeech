import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to use CommEase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Getting started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Tap a phrase tile to speak it.\n• Long-press a subcategory to delete it.\n• Use the + buttons to add your own tiles and words.'),

          SizedBox(height: 16),
          Text('Voice & speech', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Open Settings → Speech.\n• Choose a voice from the list, then tap Test.\n• Adjust Rate (speed) and Pitch as you like.\n• These settings are saved and used app-wide.'),

          SizedBox(height: 16),
          Text('Favourites & history', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Favourites: quick access to phrases you use a lot.\n• History: replay what you said recently.'),

          SizedBox(height: 16),
          Text('Backup & restore', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• Use Backup / Restore in the menu to export or import your data.'),

          SizedBox(height: 16),
          Text('Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('• If the system voice changes after a device update, open Settings → Speech and re-select your preferred voice.\n• You can customize tiles and colors on the home screen.'),
        ],
      ),
    );
  }
}