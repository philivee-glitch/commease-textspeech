import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CommEase Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Effective date: October 2025',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Platform: Android & iOS',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Summary (plain language)',
                'CommEase runs on your device and keeps your data on your device. We do not collect, share, or sell personal information. There is no advertising or tracking.',
              ),
              _buildSection(
                'What data we handle',
                'Phrases, favourites, categories, and settings you create in the app are stored locally on your device.\n\n'
                '• No account is required. We do not store data on our servers.\n'
                '• No analytics or tracking SDKs are included.\n'
                '• No third-party sharing of any data.',
              ),
              _buildSection(
                'Permissions',
                'Audio output (text-to-speech): used to speak selected phrases aloud.\n\n'
                '• No microphone/recording permission is requested in the current version.\n'
                '• The app does not request contacts, location, camera, or photos.',
              ),
              _buildSection(
                'How your data is used',
                'Your on-device data is used solely to provide app features (show tiles, speak phrases, remember preferences). We do not profile users.',
              ),
              _buildSection(
                'Data retention and deletion',
                'All data remains on your device until you delete it.\n\n'
                '• You can remove phrases/categories within the app.\n'
                '• Optional backup files you create are saved to your device storage and can be shared or deleted manually.\n'
                '• You can delete all app data by uninstalling the app or clearing the app\'s storage in system settings.',
              ),
              _buildSection(
                'Children',
                'CommEase may be used by children under guidance of parents/carers/clinicians. We do not collect personal data from any users.',
              ),
              _buildSection(
                'Security',
                'Data is stored locally using the platform\'s standard app storage. Do not store sensitive information in phrase text. If future versions add cloud backup or sync, this policy will be updated first.',
              ),
              _buildSection(
                'Changes to this policy',
                'We may update this policy from time to time. Material changes will be reflected on this page with a new effective date.',
              ),
              _buildSection(
                'Contact',
                'Questions or concerns? Please contact the developer using the details provided in the app store listing.',
              ),
              const Divider(height: 32),
              const Text(
                'Disclaimer: CommEase is an assistive communication tool and is not a medical device or a substitute for emergency communication.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}