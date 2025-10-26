import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/info/terms_screen.dart';
import '../screens/info/about_page.dart';
import '../screens/info/privacy_policy_screen.dart';
import '../screens/info/how_to_use_page.dart';
import '../screens/info/backup_restore_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const ListTile(
              title: Text('Menu'),
              subtitle: Text('Quick access'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup & Restore'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupRestorePage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How to Use'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HowToUsePage()),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Terms & Conditions'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TermsAndConditionsScreen(isInfoPage: true),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.policy),
              title: const Text('Privacy Policy'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}