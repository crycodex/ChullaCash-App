import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../ad_helper.dart';
import 'dart:async';

class AdService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  bool _isLoading = false;
  bool _hasShownAd = false;
  bool _isInitialized = false;
  int _numInterstitialLoadAttempts = 0;
  int _maxInterstitialLoadAttempts = 3;

  // Completer para manejar la inicialización asíncrona
  final Completer<bool> _initCompleter = Completer<bool>();

  // Getter para obtener el Future de inicialización
  Future<bool> get initialized => _initCompleter.future;

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

      // Completar el Future de inicialización
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete(true);
      }
    } catch (e) {
      debugPrint('❌ Error al inicializar Google Mobile Ads: $e');
      _isInitialized = false;

      // Completar el Future con error
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete(false);
      }
    }
  }

  Future<void> loadInterstitialAd() async {
    // Esperar a que AdMob esté inicializado
    if (!_isInitialized) {
      debugPrint('⏳ Esperando a que AdMob se inicialice...');
      final isInitialized = await initialized.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint(
              '⚠️ Tiempo de espera agotado para la inicialización de AdMob');
          return false;
        },
      );

      if (!isInitialized) {
        debugPrint(
            '⚠️ No se puede cargar el anuncio: AdMob no se inicializó correctamente');
        return;
      }
    }

    if (_isLoading) {
      debugPrint('⚠️ Ya se está cargando un anuncio');
      return;
    }

    // Reiniciar el estado para permitir cargar un nuevo anuncio
    _hasShownAd = false;
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
            _numInterstitialLoadAttempts = 0;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                debugPrint('📱 Anuncio mostrado en pantalla completa');
                _hasShownAd = true;
              },
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('👋 Anuncio cerrado por el usuario');
                _isInterstitialAdReady = false;
                ad.dispose();

                // Precargar el siguiente anuncio
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ Error al mostrar el anuncio: ${error.message}');
                _isInterstitialAdReady = false;
                _isLoading = false;
                ad.dispose();

                // Intentar cargar otro anuncio
                loadInterstitialAd();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('❌ Error al cargar el anuncio: ${error.message}');
            _isInterstitialAdReady = false;
            _isLoading = false;
            _interstitialAd = null;

            _numInterstitialLoadAttempts += 1;
            if (_numInterstitialLoadAttempts < _maxInterstitialLoadAttempts) {
              debugPrint(
                  '🔄 Reintentando cargar anuncio (intento $_numInterstitialLoadAttempts de $_maxInterstitialLoadAttempts)');
              Future.delayed(const Duration(seconds: 1), () {
                loadInterstitialAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error inesperado al cargar el anuncio: $e');
      _isLoading = false;
    }
  }

  Future<void> showInterstitialAd() async {
    // Esperar a que AdMob esté inicializado
    if (!_isInitialized) {
      debugPrint(
          '⏳ Esperando a que AdMob se inicialice antes de mostrar el anuncio...');
      final isInitialized = await initialized.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint(
              '⚠️ Tiempo de espera agotado para la inicialización de AdMob');
          return false;
        },
      );

      if (!isInitialized) {
        debugPrint(
            '⚠️ No se puede mostrar el anuncio: AdMob no se inicializó correctamente');
        return;
      }
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
        // Intentar cargar el anuncio primero
        await loadInterstitialAd();

        // Esperar un momento para que se cargue
        await Future.delayed(const Duration(seconds: 2));

        // Intentar mostrar de nuevo si está listo
        if (_isInterstitialAdReady && _interstitialAd != null) {
          debugPrint('🎬 Mostrando anuncio intersticial (segundo intento)...');
          _interstitialAd!.show();
        } else {
          debugPrint('⚠️ No se pudo cargar el anuncio después de intentarlo');
        }
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
