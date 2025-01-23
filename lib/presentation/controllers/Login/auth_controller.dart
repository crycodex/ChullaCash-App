import 'package:get/get.dart';

class AuthController extends GetxController {
  final RxBool showLogin = false.obs;
  final RxBool showRegister = false.obs;

  void toggleLogin() {
    showLogin.value = !showLogin.value;
    if (showLogin.value) {
      showRegister.value = false;
    }
  }

  void toggleRegister() {
    showRegister.value = !showRegister.value;
    if (showRegister.value) {
      showLogin.value = false;
    }
  }

  void closeAll() {
    showLogin.value = false;
    showRegister.value = false;
  }
}
