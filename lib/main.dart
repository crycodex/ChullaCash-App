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

    // Verificar si hay un usuario autenticado
    final User? currentUser = FirebaseAuth.instance.currentUser;
    String initialRoute = Routes.welcome;

    if (currentUser?.emailVerified == true) {
      initialRoute = Routes.home;
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
      },
    );
  }
}
