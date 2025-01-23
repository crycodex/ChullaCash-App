//welcome page
import '../atomic/pages/welcome_page.dart';
//login
import '../atomic/pages/Login/login_page.dart';
//register
import '../atomic/pages/Login/register_page.dart';

class Pages {
  //welcome page
  static const welcome = WelcomePage();
  //login
  static const login = LoginPage();
  //register
  static const register = RegisterPage();
}

class Routes {
  //welcome page
  static const welcome = '/welcome';
  static const home = '/';
  //login
  static const login = '/login';
  //register
  static const register = '/register';
}
