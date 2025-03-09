import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../ad_helper.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isLoading = false;
  bool _hasShownAd = false;
  bool _isInitialized = false;

  AdService() {
    _initGoogleMobileAds();
  }

  Future<void> _initGoogleMobileAds() async {
    try {
      debugPrint('🚀 Inicializando Google Mobile Ads...');

      // Configurar dispositivos de prueba
      List<String> testDeviceIds = ['13def7a256a57ca7900a203ed8d14b7d'];

      if (kDebugMode) {
        RequestConfiguration configuration = RequestConfiguration(
          testDeviceIds: testDeviceIds,
        );
        await MobileAds.instance.updateRequestConfiguration(configuration);
        debugPrint('✅ Configuración de dispositivos de prueba completada');
      }

      // Inicializar MobileAds
      await MobileAds.instance.initialize();
      debugPrint('✅ Google Mobile Ads inicializado correctamente');

      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Error al inicializar Google Mobile Ads: $e');
      _isInitialized = false;
    }
  }

  Future<void> loadInterstitialAd() async {
    if (_isLoading || _hasShownAd || !_isInitialized) {
      debugPrint(
          '⚠️ No se puede cargar el anuncio: ${!_isInitialized ? "AdMob no inicializado" : "Ya está cargando o ya se mostró"}');
      return;
    }

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
    if (!_isInitialized) {
      debugPrint(
          '⚠️ AdMob no está inicializado, no se puede mostrar el anuncio');
      return;
    }

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
