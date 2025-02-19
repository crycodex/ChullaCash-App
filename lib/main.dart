import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'presentation/routes/routes.dart';
//theme
import 'presentation/theme/app_theme.dart';
//idioma
import 'package:flutter_localizations/flutter_localizations.dart';
//change notifier
import 'change_notifier.dart';
//provider
import 'package:provider/provider.dart';
//firebase
import 'package:firebase_auth/firebase_auth.dart';
//controllers
import 'presentation/controllers/user_controller.dart';
import 'presentation/controllers/Login/auth_controller.dart';
//admob google
import 'package:google_mobile_ads/google_mobile_ads.dart';
//services
import 'services/ad_service.dart';

final adService = AdService();

Future<void> main() async {
  try {
    // Asegurarse de que Flutter esté inicializado
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializar AdMob
    await MobileAds.instance.initialize();

    // Inicializar el controlador de usuario
    Get.put(UserController(), permanent: true);

    // Verificar si hay un usuario autenticado
    final User? currentUser = FirebaseAuth.instance.currentUser;
    String initialRoute = Routes.welcome;

    if (currentUser?.emailVerified == true) {
      // Obtener el controlador de autenticación
      final authController = Get.put(AuthController());

      // Si el bloqueo está activado y hay un PIN configurado o biometría habilitada
      if (authController.isAppLockEnabled.value &&
          (authController.pin.value.isNotEmpty ||
              authController.isBiometricEnabled.value)) {
        initialRoute = Routes.appLock;
      } else {
        initialRoute = Routes.home;
      }
    }

    runApp(
      ChangeNotifierProvider(
        create: (context) => LocaleProvider(),
        child: MainApp(
          initialRoute: initialRoute,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error en la inicialización: $e');
    // Ejecutar la app con una pantalla de error si algo falla
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error al iniciar la aplicación: $e'),
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  final String initialRoute;

  const MainApp({
    super.key,
    required this.initialRoute,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _initAds();
  }

  void _initAds() async {
    try {
      debugPrint('🚀 Iniciando configuración de anuncios...');
      // Cargar el anuncio
      adService.loadInterstitialAd();

      // Mostrar el anuncio después de un breve retraso
      await Future.delayed(const Duration(seconds: 3));
      debugPrint('⏰ Tiempo de espera completado, mostrando anuncio...');
      adService.showInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error al inicializar anuncios: $e');
    }
  }

  @override
  void dispose() {
    adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: Get.put(UserController()).isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          locale: localeProvider.locale,
          fallbackLocale: const Locale('es'),
          initialRoute: widget.initialRoute,
          getPages: Routes.routes,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es'),
            Locale('en'),
          ],
        );
      },
    );
  }
}
