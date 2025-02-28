import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6468767225905546/3621399432';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6468767225905546~1283581526';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6468767225905546/3621399432';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6468767225905546/9094622930';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6468767225905546/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6468767225905546/1712485313';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
