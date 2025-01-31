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
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Verificar si hay un usuario autenticado y su tema
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String initialRoute = Routes.welcome;
  ThemeMode initialThemeMode = ThemeMode.light;

  if (currentUser?.emailVerified == true) {
    initialRoute = Routes.home;
    // Cargar tema del usuario
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();
      if (userDoc.exists) {
        final darkMode = userDoc.data()?['isDarkMode'];
        initialThemeMode = (darkMode == true || darkMode == "true")
            ? ThemeMode.dark
            : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error al cargar el tema: $e');
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: MainApp(
        initialRoute: initialRoute,
        initialThemeMode: initialThemeMode,
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final ThemeMode initialThemeMode;

  const MainApp({
    super.key,
    required this.initialRoute,
    required this.initialThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: initialThemeMode,
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
