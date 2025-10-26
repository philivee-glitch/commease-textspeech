import 'dart:async';
import 'package:flutter/material.dart';

// This class holds our translated strings.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Our translation maps for each language.
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'CommEase',
    },
    'es': {
      'appTitle': 'CommEase', // (A professional translator would change this value)
    },
    'zh': {
      'appTitle': 'CommEase', // (A professional translator would change this value)
    },
  };

  // Getters for each translated string.
  String get appTitle {
    return _localizedValues[locale.languageCode]?['appTitle'] ?? 'CommEase';
  }
}

// This delegate is the bridge between Flutter and our translation class.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}