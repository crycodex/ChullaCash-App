import 'package:get/get.dart';
import 'package:flutter/material.dart';
//firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//models
import '../../../data/models/user_model.dart';
//google sign in
import 'package:google_sign_in/google_sign_in.dart';
//apple sign in
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum AuthStatus { checking, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  //variables
  final RxBool showLogin = false.obs;
  final RxBool showRegister = false.obs;
  final RxBool showForgotPassword = false.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid.value = currentUser.uid;
        await _loadTheme();
      }
    } catch (e) {
      debugPrint('Error al inicializar auth: $e');
    }
  }

  Future<void> _loadTheme() async {
    try {
      if (uid.value.isEmpty) return;

      final userDoc = await _firestore.collection('users').doc(uid.value).get();
      if (userDoc.exists) {
        final darkMode = userDoc.data()?['isDarkMode'];
        isDarkMode.value = darkMode == true || darkMode == "true";
        Get.changeThemeMode(
            isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (e) {
      debugPrint('Error al cargar el tema: $e');
    }
  }

  void toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

      if (uid.value.isNotEmpty) {
        await _firestore.collection('users').doc(uid.value).update({
          'isDarkMode': isDarkMode.value,
        });
      }
    } catch (e) {
      debugPrint('Error al cambiar el tema: $e');
    }
  }

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
  final password = ''.obs;
  final profilePicture = ''.obs;
  final theme = ''.obs;
  final language = ''.obs;
  final userType = ''.obs;
  final email = ''.obs;
  //Constantes
  static const int minNameLength = 1;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 12;
  static const int minEmailLength = 6;
  static const int maxEmailLength = 100;
  static const String specialCharacters = r'[!@#$%^&*(),.?":{}|<>]';

  //handle firebase error
  void _handleAuthErrors(FirebaseAuthException e, Function(String) onError) {
    String errorMessage;

    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'Este correo ya está en uso.';
        break;
      case 'invalid-email':
        errorMessage = 'Formato de correo inválido.';
        break;
      case 'weak-password':
        errorMessage = 'La contraseña es muy débil.';
        break;
      case 'user-not-found':
        errorMessage = 'No se encontró usuario con este correo.';
        break;
      case 'wrong-password':
        errorMessage = 'Contraseña incorrecta.';
        break;
      case 'user-disabled':
        errorMessage = 'Este usuario ha sido deshabilitado.';
        break;
      case 'too-many-requests':
        errorMessage =
            'Demasiados intentos fallidos. Por favor, intente más tarde.';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Operación no permitida.';
        break;
      case 'network-request-failed':
        errorMessage = 'Error de conexión. Verifique su conexión a internet.';
        break;
      default:
        errorMessage = 'Ocurrió un error inesperado.';
    }

    debugPrint('AuthController: Error manejado - ${e.code}: $errorMessage');
    onError(errorMessage);
  }

  AuthStatus _handleAuthStatus(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Por favor, ingrese un email y contraseña válidos');
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      throw Exception('Por favor, ingrese un email válido');
    }

    if (email.length < minEmailLength) {
      throw Exception(
          'El email debe tener al menos $minEmailLength caracteres');
    }

    if (email.length > maxEmailLength) {
      throw Exception(
          'El email no puede tener más de $maxEmailLength caracteres');
    }

    if (password.length < minPasswordLength) {
      throw Exception(
          'La contraseña debe tener al menos $minPasswordLength caracteres');
    }

    if (password.length > maxPasswordLength) {
      throw Exception(
          'La contraseña no puede tener más de $maxPasswordLength caracteres');
    }

    return AuthStatus.checking;
  }

  //!Metodos
  //create user document
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'UID': user.uid,
      'createdAt': Timestamp.now(),
      'name': '',
      'email': user.email?.toLowerCase(),
      'photoUrl': '',
      'userType': 'free',
      'isDarkMode': false,
    });
  }

  //login email
  Future<void> login({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    debugPrint('AuthController: Iniciando proceso de login...');
    try {
      isLoading.value = true;
      authStatus.value = _handleAuthStatus(email, password);

      final String userEmail = email.toLowerCase().trim();
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      final User? signedUser = userCredential.user;
      if (signedUser == null) {
        throw Exception('No se pudo iniciar sesión');
      }

      if (!signedUser.emailVerified) {
        await signedUser.sendEmailVerification();
        throw Exception(
            'Por favor, verifique su correo electrónico. Se ha enviado un nuevo correo de verificación.');
      }

      final userDoc =
          await _firestore.collection('users').doc(signedUser.uid).get();

      if (!userDoc.exists) {
        await _createUserDocument(signedUser);
        final updatedDoc =
            await _firestore.collection('users').doc(signedUser.uid).get();
        if (!updatedDoc.exists) {
          throw Exception('Error al crear el perfil de usuario');
        }
        user = UserModel.fromJson(updatedDoc.data()!);
      } else {
        final userData = userDoc.data();
        if (userData == null) {
          throw Exception('Error al obtener los datos del usuario');
        }
        user = UserModel.fromJson(userData);
      }

      // Actualizar datos observables
      uid.value = signedUser.uid;
      email = signedUser.email ?? '';
      name.value = user?.name ?? '';
      profilePicture.value = user?.photoUrl ?? '';
      theme.value = user?.theme ?? '';
      language.value = user?.language ?? '';
      userType.value = user?.userType ?? '';
      authStatus.value = AuthStatus.authenticated;

      debugPrint('AuthController: Login exitoso');
      onSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthController: Error de Firebase - ${e.code}');
      _handleAuthErrors(e, onError);
    } catch (e) {
      debugPrint('AuthController: Error inesperado - $e');
      onError(e.toString());
    } finally {
      isLoading.value = false;
      if (authStatus.value != AuthStatus.authenticated) {
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  //register email
  Future<void> register({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    debugPrint('AuthController: Iniciando proceso de registro...');
    try {
      isLoading.value = true;
      authStatus.value = _handleAuthStatus(email, password);

      final String userEmail = email.toLowerCase().trim();
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: password,
      );

      final User? newUser = userCredential.user;
      if (newUser == null) {
        throw Exception('Error al crear la cuenta');
      }

      await newUser.sendEmailVerification();
      await _createUserDocument(newUser);

      Get.snackbar(
        'Registro exitoso',
        'Por favor, verifique su correo electrónico para activar su cuenta.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      onSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthController: Error de Firebase - ${e.code}');
      _handleAuthErrors(e, onError);
    } catch (e) {
      debugPrint('AuthController: Error inesperado - $e');
      onError(e.toString());
    } finally {
      isLoading.value = false;
      if (authStatus.value != AuthStatus.authenticated) {
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  //recover password
  Future<void> recoverPassword({
    required String email,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      //verificar si el email existe
      final userDoc = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userDoc.docs.isEmpty) {
        throw Exception('No se encontró usuario con este correo');
      }

      //enviar correo de recuperación
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Correo de recuperación enviado',
        'Se ha enviado un correo de recuperación a su correo electrónico.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthController: Error de Firebase - ${e.code}');
      _handleAuthErrors(e, onError);
    } catch (e) {
      debugPrint('AuthController: Error inesperado - $e');
      onError(e.toString());
    }
  }

  //logout
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed('/welcome');
  }

  //* Login con Google
  Future<void> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('Error al iniciar sesión con Google');
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createUserDocument(user);
        //ir a la pantalla de home
        Get.offAllNamed('/home');
      }
    }
  }

  //* Login con Apple
  Future<void> loginWithApple() async {
    try {
      debugPrint('Iniciando login con Apple...');

      // Verificar si el servicio está disponible
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception(
            'El inicio de sesión con Apple no está disponible en este dispositivo');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('Credencial de Apple obtenida');

      // Crear credencial de Firebase
      final oAuthProvider = OAuthProvider('apple.com');
      final authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Iniciar sesión en Firebase
      final userCredential = await _auth.signInWithCredential(authCredential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Error al iniciar sesión con Apple');
      }

      debugPrint('Usuario autenticado con Firebase');

      // Verificar si el usuario existe en Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Crear documento del usuario si no existe
        await _createUserDocument(user);
        debugPrint('Documento de usuario creado en Firestore');
      }

      // Actualizar datos observables
      uid.value = user.uid;
      email.value = user.email ?? '';
      name.value = user.displayName ?? '';
      profilePicture.value = user.photoURL ?? '';

      debugPrint('Login con Apple exitoso');
      Get.offAllNamed('/home');
    } on SignInWithAppleAuthorizationException catch (e) {
      String errorMessage;
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          errorMessage = 'Inicio de sesión cancelado por el usuario';
          break;
        case AuthorizationErrorCode.failed:
          errorMessage = 'Error de autenticación: ${e.message}';
          break;
        case AuthorizationErrorCode.invalidResponse:
          errorMessage = 'Respuesta inválida del servidor de Apple';
          break;
        case AuthorizationErrorCode.notHandled:
          errorMessage = 'La solicitud no pudo ser manejada';
          break;
        case AuthorizationErrorCode.unknown:
          errorMessage = 'Error desconocido al iniciar sesión con Apple';
          break;
        default:
          errorMessage = 'Error al iniciar sesión con Apple';
      }
      debugPrint('Error en login con Apple: $errorMessage');
      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Error inesperado en login con Apple: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar el inicio de sesión con Apple',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
