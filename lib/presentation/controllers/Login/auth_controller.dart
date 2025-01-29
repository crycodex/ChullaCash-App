import 'package:get/get.dart';
import 'package:flutter/material.dart';
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
}
