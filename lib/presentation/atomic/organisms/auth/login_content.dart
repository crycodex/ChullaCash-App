import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_colors.dart';
import '../../../controllers/Login/auth_controller.dart';
//molecules
import '../../molecules/Login/login_form.dart';

class LoginContent extends StatefulWidget {
  final VoidCallback onClose;

  const LoginContent({super.key, required this.onClose});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> {
  //controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.put(AuthController());

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin({
    required String email,
    required String password,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    debugPrint('LoginContent: Iniciando login con email: $email');
    try {
      await _authController.login(
        email: email,
        password: password,
        onSuccess: () {
          debugPrint('LoginContent: Login exitoso, navegando a home');
          Get.offAllNamed('/home');
          onSuccess();
        },
        onError: (error) {
          debugPrint('LoginContent: Error en login - $error');
          onError(error);
        },
      );
    } catch (e) {
      debugPrint('LoginContent: Error inesperado - $e');
      onError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener información de la pantalla y fuente
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final textScaleFactor = mediaQuery.textScaler;

    // Espaciados dinámicos basados en el tamaño de pantalla y fuente
    final dynamicSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 12.0 : 16.0;
    final headerSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 16.0 : 24.0;
    final sectionSpacing =
        screenHeight < 700 || textScaleFactor.scale(1.2) > 1.2 ? 16.0 : 24.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header más compacto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Iniciar sesión',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.fontSize !=
                                null
                            ? Theme.of(context)
                                    .textTheme
                                    .displayMedium!
                                    .fontSize! *
                                (textScaleFactor.scale(1.3) > 1.3 ? 0.9 : 1.0)
                            : null,
                      ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onClose,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
          SizedBox(height: dynamicSpacing * 0.5),
          Text(
            'En tu cuenta',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: headerSpacing),

          // Formulario expandido con mejor scroll
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //login form
                  LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocusNode: _emailFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    formKey: _formKey,
                    onSubmit: _handleLogin,
                  ),

                  SizedBox(height: dynamicSpacing * 0.5),

                  // Olvidé mi contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _authController.toggleForgotPassword();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: textScaleFactor.scale(1.3) > 1.3 ? 13 : 14,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: sectionSpacing),

                  // O inicia sesión con
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.lightGray)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O inicia sesión con',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: textScaleFactor.scale(1.3) > 1.3 ? 11 : 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.lightGray)),
                    ],
                  ),

                  SizedBox(height: sectionSpacing),

                  // Botones de redes sociales con mejor responsividad
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _authController.loginWithGoogle();
                          },
                          icon: Image.asset(
                            'lib/assets/icons/others/googleIcon.png',
                            height: textScaleFactor.scale(1.3) > 1.3 ? 20 : 24,
                          ),
                          label: Text(
                            'Google',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: textScaleFactor.scale(1.3) > 1.3 ? 13 : 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: textScaleFactor.scale(1.2) > 1.2 ? 10 : 12,
                            ),
                            side: BorderSide(color: AppColors.lightGray),
                            backgroundColor: AppColors.surfaceLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (GetPlatform.isIOS) ...[
                        SizedBox(width: dynamicSpacing),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _authController.loginWithApple();
                            },
                            icon: Image.asset(
                              'lib/assets/icons/others/apple.png',
                              height: textScaleFactor.scale(1.3) > 1.3 ? 20 : 24,
                            ),
                            label: Text(
                              'Apple',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: textScaleFactor.scale(1.3) > 1.3 ? 13 : 14,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: textScaleFactor.scale(1.2) > 1.2 ? 10 : 12,
                              ),
                              side: BorderSide(color: AppColors.lightGray),
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: sectionSpacing),

                  // Enlace de registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "¿No tienes una cuenta? ",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _authController.toggleRegister();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Espacio adicional para el scroll
                  SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom > 0
                          ? 20
                          : 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
