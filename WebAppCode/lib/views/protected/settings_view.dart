import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  static const String languageCodeKey = 'language_code'; // Key for storing language preference
  late SharedPreferences prefs;
  String _selectedLanguage = 'en'; // Default to English

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _selectedLanguage = prefs.getString(languageCodeKey) ?? 'en'; // Load saved language
    });

    // Load the localization for the selected language
    await LocalizationService.load(_selectedLanguage);
  }

  Future<void> _changeLanguage(String languageCode) async {
    await LocalizationService.changeLanguage(languageCode); // Change language
    setState(() {
      _selectedLanguage = languageCode; // Update selected language
    });

    // Save the selected language in SharedPreferences
    await prefs.setString(languageCodeKey, languageCode);
    
    // Reload the strings for the new language to reflect changes in the UI
    await LocalizationService.load(languageCode);
    setState(() {}); // Ensure the UI updates with new localization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                CupertinoListTile(
                  title: Text(
                    LocalizationService.getString("settings", "select_language"),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text("Current Language: $_selectedLanguage"), // Show current language
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeLanguage(newValue); // Call change language function
                      }
                    },
                    items: LocalizationService.supportedLanguages.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.toUpperCase()), // Display the language code
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
