import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/storage_keys.dart';

class BackupService {
  static const String _backupVersion = '1.0';

  /// Export all app data to a JSON string
  static Future<Map<String, dynamic>> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    
    final Map<String, dynamic> backup = {
      'version': _backupVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'data': {},
    };

    for (final key in allKeys) {
      // Skip the terms acceptance flag
      if (key == StoreKeys.acceptedTerms) continue;
      
      final value = prefs.get(key);
      if (value != null) {
        backup['data'][key] = value;
      }
    }

    return backup;
  }

  /// Import data from a backup map
  static Future<bool> importData(Map<String, dynamic> backup) async {
    try {
      // Validate backup structure
      if (!backup.containsKey('version') || !backup.containsKey('data')) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final data = backup['data'] as Map<String, dynamic>;

      // Import all data
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        if (value is String) {
          await prefs.setString(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is List) {
          await prefs.setStringList(key, value.cast<String>());
        }
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  /// Create backup file and return the file path
  static Future<File> createBackupFile() async {
    final backup = await exportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final fileName = 'commease_backup_$timestamp.json';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(jsonString);
    return file;
  }

  /// Share backup file
  static Future<void> shareBackup(BuildContext context) async {
    try {
      final file = await createBackupFile();
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'CommEase Backup',
        text: 'CommEase backup file - $timestamp',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup file ready to share')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  /// Save backup to Downloads (Android) or Documents (iOS)
  static Future<void> saveBackupLocally(BuildContext context) async {
    try {
      final file = await createBackupFile();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup saved to: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  /// Parse backup from JSON string
  static Map<String, dynamic>? parseBackup(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      debugPrint('Parse error: $e');
      return null;
    }
  }
}