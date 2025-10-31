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
              
              // Subscription Terms Section
              _buildSectionHeader('SUBSCRIPTION TERMS'),
              
              _buildSection(
                'Subscription plans',
                'CommEase offers three premium access options:\n\n'
                '• Monthly Subscription: \$4.99 per month with a 3-day free trial\n'
                '• Annual Subscription: \$49.99 per year with a 3-day free trial\n'
                '• Lifetime Purchase: \$79.99 one-time payment (no subscription)\n\n'
                'All subscriptions include unlimited access to premium features including custom tiles, images, categories, text-to-speech input, and all unlocked content.',
              ),
              
              _buildSection(
                'Free trial',
                'New subscribers to monthly or annual plans receive a 3-day free trial. You will not be charged during the trial period. If you do not cancel before the trial ends, your subscription will automatically begin and you will be charged the subscription fee.',
              ),
              
              _buildSection(
                'Automatic renewal',
                'Monthly and annual subscriptions automatically renew at the end of each billing period unless you cancel at least 24 hours before the renewal date. Your payment method will be charged automatically upon renewal.',
              ),
              
              _buildSection(
                'Cancellation',
                'You may cancel your subscription at any time through your Google Play Store account settings. Cancellation takes effect at the end of your current billing period. You will retain access to premium features until the end of the paid period.',
              ),
              
              _buildSection(
                'Refunds',
                'All purchases are processed through Google Play Store and are subject to Google\'s refund policy. Refund requests should be directed to Google Play Store support. Generally, refunds are not provided for partial subscription periods or for the lifetime purchase after the refund window has closed.',
              ),
              
              _buildSection(
                'Price changes',
                'We reserve the right to change subscription prices with 30 days notice. Price changes will not affect your current subscription period but will apply upon renewal unless you cancel before the change takes effect.',
              ),
              
              _buildSection(
                'Access after subscription ends',
                'If your subscription expires or is cancelled, you will lose access to premium features but will retain access to the free tier. Your custom content will be preserved and will become accessible again if you resubscribe.',
              ),
              
              _buildSectionHeader('GENERAL TERMS'),
              
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
                'Your custom phrases and preferences are saved on your device using local storage. Subscription information is processed through RevenueCat and Google Play Store. See our Privacy Policy for complete details.',
              ),
              _buildSection(
                'Data you add',
                'Any phrases or categories you create may contain personal information if you choose to include it. Do not store sensitive information you would not want others with access to your device to see.',
              ),
              _buildSection(
                'Third-party services',
                'The app uses platform services provided by Google (text-to-speech engines, Google Play Billing) and RevenueCat (subscription management) which are governed by their own terms and privacy policies.',
              ),
              _buildSection(
                'Children',
                'If a child uses the app, a parent or guardian should supervise and manage any information stored on the device and any subscription purchases.',
              ),
              _buildSection(
                'Changes to these terms',
                'We may update these terms to reflect improvements or legal requirements. Continued use of CommEase after changes means you accept the updated terms.',
              ),
              _buildSection(
                'Contact',
                'Questions or concerns? Please contact support@codenestle.com or use the contact details provided in the Google Play Store listing.',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
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