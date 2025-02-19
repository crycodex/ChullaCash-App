import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../ad_helper.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isLoading = false;
  bool _hasShownAd = false;

  AdService() {
    _initGoogleMobileAds();
  }

  Future<void> _initGoogleMobileAds() async {
    // Solo configurar dispositivo de prueba en el emulador
    if (!Platform.isAndroid && !Platform.isIOS) {
      RequestConfiguration configuration = RequestConfiguration(
        testDeviceIds: ['13def7a256a57ca7900a203ed8d14b7d'],
      );
      MobileAds.instance.updateRequestConfiguration(configuration);
    }
  }

  Future<void> loadInterstitialAd() async {
    if (_isLoading || _hasShownAd) return;
    _isLoading = true;

    debugPrint('🎯 Iniciando carga del anuncio intersticial...');

    try {
      await InterstitialAd.load(
        adUnitId: AdHelper.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅ Anuncio intersticial cargado exitosamente');
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            _isLoading = false;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('📱 Anuncio mostrado en pantalla completa');
                _hasShownAd = true;
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('👋 Anuncio cerrado por el usuario');
                _isInterstitialAdReady = false;
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ Error al mostrar el anuncio: ${error.message}');
                _isInterstitialAdReady = false;
                _isLoading = false;
                ad.dispose();
              },
            );

            // Mostrar el anuncio inmediatamente después de cargarlo
            showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('❌ Error al cargar el anuncio: ${error.message}');
            _isInterstitialAdReady = false;
            _isLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error inesperado al cargar el anuncio: $e');
      _isLoading = false;
    }
  }

  void showInterstitialAd() {
    if (_hasShownAd) {
      debugPrint('⚠️ El anuncio ya fue mostrado anteriormente');
      return;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      debugPrint('🎬 Mostrando anuncio intersticial...');
      _interstitialAd!.show();
    } else {
      debugPrint('⚠️ El anuncio no está listo para mostrarse');
      if (!_isLoading) {
        loadInterstitialAd();
      }
    }
  }

  void dispose() {
    debugPrint('🗑️ Limpiando recursos del anuncio');
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _isLoading = false;
    _hasShownAd = false;
  }
}
