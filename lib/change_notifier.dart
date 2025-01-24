import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('es');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      Get.updateLocale(newLocale);
      notifyListeners();
      debugPrint('Idioma cambiado a: ${newLocale.languageCode}');
    }
  }
}
