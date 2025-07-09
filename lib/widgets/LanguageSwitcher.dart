import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:automotive/translations/languages.dart';

class LanguageSwitcher extends StatelessWidget {
  final locale = GetStorage();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.language),
      onSelected: (String language) {
        _changeLanguage(language);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: Languages.english,
            child: Text('English'),
          ),
          PopupMenuItem(
            value: Languages.arabic,
            child: Text('العربية'),
          ),
          PopupMenuItem(
            value: Languages.german,
            child: Text('Deutsch'),
          ),
        ];
      },
    );
  }

  void _changeLanguage(String languageCode) {
    locale.write('language', languageCode);
    Get.updateLocale(Locale(languageCode));
  }
}