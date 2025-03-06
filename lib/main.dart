import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:get/get.dart';
import 'presentation/routes/routes.dart';
//theme
import 'presentation/theme/app_theme.dart';
//idioma
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//change notifier
import 'change_notifier.dart';
//provider
import 'package:provider/provider.dart';
//firebase
import 'package:firebase_auth/firebase_auth.dart';
//controllers
import 'presentation/controllers/user_controller.dart';
import 'presentation/controllers/Login/auth_controller.dart';
import 'presentation/controllers/connectivity_controller.dart';
//pages
import 'presentation/atomic/pages/no_connection_page.dart';

Future<void> main() async {
  try {
    // Asegurarse de que Flutter esté inicializado
    WidgetsFlutterBinding.ensureInitialized();

    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicializar el controlador de usuario
    Get.put(UserController(), permanent: true);

    // Inicializar el controlador de conectividad
    Get.put(ConnectivityController(), permanent: true);

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

class MainApp extends StatelessWidget {
  final String initialRoute;

  const MainApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Asegurarnos de que el controlador de conectividad esté inicializado
    final connectivityController = Get.find<ConnectivityController>();

    // Forzar una verificación de conectividad al iniciar la app
    Future.delayed(const Duration(milliseconds: 500), () {
      connectivityController.checkConnectivity();
    });

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
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
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es'),
                Locale('en'),
              ],
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
            locale: localeProvider.locale,
            fallbackLocale: const Locale('es'),
            initialRoute: initialRoute,
            getPages: Routes.routes,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
          );
        });
      },
    );
  }
}
