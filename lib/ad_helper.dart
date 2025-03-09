import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Usar IDs de prueba en modo debug
  static bool get _isDebug => kDebugMode;

  static String get bannerAdUnitId {
    if (_isDebug) {
      // IDs de prueba para desarrollo
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } else {
      // IDs reales para producción
      if (Platform.isAndroid) {
        return 'ca-app-pub-6468767225905546/3621399432';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-6468767225905546~1283581526';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (_isDebug) {
      // IDs de prueba para desarrollo
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    } else {
      // IDs reales para producción
      if (Platform.isAndroid) {
        return 'ca-app-pub-6468767225905546/3621399432';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-6468767225905546/9094622930';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (_isDebug) {
      // IDs de prueba para desarrollo
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    } else {
      // IDs reales para producción
      if (Platform.isAndroid) {
        return 'ca-app-pub-6468767225905546/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-6468767225905546/1712485313';
      }
    }
    throw UnsupportedError('Unsupported platform');
  }
}
