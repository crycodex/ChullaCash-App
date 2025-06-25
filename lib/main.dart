import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'presentation/routes/routes.dart';
//theme
import 'presentation/theme/app_theme.dart';
//firebase
import 'package:firebase_auth/firebase_auth.dart';
//controllers
import 'presentation/controllers/user_controller.dart';
import 'presentation/controllers/Login/auth_controller.dart';
import 'presentation/controllers/connectivity_controller.dart';
//pages
import 'presentation/atomic/pages/no_connection_page.dart';
//services
import 'services/ad_service.dart';
// Importar para la inicialización de localización de fechas
import 'package:intl/date_symbol_data_local.dart';

// Crear una instancia global del servicio de anuncios
final adService = AdService();

Future<void> main() async {
  try {
    // Asegurarse de que Flutter esté inicializado
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('🚀 Flutter inicializado correctamente');

    // Inicializar datos de localización para español
    await initializeDateFormatting('es_ES', null);
    debugPrint('✅ Localización de fechas inicializada para es_ES');

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado correctamente');

    // Inicializar el controlador de usuario
    Get.put(UserController(), permanent: true);
    debugPrint('✅ Controlador de usuario inicializado');

    // Inicializar el controlador de conectividad
    Get.put(ConnectivityController(), permanent: true);
    debugPrint('✅ Controlador de conectividad inicializado');

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
      MainApp(
        initialRoute: initialRoute,
      ),
    );
  } catch (e) {
    debugPrint('❌ Error en la inicialización: $e');
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

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAds();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    adService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Mostrar anuncio cuando la app vuelve al primer plano desde segundo plano
    if (state == AppLifecycleState.resumed && !_isFirstLaunch) {
      // Usar Future.microtask para no bloquear la UI
      Future.microtask(() async {
        // Esperar un momento para que la app esté completamente en primer plano
        await Future.delayed(const Duration(seconds: 1));
        await _showInterstitialAd();
      });
    }
  }

  void _initAds() async {
    try {
      debugPrint('🚀 Iniciando configuración de anuncios...');

      // Esperar a que la app esté completamente inicializada
      await Future.delayed(const Duration(seconds: 3));

      // Mostrar anuncio al iniciar la app
      await _showInterstitialAd();

      // Marcar que ya no es el primer lanzamiento
      _isFirstLaunch = false;
    } catch (e) {
      debugPrint('❌ Error al inicializar anuncios: $e');
    }
  }

  Future<void> _showInterstitialAd() async {
    try {
      // Mostrar el anuncio
      debugPrint('⏰ Intentando mostrar anuncio intersticial...');
      await adService.showInterstitialAd();
    } catch (e) {
      debugPrint('❌ Error al mostrar anuncio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Asegurarnos de que el controlador de conectividad esté inicializado
    final connectivityController = Get.find<ConnectivityController>();

    // Forzar una verificación de conectividad al iniciar la app
    Future.delayed(const Duration(milliseconds: 500), () {
      connectivityController.checkConnectivity();
    });

    return Obx(() {
      // Solo mostrar la pantalla de sin conexión si estamos seguros de que no hay conexión
      // y ya se ha completado la verificación inicial
      if (!connectivityController.isConnected.value &&
          !connectivityController.isInitialCheck.value) {
        debugPrint('Mostrando pantalla de sin conexión');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: Get.put(UserController()).isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          home: NoConnectionPage(
            onRetry: () {
              debugPrint('Intentando reconectar...');
              connectivityController.checkConnectivity();
            },
          ),
        );
      }

      // Si hay conexión o estamos verificando, mostrar la aplicación normal
      debugPrint(
          'Mostrando aplicación normal. Estado de conexión: ${connectivityController.isConnected.value}');
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: Get.put(UserController()).isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: widget.initialRoute,
        getPages: Routes.routes,
      );
    });
  }
}
