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

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String history = '/history';
  static const String personalInfo = '/personal-info';
  static const String security = '/security';
  static const String appLock = '/app-lock';

  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => WelcomePage()),
    GetPage(name: Routes.home, page: () => HomePage()),
    GetPage(name: Routes.history, page: () => HistoryContent()),
    GetPage(name: Routes.personalInfo, page: () => PersonalInfoContent()),
    GetPage(name: Routes.security, page: () => SecurityContent()),
    GetPage(name: Routes.appLock, page: () => AppLockScreen()),
  ];
}
