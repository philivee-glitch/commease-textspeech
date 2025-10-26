import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/storage_keys.dart';
import 'tts_controller.dart';
import 'services/subcategory_prefs.dart';
import 'tile_size.dart';
import 'screens/home_screen.dart';
import 'screens/info/terms_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TtsController.instance.init();
  SubcategoryPrefs.init();
  TileSizeController.instance.load();
  final prefs = await SharedPreferences.getInstance();
  final hasAccepted = prefs.getBool(StoreKeys.acceptedTerms) ?? false;
  runApp(CommunicationApp(startOnTerms: !hasAccepted));
}

class CommunicationApp extends StatelessWidget {
  final bool startOnTerms;
  
  const CommunicationApp({super.key, this.startOnTerms = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommEase',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        visualDensity: VisualDensity.comfortable,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: startOnTerms ? const TermsAndConditionsScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}