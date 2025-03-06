//get
import 'package:get/get.dart';
//welcome page
import '../atomic/pages/welcome_page.dart';
//home page
import '../atomic/pages/home_page.dart';
//history page
import '../atomic/organisms/history/history_content.dart';
//personal info page
import '../atomic/organisms/profile/personal_info_content.dart';
//security page
import '../atomic/organisms/profile/security_content.dart';
//app lock screen
import '../atomic/organisms/auth/app_lock_screen.dart';
//credits page
import '../atomic/organisms/credits/credits_content.dart';
//connectivity checker
import '../atomic/molecules/connectivity_checker.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String history = '/history';
  static const String personalInfo = '/personal-info';
  static const String security = '/security';
  static const String appLock = '/app-lock';
  static const String credits = '/credits';

  static final List<GetPage> routes = [
    GetPage(
      name: Routes.welcome,
      page: () => ConnectivityChecker(child: WelcomePage()),
    ),
    GetPage(
      name: Routes.home,
      page: () => ConnectivityChecker(child: HomePage()),
    ),
    GetPage(
      name: Routes.history,
      page: () => ConnectivityChecker(child: HistoryContent()),
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => ConnectivityChecker(child: PersonalInfoContent()),
    ),
    GetPage(
      name: Routes.security,
      page: () => ConnectivityChecker(child: SecurityContent()),
    ),
    GetPage(
      name: Routes.appLock,
      page: () =>
          AppLockScreen(), // No añadimos el checker aquí para permitir el acceso sin conexión
    ),
    GetPage(
      name: Routes.credits,
      page: () => ConnectivityChecker(child: CreditsContent()),
    ),
  ];
}
