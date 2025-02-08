//get
import 'package:get/get.dart';
//welcome page
import '../atomic/pages/welcome_page.dart';
//home page
import '../atomic/pages/home_page.dart';
//history page
import '../atomic/organisms/history/history_content.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String home = '/home';
  static const String history = '/history';
  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => WelcomePage()),
    GetPage(name: Routes.home, page: () => HomePage()),
    GetPage(name: Routes.history, page: () => HistoryContent()),
  ];
}
