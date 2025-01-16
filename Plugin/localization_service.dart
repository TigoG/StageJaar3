import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static Map<String, Map<String, String>>? _localizedStrings; // Nested map for localization
  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'nl']; // Supported languages
  static const String _fallbackLanguageCode = 'en'; // Fallback language

  // Load the appropriate language file based on the language code
  static Future<void> load(String languageCode) async {
    // Load fallback strings and store them temporarily
    final fallbackStrings = await _loadLanguageFile(_fallbackLanguageCode);

    if (!supportedLanguages.contains(languageCode)) {
      languageCode = _fallbackLanguageCode; // Use fallback if the language is not supported
    }

    try {
      _localizedStrings = await _loadLanguageFile(languageCode); // Load the selected language
    } catch (e) {
      print("Error loading localization file for '$languageCode': $e");
      _localizedStrings = fallbackStrings; // Use fallback strings in case of an error
    }

    _mergeFallbackStrings(fallbackStrings); // Merge fallback strings with loaded strings
  }

  // Helper method to load the language file and return the parsed strings
  static Future<Map<String, Map<String, String>>> _loadLanguageFile(String languageCode) async {
    String jsonString = await rootBundle.loadString('assets/localization/$languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    return _extractTranslations(jsonMap); // Extract translations from the JSON file
  }

  // Helper method to extract translations from the nested JSON structure
  static Map<String, Map<String, String>> _extractTranslations(Map<String, dynamic> jsonMap) {
    final translations = <String, Map<String, String>>{};

    // Iterate through each section in the JSON map
    jsonMap.forEach((section, values) {
      if (values is Map<String, dynamic>) {
        translations[section] = values.map((key, value) => MapEntry(key, value)); // Map key to its corresponding translation
      }
    });

    return translations;
  }

  // Merge localized strings with fallback strings
  static void _mergeFallbackStrings(Map<String, Map<String, String>> fallbackStrings) {
    if (_localizedStrings != null) {
      fallbackStrings.forEach((sectionKey, sectionValue) {
        // If the section exists in localized strings, merge its keys
        if (_localizedStrings!.containsKey(sectionKey)) {
          sectionValue.forEach((key, value) {
            // Add missing keys from the fallback language
            _localizedStrings![sectionKey]!.putIfAbsent(key, () => value);
          });
        } else {
          // Add the entire section if it's not present
          _localizedStrings![sectionKey] = sectionValue;
        }
      });
    } else {
      _localizedStrings = fallbackStrings; // If no localized strings, use fallback entirely
    }
  }

  // Translate a given key using the loaded language strings
  static String getString(String section, String key) {
    return _localizedStrings?[section]?[key] ?? key; // Fallback to returning the key itself if not found
  }

  // Change the language (utility function)
  static Future<void> changeLanguage(String languageCode) async {
    await load(languageCode); // Load new language
  }

  // Retrieve the currently loaded language strings
  static Map<String, Map<String, String>>? get localizedStrings => _localizedStrings;
}
