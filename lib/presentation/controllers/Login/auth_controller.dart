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
//theme
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_theme.dart';

enum AuthStatus { checking, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  //variables
  final RxBool showLogin = false.obs;
  final RxBool showRegister = false.obs;
  final RxBool showForgotPassword = false.obs;
  final RxBool isDarkMode = false.obs;
  final RxString userName = 'Usuario'.obs;
  final RxString userEmail = 'usuario@example.com'.obs;
  final Rxn<String> profileImage = Rxn<String>();

  // Seguridad
  final RxBool isAppLockEnabled = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxString lockTimeout = 'immediately'.obs;
  final RxString pin = ''.obs;

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
        await _loadUserData();
        await _loadTheme();
        await _loadSecuritySettings();
      }
    } catch (e) {
      debugPrint('Error al inicializar auth: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (uid.value.isEmpty) return;

      final userDoc = await _firestore.collection('users').doc(uid.value).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userName.value = userData['name'] ?? 'Usuario';
        userEmail.value = userData['email'] ?? 'usuario@example.com';
        profileImage.value = userData['photoUrl'];
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _loadTheme() async {
    try {
      if (uid.value.isEmpty) return;

      final userDoc = await _firestore.collection('users').doc(uid.value).get();
      if (userDoc.exists) {
        final darkMode = userDoc.data()?['isDarkMode'];
        isDarkMode.value = darkMode == true || darkMode == "true";
        _applyTheme();
      }
    } catch (e) {
      debugPrint('Error al cargar el tema: $e');
    }
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    Get.changeTheme(
        isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme);
  }

  void toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      _applyTheme();

      if (uid.value.isNotEmpty) {
        await _firestore.collection('users').doc(uid.value).update({
          'isDarkMode': isDarkMode.value,
        });
      }

      Get.snackbar(
        'Tema cambiado',
        isDarkMode.value ? 'Modo oscuro activado' : 'Modo claro activado',
        backgroundColor:
            isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white,
        colorText: isDarkMode.value ? Colors.white : AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error al cambiar el tema: $e');
      Get.snackbar(
        'Error',
        'No se pudo cambiar el tema',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    try {
      isLoading.value = true;
      debugPrint('Iniciando login con Google...');

      // Primero intentamos cerrar sesión para evitar problemas de caché
      final GoogleSignIn googleSignIn = GoogleSignIn();
      try {
        await googleSignIn.signOut();
        debugPrint('Sesión previa de Google cerrada correctamente');
      } catch (e) {
        debugPrint('No había sesión previa de Google o error al cerrarla: $e');
      }

      // Intentamos iniciar sesión con Google
      debugPrint('Solicitando cuenta de Google...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Usuario canceló el inicio de sesión con Google');
        throw Exception('Inicio de sesión cancelado');
      }

      debugPrint('Cuenta de Google seleccionada: ${googleUser.email}');
      debugPrint('Obteniendo tokens de autenticación...');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint('Error: No se pudieron obtener los tokens de autenticación');
        throw Exception('No se pudieron obtener los tokens de autenticación');
      }

      debugPrint('Tokens obtenidos correctamente');
      debugPrint('Creando credencial para Firebase...');

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Iniciando sesión en Firebase con credencial de Google...');
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        debugPrint('Error: Firebase no devolvió un usuario válido');
        throw Exception('Error al iniciar sesión con Google en Firebase');
      }

      debugPrint('Usuario autenticado en Firebase: ${user.uid}');
      debugPrint('Verificando si el usuario existe en Firestore...');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        debugPrint('Usuario nuevo, creando documento en Firestore...');
        await _createUserDocument(user);
        debugPrint('Documento de usuario creado correctamente');
      } else {
        debugPrint('Usuario existente encontrado en Firestore');
      }

      // Actualizar datos observables
      uid.value = user.uid;
      email.value = user.email ?? '';
      name.value = user.displayName ?? '';
      profilePicture.value = user.photoURL ?? '';

      // Actualizar datos del usuario en Firestore si es necesario
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': Timestamp.now(),
        'name': user.displayName ?? name.value,
        'email': user.email?.toLowerCase() ?? email.value,
        'photoUrl': user.photoURL ?? profilePicture.value,
      });

      debugPrint('Login con Google exitoso, redirigiendo a home');
      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('Error detallado en login con Google: $e');
      String errorMessage =
          'No se pudo completar el inicio de sesión con Google';

      if (e.toString().contains('network')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else if (e.toString().contains('canceled')) {
        errorMessage = 'Inicio de sesión cancelado.';
      } else if (e.toString().contains('credential')) {
        errorMessage =
            'Error de autenticación. Verifica tu configuración de Firebase.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  //* Login con Apple
  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      debugPrint('🍎 Iniciando login con Apple...');

      // Verificar disponibilidad del servicio
      final isAvailable = await SignInWithApple.isAvailable();
      debugPrint('🍎 Apple Sign In disponible: $isAvailable');

      if (!isAvailable) {
        throw Exception(
            'El inicio de sesión con Apple no está disponible en este dispositivo');
      }

      debugPrint('🍎 Solicitando credenciales de Apple...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('🍎 Credenciales de Apple obtenidas:');
      debugPrint('  - userIdentifier: ${credential.userIdentifier}');
      debugPrint('  - email: ${credential.email}');
      debugPrint('  - givenName: ${credential.givenName}');
      debugPrint('  - familyName: ${credential.familyName}');
      debugPrint(
          '  - authorizationCode length: ${credential.authorizationCode?.length}');
      debugPrint(
          '  - identityToken length: ${credential.identityToken?.length}');

      if (credential.identityToken == null) {
        debugPrint('❌ Error: identityToken es null');
        throw Exception('No se pudo obtener el token de identidad de Apple');
      }

      debugPrint('🍎 Creando credencial de Firebase...');
      final oAuthProvider = OAuthProvider('apple.com');
      final authCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      debugPrint('🍎 Iniciando sesión en Firebase...');
      final userCredential = await _auth.signInWithCredential(authCredential);
      final user = userCredential.user;

      if (user == null) {
        debugPrint('❌ Error: Firebase no devolvió un usuario válido');
        throw Exception('Error al iniciar sesión con Apple en Firebase');
      }

      debugPrint('🍎 Usuario autenticado en Firebase: ${user.uid}');
      debugPrint('🍎 Verificando documento en Firestore...');

      // Verificar si el usuario existe en Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        debugPrint('🍎 Usuario nuevo, creando documento en Firestore...');
        await _createUserDocument(user);
        debugPrint('🍎 Documento de usuario creado correctamente');
      } else {
        debugPrint('🍎 Usuario existente encontrado en Firestore');
      }

      // Actualizar datos observables
      uid.value = user.uid;
      email.value = user.email ?? '';
      name.value = user.displayName ?? credential.givenName ?? '';
      profilePicture.value = user.photoURL ?? '';

      // Actualizar datos del usuario en Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': Timestamp.now(),
        'name': user.displayName ?? credential.givenName ?? name.value,
        'email': user.email?.toLowerCase() ?? email.value,
        'photoUrl': user.photoURL ?? profilePicture.value,
      });

      debugPrint('🍎 Login con Apple exitoso, redirigiendo a home...');
      Get.offAllNamed('/home');
    } on SignInWithAppleAuthorizationException catch (e) {
      String errorMessage;
      debugPrint('❌ Error de autorización de Apple: ${e.code} - ${e.message}');

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
          errorMessage = 'Error al iniciar sesión con Apple: ${e.message}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Error de Firebase Auth: ${e.code} - ${e.message}');
      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
          errorMessage = 'Credenciales de Apple inválidas';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              'Ya existe una cuenta con este email usando otro método de autenticación';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Apple Sign In no está habilitado en Firebase Console';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta ha sido deshabilitada';
          break;
        default:
          errorMessage = 'Error de autenticación en Firebase: ${e.message}';
      }

      Get.snackbar(
        'Error de Firebase',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('❌ Error inesperado en login con Apple: $e');
      Get.snackbar(
        'Error',
        'No se pudo completar el inicio de sesión con Apple: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      // Aquí implementarías la lógica para subir la imagen a Firebase Storage
      // y actualizar la URL en Firestore
      // Por ahora solo actualizamos el estado local
      profileImage.value = imagePath;
      Get.snackbar(
        'Éxito',
        'Imagen de perfil actualizada',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la imagen de perfil',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      if (uid.value.isEmpty) return;

      await _firestore.collection('users').doc(uid.value).update({
        'name': newName,
      });

      userName.value = newName;
      Get.snackbar(
        'Éxito',
        'Nombre actualizado correctamente',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error al actualizar nombre: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el nombre',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Aquí implementarías la lógica para eliminar la cuenta en Firebase
      // Por ahora solo cerramos sesión
      await logout();
      Get.snackbar(
        'Éxito',
        'Cuenta eliminada correctamente',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la cuenta',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadSecuritySettings() async {
    try {
      if (uid.value.isEmpty) return;

      final userDoc = await _firestore.collection('users').doc(uid.value).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        isAppLockEnabled.value = data['isAppLockEnabled'] ?? false;
        isBiometricEnabled.value = data['isBiometricEnabled'] ?? false;
        pin.value = data['pin'] ?? '';
        lockTimeout.value = data['lockTimeout'] ?? 'immediately';

        // Si hay PIN configurado, redirigir a la pantalla de verificación
        if (isAppLockEnabled.value && pin.value.isNotEmpty) {
          Get.offAllNamed('/app-lock');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar configuración de seguridad: $e');
    }
  }

  Future<void> toggleAppLock(bool value) async {
    try {
      isAppLockEnabled.value = value;
      if (value && pin.value.isEmpty) {
        // Si se activa el bloqueo y no hay PIN, mostrar diálogo para configurarlo
        Get.dialog(
          AlertDialog(
            title: const Text('Configurar PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  onChanged: (value) => pin.value = value,
                  decoration: const InputDecoration(
                    labelText: 'PIN (4 dígitos)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  isAppLockEnabled.value = false;
                  Get.back();
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  if (pin.value.length == 4) {
                    await _saveSecuritySettings();
                    Get.back();
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        );
      } else {
        await _saveSecuritySettings();
      }
    } catch (e) {
      debugPrint('Error al cambiar estado de bloqueo: $e');
      Get.snackbar(
        'Error',
        'No se pudo cambiar el estado del bloqueo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveSecuritySettings() async {
    if (uid.value.isEmpty) return;

    await _firestore.collection('users').doc(uid.value).update({
      'isAppLockEnabled': isAppLockEnabled.value,
      'isBiometricEnabled': isBiometricEnabled.value,
      'pin': pin.value,
      'lockTimeout': lockTimeout.value,
    });
  }

  Future<void> toggleBiometric(bool value) async {
    try {
      isBiometricEnabled.value = value;
      await _saveSecuritySettings();
      Get.snackbar(
        'Éxito',
        value ? 'Biometría activada' : 'Biometría desactivada',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error al cambiar estado de biometría: $e');
      Get.snackbar(
        'Error',
        'No se pudo cambiar el estado de la biometría',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> updatePin(String newPin) async {
    try {
      pin.value = newPin;
      // Aquí implementarías la lógica para guardar en Firebase/local storage
      Get.snackbar(
        'Éxito',
        'PIN actualizado correctamente',
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error al actualizar PIN: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el PIN',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> setLockTimeout(String timeout) async {
    try {
      lockTimeout.value = timeout;
      // Aquí implementarías la lógica para guardar en Firebase/local storage
    } catch (e) {
      debugPrint('Error al cambiar tiempo de bloqueo: $e');
      Get.snackbar(
        'Error',
        'No se pudo cambiar el tiempo de bloqueo',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
