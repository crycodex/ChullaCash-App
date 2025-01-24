import 'package:get/get.dart';
//firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//models
import '../../../data/models/user_model.dart';

enum AuthStatus { checking, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  //variables
  final RxBool showLogin = false.obs;
  final RxBool showRegister = false.obs;
  final RxBool showForgotPassword = false.obs;

  void toggleLogin() {
    showLogin.value = !showLogin.value;
    if (showLogin.value) {
      showRegister.value = false;
      showForgotPassword.value = false;
    }
  }

  void toggleRegister() {
    showRegister.value = !showRegister.value;
    if (showRegister.value) {
      showLogin.value = false;
      showForgotPassword.value = false;
    }
  }

  void toggleForgotPassword() {
    showForgotPassword.value = !showForgotPassword.value;
    if (showForgotPassword.value) {
      showLogin.value = false;
      showRegister.value = false;
    }
  }

  void closeAll() {
    showLogin.value = false;
    showRegister.value = false;
    showForgotPassword.value = false;
  }

  //?Variables
  //Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //UserModel
  UserModel? user;

  //observadores
  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final authStatus = AuthStatus.checking.obs;
  //user
  final uid = ''.obs;
  final name = ''.obs;
  final email = ''.obs;
  final profilePicture = ''.obs;
  final theme = ''.obs;
  final language = ''.obs;

  //Constantes
  static const int minNameLength = 1;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 12;
  static const String minEmailLength = '6';
  static const String maxEmailLength = '100';
  static const String specialCharacters = r'[!@#$%^&*(),.?":{}|<>]';

  //!Metodos
  //login
  Future<void> login({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    print('AuthController: Iniciando proceso de login...'); // Debug log
    try {
      isLoading.value = true;
      authStatus.value = AuthStatus.checking;

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Por favor, ingrese un email y contraseña válidos');
      }

      print('AuthController: Validando email y contraseña...'); // Debug log
      final String userEmail = email.toLowerCase().trim();
      final bool isValidEmail =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
              .hasMatch(userEmail);

      if (!isValidEmail) {
        throw Exception('Por favor, ingrese un email válido');
      }

      print('AuthController: Intentando login con Firebase...'); // Debug log
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      final User? signedUser = userCredential.user;
      if (signedUser == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      print('AuthController: Login exitoso'); // Debug log
      authStatus.value = AuthStatus.authenticated;
      onSuccess();
    } on FirebaseAuthException catch (e) {
      print('AuthController: Error de Firebase - ${e.code}'); // Debug log
      _handleAuthErrors(e, onError);
    } catch (e) {
      print('AuthController: Error inesperado - $e'); // Debug log
      onError(e.toString());
    } finally {
      isLoading.value = false;
      if (authStatus.value != AuthStatus.authenticated) {
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  //handle firebase error
  void _handleAuthErrors(FirebaseAuthException e, Function(String) onError) {
    final Map<String, String> errorMessages = {
      'email-already-in-use': 'Este correo ya está en uso.',
      'invalid-email': 'Formato de correo inválido.',
      'weak-password': 'La contraseña es muy débil.',
      'user-not-found': 'No se encontró usuario con este correo.',
      'wrong-password': 'Contraseña incorrecta.',
      'user-disabled': 'Este usuario ha sido deshabilitado.',
      'too-many-requests':
          'Demasiados intentos fallidos. Por favor, intente más tarde.',
      'operation-not-allowed': 'Operación no permitida.',
      'network-request-failed':
          'Error de conexión. Verifique su conexión a internet.',
    };

    final errorMessage =
        errorMessages[e.code] ?? 'Ocurrió un error inesperado.';
    print(
        'AuthController: Error manejado - ${e.code}: $errorMessage'); // Debug log
    onError(errorMessage);
  }
}
