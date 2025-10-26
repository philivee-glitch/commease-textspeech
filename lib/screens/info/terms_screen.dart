import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/storage_keys.dart';
import '../home_screen.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  final bool isInfoPage;
  
  const TermsAndConditionsScreen({super.key, this.isInfoPage = false});
  
  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _checked = false;

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StoreKeys.acceptedTerms, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection(
                'Purpose and scope',
                'CommEase provides quick-access phrases and text-to-speech to support everyday communication. It is intended as a convenience tool only.',
              ),
              _buildSection(
                'No medical or emergency use',
                'CommEase is not a medical device and does not provide clinical, legal, or safety advice. Do not rely on it in emergencies. In an emergency, contact your local emergency number.',
              ),
              _buildSection(
                'Your responsibilities',
                'You are responsible for how you use the app and the content you input or share. Use clear judgment and verify important information independently.',
              ),
              _buildSection(
                'Content accuracy',
                'Text-to-speech output is generated from the phrases you select or enter. Always check that what is spoken reflects your intent before relying on it.',
              ),
              _buildSection(
                'Privacy summary',
                'Your custom phrases and preferences are saved on your device using local storage (SharedPreferences). By default no personal data is sent to a remote server.',
              ),
              _buildSection(
                'Data you add',
                'Any phrases or categories you create may contain personal information if you choose to include it. Do not store sensitive information you would not want others with access to your device to see.',
              ),
              _buildSection(
                'Third-party services',
                'The app may use platform services provided by Apple or Google (for example, text-to-speech engines) which are governed by their own terms and privacy policies.',
              ),
              _buildSection(
                'Children',
                'If a child uses the app, a parent or guardian should supervise and manage any information stored on the device.',
              ),
              _buildSection(
                'Changes to these terms',
                'We may update these terms to reflect improvements or legal requirements. Continued use of CommEase after changes means you accept the updated terms.',
              ),
              _buildSection(
                'Contact',
                'Questions or concerns? Please contact the developer using the details provided in the app store listing.',
              ),
              if (!widget.isInfoPage) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Checkbox(
                      value: _checked,
                      onChanged: (v) => setState(() => _checked = v ?? false),
                    ),
                    const Expanded(
                      child: Text('I have read and agree to the Terms and Conditions.'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _checked ? _accept : null,
                  child: const Text('Accept and continue'),
                ),
              ]
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