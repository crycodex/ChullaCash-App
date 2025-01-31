//get
import 'package:get/get.dart';
//welcome page
import '../atomic/pages/welcome_page.dart';
//home page
import '../atomic/pages/home_page.dart';

class Routes {
  //welcome page
  static const String welcome = '/welcome';
  static const String home = '/home';
  static final List<GetPage> routes = [
    GetPage(name: Routes.welcome, page: () => WelcomePage()),
    GetPage(name: Routes.home, page: () => HomePage()),
  ];
}
