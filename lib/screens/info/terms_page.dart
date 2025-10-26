import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Terms of Use',
            'By using CommEase, you agree to these terms. Please read them carefully.',
          ),
          _buildSection(
            '1. Acceptance of Terms',
            'By downloading, installing, or using CommEase, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use the app.',
          ),
          _buildSection(
            '2. Description of Service',
            'CommEase is a communication aid application that provides text-to-speech functionality through tile-based navigation. The app allows users to create custom vocabulary and use pre-loaded communication categories.',
          ),
          _buildSection(
            '3. Medical Disclaimer',
            'CommEase is designed as a communication aid tool and is not a medical device. It is not intended to diagnose, treat, cure, or prevent any medical condition. Always consult with qualified healthcare professionals regarding medical advice and treatment.',
          ),
          _buildSection(
            '4. User Responsibilities',
            'You are responsible for:\n\n• Using the app appropriately and lawfully\n• Maintaining the security of your device\n• Creating backups of important custom content\n• Ensuring your device has appropriate TTS engines installed for desired functionality\n• Understanding that voice availability depends on your device\'s installed TTS engines',
          ),
          _buildSection(
            '5. Text-to-Speech Functionality',
            'CommEase relies on your device\'s installed text-to-speech (TTS) engines. Voice availability, quality, and offline functionality depend entirely on the TTS engines you have installed on your device. We do not provide, control, or guarantee the availability or quality of TTS voices.',
          ),
          _buildSection(
            '6. Data Storage',
            'All data created in CommEase (custom tiles, words, and settings) is stored locally on your device. We do not collect, transmit, or store your data on external servers. You are responsible for backing up your custom content using the app\'s backup feature.',
          ),
          _buildSection(
            '7. No Warranty',
            'CommEase is provided "as is" without warranty of any kind, either express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, or non-infringement. We do not warrant that the app will be uninterrupted or error-free.',
          ),
          _buildSection(
            '8. Limitation of Liability',
            'To the maximum extent permitted by law, CodeNestle and its developers shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from your use or inability to use CommEase.',
          ),
          _buildSection(
            '9. Changes to Content',
            'You may customize the app\'s content for personal use. However, you acknowledge that:\n\n• Custom content is stored locally on your device\n• Loss of custom content may occur if you uninstall the app, clear app data, or experience device failure\n• Regular backups are recommended',
          ),
          _buildSection(
            '10. Updates and Modifications',
            'We reserve the right to modify, update, or discontinue CommEase at any time without prior notice. We may also update these Terms and Conditions. Continued use of the app after changes constitutes acceptance of the modified terms.',
          ),
          _buildSection(
            '11. Third-Party Services',
            'CommEase uses device-level text-to-speech services provided by your operating system or third-party TTS engines you have installed. These services are subject to their own terms and conditions.',
          ),
          _buildSection(
            '12. Open Source',
            'CommEase is built using open source Flutter framework and various open source packages. These components are subject to their respective licenses.',
          ),
          _buildSection(
            '13. Intellectual Property',
            'CommEase, its design, and original content are owned by CodeNestle. You may not copy, modify, distribute, or reverse engineer the app except as permitted by law.',
          ),
          _buildSection(
            '14. Jurisdiction',
            'These terms are governed by the laws of Western Australia, Australia. Any disputes shall be subject to the exclusive jurisdiction of the courts of Western Australia.',
          ),
          _buildSection(
            '15. Contact',
            'For questions about these Terms and Conditions, please contact CodeNestle through the app\'s official channels.',
          ),
          _buildSection(
            'Last Updated',
            'These Terms and Conditions were last updated on the release of version 2.0.0.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}