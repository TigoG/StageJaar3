import 'dart:ui'; // For accessing the system language
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_companion_application/localization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  static const String sensorAutoStartKey = 'sensor_auto_start';
  static const String languageCodeKey =
      'language_code'; // Key for storing language preference
  static const String communicationIntervalKey =
      'communication_interval'; // Key for storing communication interval preference

  late SharedPreferences prefs;

  bool _sensorAutoStart = false;
  int _communicationIntervalMin = 5; // Default to 5 minutes
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
      _sensorAutoStart = prefs.getBool(sensorAutoStartKey) ?? false;
      _selectedLanguage =
          prefs.getString(languageCodeKey) ?? 'en'; // Load saved language
      _communicationIntervalMin =
          prefs.getInt(communicationIntervalKey) ?? 5; // Load saved interval
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

  Future<void> _updateSensorAutoStart(bool value) async {
    await prefs.setBool(sensorAutoStartKey, value); // Save to SharedPreferences
    setState(() {
      _sensorAutoStart = value; // Update the state
    });
  }

  Future<void> _updateCommunicationInterval(int value) async {
    await prefs.setInt(
        communicationIntervalKey, value); // Save to SharedPreferences
    setState(() {
      _communicationIntervalMin = value; // Update the state
    });
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
            // Language Selection Section
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                CupertinoListTile(
                  title: Text(
                    LocalizationService.getString(
                        "settings", "select_language"),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                      "${LocalizationService.getString("settings", "current_language")}: ${LocalizationService.getString("settings", _selectedLanguage)}"),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeLanguage(
                            newValue); // Call change language function
                      }
                    },
                    items: LocalizationService.supportedLanguages
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                            value.toUpperCase()), // Display the language code
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            // Sensor section
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                CupertinoListTile(
                  title: Text(
                    LocalizationService.getString(
                        "settings", "sensor_auto_start"),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    LocalizationService.getString(
                        "settings", "sensor_auto_start_subtitle"),
                  ),
                  trailing: CupertinoSwitch(
                    value: _sensorAutoStart,
                    onChanged: (bool value) {
                      _updateSensorAutoStart(value); // Call the method here
                    },
                  ),
                ),
                CupertinoListTile(
                  title: Text(
                    LocalizationService.getString(
                        "settings", "communication_interval_title"),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    LocalizationService.getString(
                        "settings", "communication_interval_subtitle"),
                  ),
                  trailing: DropdownButton<int>(
                    value: _communicationIntervalMin,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        _updateCommunicationInterval(
                            newValue); // Call the method here
                      }
                    },
                    items: <int>[1, 5].map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                            '$value ${LocalizationService.getString("misc", "minutes")}'), // Display the value
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
